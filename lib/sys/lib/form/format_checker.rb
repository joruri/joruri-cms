# encoding: utf-8
class Sys::Lib::Form::FormatChecker
  def self.email?(text)
    text =~ /\A.+@.+\z/
  end
end