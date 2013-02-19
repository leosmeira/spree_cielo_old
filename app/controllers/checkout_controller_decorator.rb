# encoding: utf-8

require File.expand_path(File.join(File.dirname(__FILE__), "..", "models", "cielo_connection_error_exception"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "models", "cielo_service_error_exception"))

CheckoutController.class_eval do

  before_filter :redirect_to_cielo, :only => :update
  rescue_from Cielo::ConnectionError, :with => :rescue_from_cielo_connection_error
  rescue_from Cielo::ServiceError, :with => :rescue_from_cielo_service_error

  def cielo_callback
    cielo_transaction = current_order.cielo_transactions.last

    if cielo_transaction.nil?
      flash[:error] = 'Houve um erro ao processar sua transação. Verifique seu pedido e tente novamente'
      redirect_to products_path
      return
    end

    cielo_transaction.verify!
    payment = create_and_start_processing_payment(cielo_transaction)

    if cielo_transaction.authorized_or_catched?
      payment.complete!

      # need to force checkout to complete state
      until current_order.state == "complete"
        if current_order.next!
          current_order.update!
          state_callback(:after)
          after_complete
          redirect_to order_path(current_order)
        end
      end
    else
      payment.fail!
      flash_error_message(cielo_transaction)
      redirect_to checkout_state_path(current_order.state)
    end
  end

  private

    def redirect_to_cielo
      return unless params[:state] == "payment"

      payment_method = PaymentMethod.find(params[:order][:payments_attributes].first[:payment_method_id])
      return unless payment_method.kind_of?(BillingIntegration::CieloBillingIntegration)

      transaction = CieloTransaction.create_and_generate_tid(
          current_order,
          :bandeira => get_bandeira(params),
          :parcelas => get_parcelas(params),
          :callback => url_for(:controller => 'checkout', :action => 'cielo_callback')
      )

      redirect_to transaction[:raw_transaction][:"url-autenticacao"]
    end
    
    def flash_error_message(cielo_transaction)
      autorizacao_negada = "5"

      transaction = cielo_transaction[:raw_transaction]

      if transaction[:autenticacao] and transaction[:autenticacao][:mensagem] == "Transacao sem autenticacao"
        flash[:error] = 'Transação sem autenticação. Tente novamente'
      elsif transaction[:autorizacao] and transaction[:autorizacao][:codigo] == autorizacao_negada
        flash[:error] = 'Autorização negada. Tente novamente'
      elsif transaction[:cancelamento] and transaction[:cancelamento][:mensagem] == 'Cancelamento solicitado pelo usuario'
        flash[:error] = 'Compra cancelada. Tente novamente'
      elsif transaction[:cancelamento] and transaction[:cancelamento][:mensagem] == 'Cancelamento por timeout do usuario'
        flash[:error] = 'Compra cancelada por demora a efetuar pagamento. Tente novamente'
      else
        flash[:error] = 'Houve um erro na transação. Tente novamente'
      end
    end

    def after_complete
      session['order_id'] = nil
    end

    def cielo_record_log(payment, transaction)
      payment.log_entries.create(:details => transaction.raw_transaction.to_yaml)
    end

    # payment processing
    def create_and_start_processing_payment(cielo_transaction)
      payment = current_order.payments.create(
        :amount => current_order.total,
        :source_type => 'Payment',
        :payment_method_id => PaymentMethod.find_by_type("BillingIntegration::CieloBillingIntegration").id
      )

      payment.started_processing!
      cielo_record_log(payment, cielo_transaction)
      
      payment
    end

    #  helpers for form's params
    def get_bandeira(params)
      params['order']['payments_attributes'][0]['payment_flag'].downcase
    end

    def get_parcelas(params)
      payments_attributes = params['order'][:payments_attributes][0]
      payment_method_id = payments_attributes['payment_method_id']
      parcelas = payments_attributes['payment_method_parcelas'][payment_method_id].to_i
      
      # ERRRO - BUG
      #max_parcelas = order_has_subscription? ? 12 : 3
      max_parcelas = 3
      
      # previne que o user compre com mais parcelas que o permitido
      parcelas = max_parcelas if parcelas > max_parcelas

      parcelas
    end

    def rescue_from_cielo_connection_error
      flash[:error] = 'Erro ao criar transação na Cielo. Tente novamente'
      redirect_to products_path
    end

    def rescue_from_cielo_service_error
      flash[:error] = 'Serviço indisponível. Tente novamente'
      redirect_to products_path
    end

    def order_has_subscription?
      @order.line_items.any? { |line_item| line_item.variant.product.subscription? }
    end

end
