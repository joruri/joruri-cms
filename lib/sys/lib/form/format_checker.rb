# encoding: utf-8
class Sys::Lib::Form::FormatChecker
  def self.email?(text)
    text =~ /^[A-Za-z0-9]+[\w-]+@[\w\.-]+\.\w{2,}$/
  end
end