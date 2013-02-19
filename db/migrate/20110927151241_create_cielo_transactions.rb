class CreateCieloTransactions < ActiveRecord::Migration
  def self.up
    create_table :cielo_transactions do |t|
      t.string :tid
      t.string :status
      t.string :pan
      
      t.text :forma_pagamento
      t.text :autenticacao
      t.text :autorizacao
      t.text :captura
      
      t.integer :order_id
      
      t.timestamps
    end
  end

  def self.down
    drop_table :cielo_transactions
  end
end