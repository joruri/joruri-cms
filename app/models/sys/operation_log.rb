# encoding: utf-8
class Sys::OperationLog < ActiveRecord::Base
  include Sys::Model::Base

  scope :search, ->(params) {
    rel = all

    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_id'
        rel = rel.where(id: v)
      when 's_user_id'
        rel = rel.where(user_id: v)
      when 's_action'
        rel = rel.where(action: v)
      end
    end if params.size != 0

    rel
  }

  def self.log(request, options = {})
    params = request.params

    log = new
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
      log.item_id     = begin
                          item.id
                        rescue
                          nil
                        end
      log.item_unid   = begin
                          item.unid
                        rescue
                          nil
                        end
      log.item_name   = begin
                          item.title
                        rescue
                          nil
                        end
      begin
        log.item_name ||= item.name
      rescue
        nil
      end
      begin
        log.item_name ||= "##{item.id}"
      rescue
        nil
      end
      log.item_name   = log.item_name.to_s.split(//u).slice(0, 80).join unless log.item_name.blank?
    end

    log.save
  end
end
