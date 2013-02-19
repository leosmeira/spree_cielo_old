class AddCancelamentoToCieloTransactions < ActiveRecord::Migration
  def self.up
    add_column :cielo_transactions, :cancelamento, :text
  end

  def self.down
    remove_column :cielo_transactions, :cancelamento
  end
end
