# encoding: utf-8
require 'csv'
class Sys::Admin::Groups::ImportController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)
  end

  def index
  end

  def import
    if !params[:item] || !params[:item][:file]
      return redirect_to(:action => :index)
    end

    @results = [0, 0, 0]

    require 'nkf'
    csv = NKF.nkf('-w', params[:item][:file].read)

    if params[:do] == 'groups'
      Core.messages << "インポート： グループ"
      import_groups(csv)
    elsif params[:do] == 'users'
      Core.messages << "インポート： ユーザ"
      import_users(csv)
    else
      return redirect_to(:action => :index)
    end

    Core.messages << "-- 追加 #{@results[0]}件"
    Core.messages << "-- 更新 #{@results[1]}件"
    Core.messages << "-- 失敗 #{@results[2]}件"

    flash[:notice] = ('インポートが終了しました。<br />' + Core.messages.join('<br />')).html_safe
    return redirect_to(:action => :index)
    
  rescue CSV::MalformedCSVError => e
    flash[:notice] = "インポートに失敗しました。（不正なCSVデータ）"
    return redirect_to(:action => :index)
  rescue Exception => e
    flash[:notice] = "インポートに失敗しました。（#{e}）"
    return redirect_to(:action => :index)
  end

  def import_groups(csv)
    CSV.parse(csv, :headers => true, :header_converters => :symbol) do |data|
      code        = data[:code]
      parent_code = data[:parent_code]

      if code.blank? || parent_code.blank?
        @results[2] += 1
        next
      end

      unless parent = Sys::Group.find_by_code(parent_code)
        @results[2] += 1
        next
      end

      group = Sys::Group.find_by_code(code) || Sys::Group.new({:code => code})

      group.parent_id    = parent.id
      group.state        = data[:state]
      group.web_state    = data[:web_state]
      group.level_no     = data[:level_no]
      group.sort_no      = data[:sort_no]
      group.layout_id    = data[:layout_id]
      group.ldap         = data[:ldap]
      group.ldap_version = data[:ldap_version]
      group.name         = data[:name]
      group.name_en      = data[:name_en]
      group.tel          = data[:tel]
      group.outline_uri  = data[:outline_uri]
      group.email        = data[:email]
      
      next unless group.changed?
      status = group.new_record? ? 0 : 1
      if group.save
        @results[status] += 1
      else
        @results[2] += 1
      end
    end
  end
  
  def import_users(csv)
    CSV.parse(csv, :headers => true, :header_converters => :symbol) do |data|
      account     = data[:account]
      group_code  = data[:group_code]

      if account.blank? || group_code.blank?
        @results[2] += 1
        next
      end

      unless group = Sys::Group.find_by_code(group_code)
        @results[2] += 1
        next
      end

      user = Sys::User.find_by_account(account) || Sys::User.new({:account => account})
      user.state        = data[:state]
      user.ldap         = data[:ldap]
      user.ldap_version = data[:ldap_version]
      user.auth_no      = data[:auth_no]
      user.name         = data[:name]
      user.name_en      = data[:name_en]
      user.password     = data[:password]
      user.email        = data[:email]
      user.in_group_id  = group.id if group.id != user.group_id
      
      next unless user.changed?
      
      status = user.new_record? ? 0 : 1
      status = 2 unless user.save
      
      @results[status] += 1
    end
  end
end
