# encoding: utf-8
class Util::String::CheckDigit
  def self.check(value)
    digit = 0
    value.to_s.split(//).reverse.each_with_index do |chr, idx|
      digit += chr.to_i * (idx.even? ? 3 : 1)
    end
    digit = (10 - (digit % 10)) % 10
    value.to_s + digit.to_s
  end
  
  def self.get_digit(code)# m10w31
    digit = 0
    code.to_s.split(//).reverse.each_with_index do |chr, idx|
      digit += chr.to_i * (idx.even? ? 3 : 1)
    end
    digit = (10 - (digit % 10)) % 10
    return digit.to_s
  end
  
  def self.add_digit(code)
    return code.to_s + self.get_digit(code)
  end
end
