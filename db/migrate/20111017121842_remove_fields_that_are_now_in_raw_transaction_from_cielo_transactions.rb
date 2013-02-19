class RemoveFieldsThatAreNowInRawTransactionFromCieloTransactions < ActiveRecord::Migration
  def self.up
    remove_column :cielo_transactions, :tid
    remove_column :cielo_transactions, :status
    remove_column :cielo_transactions, :pan
    remove_column :cielo_transactions, :forma_pagamento
    remove_column :cielo_transactions, :autenticacao
    remove_column :cielo_transactions, :autorizacao
    remove_column :cielo_transactions, :captura
    remove_column :cielo_transactions, :cancelamento
  end

  def self.down
    add_column :cielo_transactions, :tid, :string
    add_column :cielo_transactions, :status, :string
    add_column :cielo_transactions, :pan, :string
    add_column :cielo_transactions, :forma_pagamento, :text
    add_column :cielo_transactions, :autenticacao, :text
    add_column :cielo_transactions, :autorizacao, :text
    add_column :cielo_transactions, :captura, :text
    add_column :cielo_transactions, :cancelamento, :text
  end
end