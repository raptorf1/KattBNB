module PriceService
  def self.two_decimals_converter(number)
    string_with_2_decimals = sprintf('%.2f', number.to_s)
    string_with_2_decimals.last(2) == '00' ? string_with_2_decimals.to_i : sprintf('%.2f', string_with_2_decimals)
  end

  def self.calculate_kattbnb_charge(number)
    charge = number + (number * 0.17) + ((number * 0.17) * 0.25)
    charge
  end
end
