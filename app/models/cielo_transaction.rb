# encoding: utf-8

require File.expand_path(File.join(File.dirname(__FILE__), "cielo_connection_error_exception"))
require File.expand_path(File.join(File.dirname(__FILE__), "cielo_service_error_exception"))

class CieloTransaction < ActiveRecord::Base

  serialize :raw_transaction

  # Creates an alias to get a property in raw_transaction
  #
  # Examples:
  #  1. link_to_raw_transaction(:status)
  #       creates cielo_transaction.status that links to cielo_transaction.raw_transaction[:status]
  #
  #  2. link_to_raw_transaction(:status, :cancelamento)
  #       creates both aliases
  def self.link_to_raw_transaction(*args)
    args.each do |property|
      define_method property do
        raw_transaction[property]
      end
    end
  end

  belongs_to :order

  link_to_raw_transaction(
      :status, :tid, :pan,
      :autenticacao, :autorizacao, :captura,
      :cancelamento, :order_id
  )
  
  def forma_pagamento
    raw_transaction[:'forma-pagamento']
  end

  def status_label
    labels = ['Criada', 'Em andamento', 'Autenticada', 'Não autenticada', 'Autorizada ou pendete de captura',
              'Não autorizada', 'Capturada', 'não-existe', 'Não capturada', 'Cancelada', 'Em Autenticação']
    labels[status.to_i]
  end

  def authorized_or_catched?
    status == "4" or status == "6" # "autorizada ou pendente de captura" ou capturada
  end

  # Verifies the transaction and updates in the DB
  def verify!
    external_transaction = Cielo::Transaction.new.verify!(raw_transaction[:tid])[:transacao]
    update_attribute :raw_transaction, external_transaction
  end
    
  # Creates a transaction in Cielo's server an record it in the order
  #
  # Accepts: Order object
  #          params[:bandeira] - visa, mastercard, diners
  #          params[:callback] - http://www.vandal.com.br/cielo/callback
  #          params[:parcelas] (optional)
  #
  # Example: CieloTransaction.create_and_generate_tid(order, 
  #             :bandeira => 'visa', :callback => 'http://www.vandal.com.br/cielo/calback')
  def self.create_and_generate_tid(order, params={})
    data = {
        :numero => order.number,
        :valor => order.total_in_cielo_format,
        :bandeira => params[:bandeira],
        :"url-retorno" => params[:callback],
        :autorizar => '2' # 1- autorizar somente se autenticada / 2- autorizar autenticada e não-autenticada
    }

    parcelas = params[:parcelas]
    if parcelas > 1
      data[:produto] = 2 # credito_a_vista = 1 / parcelado_loja = 2 / parcelado_administradora = 3 / debito = "A"
      data[:parcelas] = parcelas
    end

    transaction = create_external_cielo_transaction(data)
    record_cielo_transaction(order, transaction)
  end

  # helper for cielo gem
  def self.create_external_cielo_transaction(data)
    transaction = Cielo::Transaction.new
    transaction = transaction.create!(data)
    if transaction[:erro]
      code = transaction[:erro][:codigo]
      
      raise Cielo::ConnectionError if code == "000"
      # falha ao conectar no servidor da Cielo
      
      raise Cielo::ServiceError if code == "097"
      # serviço indisponível
    end


    transaction[:transacao]
  end

  # record stuff
  def self.record_cielo_transaction(order, transaction)
    order.cielo_transactions.create(:raw_transaction => transaction)
  end

end
