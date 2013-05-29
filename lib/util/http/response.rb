# encoding: utf-8
class Util::Http::Response
  attr_accessor :status, :header, :body
  
  def initialize(attributes = {})
    self.status = attributes[:status]
    self.header = attributes[:header]
    self.body   = attributes[:body]
  end
end