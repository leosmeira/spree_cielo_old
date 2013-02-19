module ProductHelper
  def format_cielo_price(number)
    format_price(number.insert(-3, '.').to_f)
  end
end