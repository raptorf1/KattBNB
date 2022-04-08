module PriceService
  def self.two_decimals_converter(number)
    string_with_2_decimals = sprintf('%.2f', number.to_s)
    if string_with_2_decimals.last(2) == '00'
      return string_with_2_decimals.to_i
    else
      return sprintf('%.2f', string_with_2_decimals)
    end
  end

  def self.calculate_kattbnb_charge(number)
    charge = number + (number * 0.17) + ((number * 0.17) * 0.25)
    return charge
  end
end
