# encoding: utf-8
class Newsletter::Log < ActiveRecord::Base
  include Sys::Model::Base

  def search(params)
    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_id'
        self.and :id, v
      when 's_email'
        self.and_keywords v, :email
      end
    end if params.size != 0

    return self
  end
end