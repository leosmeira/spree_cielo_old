class AddRawTransactionToCieloTransaction < ActiveRecord::Migration
  def self.up
    add_column :cielo_transactions, :raw_transaction, :text
  end

  def self.down
    remove_column :cielo_transactions, :raw_transaction
  end
end
