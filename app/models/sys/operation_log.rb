# encoding: utf-8
class Sys::OperationLog < ActiveRecord::Base
  include Sys::Model::Base
  
  def self.log(request, options = {})
    params = request.params
    
    log = self.new
    log.uri       = Core.request_uri
    log.action    = params[:do]
    log.action    = params[:action] if params[:do].blank?
    log.ipaddr    = request.remote_addr
    
    if user = options[:user]
      log.user_id   = user.id
      log.user_name = user.name
    elsif user = Core.user
      log.user_id   = user.id
      log.user_name = user.name
    end
    
    if item = options[:item]
      log.item_model  = item.class.to_s
      log.item_id     = item.id rescue nil
      log.item_unid   = item.unid rescue nil
      log.item_name   = item.title rescue nil
      log.item_name ||= item.name rescue nil
      log.item_name ||= "##{item.id}" rescue nil
      log.item_name   = log.item_name.to_s.split(//u).slice(0, 80).join if !log.item_name.blank?
    end
    
    log.save
  end
  
  def search(params)
    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_id'
        self.and :id, v
      when 's_user_id'
        self.and :user_id, v
      when 's_action'
        self.and :action, v
        #self.and_keywords v, :action
      end
    end if params.size != 0

    return self
  end
  
end