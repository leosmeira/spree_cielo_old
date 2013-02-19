Order.class_eval do
  has_many :cielo_transactions

  def total_in_cielo_format
    sprintf("%.2f", total).gsub(".", "")
  end
end