# encoding: utf-8
class Newsletter::Script::RequestsController < ApplicationController
  
  def read
    @mail_from = {}
    
    Util::Config.load(:database, :section => false).each do |section, spec|
      next if section.to_s !~ /^#{Rails.env.to_s}_pull_database/ ## only pull_database
      begin
        @db = SlaveBase.establish_connection(spec).connection
        pull_requests
      rescue => e
        Script.error e.to_s
      end
    end
    
    @db = Newsletter::Request.connection
    check_requests
    
    return render(:text => "OK")
  rescue Script::InterruptException => e
    raise e
  end
  
protected
  def mail_from(content_id)
    return @mail_from[content_id] if @mail_from[content_id]
    item = Newsletter::Content::Base.find_by_id(content_id)
    addr = item.setting_value("sender_address")
    @mail_from[content_id] = !addr.blank? ? addr : "webmaster@" + item.site.full_uri.gsub(/^.*?\/\/(.*?)(:|\/).*/, '\\1')
  rescue
    raise "unknown mail from Cms::Content##{content_id}"
  end
  
  def pull_requests
    sql = "SELECT * FROM newsletter_requests WHERE state = 'enabled' order BY id"
    
    @db.execute(sql).each(:as => :hash) do |data|
      req = Newsletter::Request.new(data)
      if req.save
        @db.execute("DELETE FROM newsletter_requests WHERE id = #{data['id']}")
      end
    end
  end
  
  def check_requests
    requests = Newsletter::Request.find(:all, :conditions => {:state => "enabled"}, :order => "created_at")
    
    Script.total requests.size
    
    requests.each do |req|
      Script.current
      begin
        if req.request_type == "subscribe"
          subscribe(req)
        elsif req.request_type == "unsubscribe"
          unsubscribe(req)
        end
        req.state = "disabled"
        req.save
        
        Script.success
      rescue Script::InterruptException => e
        raise e
      rescue => e
        Script.error e.to_s
      end
    end
  end
  
  def subscribe(req)
    mem = Newsletter::Member.find(:first, :conditions => {:state => 'enabled', :content_id => req.content_id, :email => req.email })
    
    ## already exists
    return true if mem
    
    mem = Newsletter::Member.new({
      :state       => 'enabled',
      :content_id  => req.content_id,
      :letter_type => req.letter_type,
      :email       => req.email,
    })
    if !mem.save
      raise mem.errors.full_messages.join(" ")
    end
      
    send_mail({
      :from    => mail_from(req.content_id),
      :to      => mem.email,
      :subject => "#{mem.content.name}登録完了のお知らせ",
      :body    => req.subscribe_notice_body
    })
  end
  
  def unsubscribe(req)
    mem = Newsletter::Member.find(:first, :conditions => {:state => 'enabled', :content_id => req.content_id, :email => req.email })
    
    ## not found
    return true unless mem
    
    if !mem.destroy
      raise mem.errors.full_messages.join(" ")
    end
    
    send_mail({
      :from    => mail_from(req.content_id),
      :to      => mem.email,
      :subject => "#{mem.content.name}解除完了のお知らせ",
      :body    => req.unsubscribe_notice_body
    })
  end

end
