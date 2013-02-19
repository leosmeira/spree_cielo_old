module CheckoutHelper
  def parcelas_range
    # max_parcelas = @order.has_subscription? ? 12 : 3
    #     (1..max_parcelas)
    
    # Define a quantidade de parcelas, dependendo do VALOR do Pedido.
    if @order.total >= 150
      1..3
    elsif @order.total >= 70
      1..2
    else
      1..1
    end  
    
  end
end