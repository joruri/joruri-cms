# encoding: utf-8
module LinkHelper
  def action_menu(type, link = nil, options = {})
    action = params[:action]
    
    if action =~ /index/
      return '' if [:index, :show, :edit, :destroy].index(type)
    elsif action =~ /(show|destroy)/
      return '' unless [:index, :edit, :destroy].index(type)
    elsif action =~ /(new|create)/
      return '' unless [:index].index(type)
    elsif action =~ /(edit|update)/
      return '' unless [:index, :show].index(type)
    end
    
    params = {}
    
    if type == :destroy
      params[:confirm] = '削除してよろしいですか？'
      params[:method]  = :delete
    end
    
    if link.is_a?(String)
      return link_to(type, link.to_s, params)
    elsif link.class == Array
      return link_to(link[0], link[1], params)
    else
      return link_to(type, url_for(:action => type), params)
    end
  end
  
  def link_to(*params)
    labels = {
      :up        => '上へ',
      :index     => '一覧',
      :list      => '一覧',
      :show      => '詳細',
      :new       => '新規作成',
      :edit      => '編集',
      :rename    => '名称変更',
      :move      => '移動',
      :duplicate => '複製',
      :delete    => '削除',
      :destroy   => '削除',
      :open      => '公開',
      :close     => '非公開',
      :enabale   => '有効化',
      :disable   => '無効化',
      :recognize => '承認',
      :publish   => '公開',
      :close     => '非公開'
    }
    params[0] = labels[params[0]] if labels.key?(params[0])
    super(*params)
  end
  
  ## E-mail to entity
  def email_to(addr, text = nil)
    return '' if addr.blank?
    text ||= addr
    addr.gsub!(/@/, '&#64;')
    addr.gsub!(/a/, '&#97;')
    text.gsub!(/@/, '&#64;')
    text.gsub!(/a/, '&#97;')
    mail_to(text.html_safe, addr.html_safe).html_safe
  end
  
  ## Tel
  def tel_to(tel, text = nil)
    text ||= tel
    return tel if tel.to_s !~ /^([\(]?)([0-9]+)([-\(\)]?)([0-9]+)([-\)]?)([0-9]+$)/
    link_to text.html_safe, "tel:#{tel}"
  end
end