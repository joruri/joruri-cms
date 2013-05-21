# encoding: utf-8
class Newsletter::Script::DocsController < ApplicationController
  
  def deliver
    id = Script.options[:doc_id] 
    raise "記事IDが入力されていません。" if id.blank?
    
    @doc = Newsletter::Doc.find_by_id(id)
    raise "記事が入力されていません。##{id}" unless @doc
    raise "コンテンツが見つかりません。##{id}" unless @content = @doc.content
    
    _deliver
    return render(:text => "OK")
  
  rescue Script::InterruptException => e
    raise e
  end
  
protected

  def _deliver
    ## start
    @doc.delivery_state = 'delivering'
    @doc.started_at     = Core.now
    @doc.delivered_at   = nil
    @doc.total_count    = 0
    @doc.success_count  = 0
    @doc.error_count    = 0
    @doc.save
    
    pc_title = @doc.mail_title
    pc_body  = @doc.mail_body
    mb_title = @doc.mail_title(true)
    mb_body  = @doc.mail_body(true)
    
    ## members
    cond    = { :content_id => @doc.content_id, :state => 'enabled' }
    members = Newsletter::Member.find(:all, :select => "id, email, letter_type", :conditions => cond)
    
    Script.total members.size
    
    from = @content.sender_address || @doc.creator.user.email
    members.each do |mem|
      Script.current
      
      send_state = nil
      send_msg   = nil
      
      ## send mail
      begin
        send_mail({
          :from    => from,
          :to      => mem.email,
          :subject => mem.mobile? ? mb_title : pc_title,
          :body    => mem.mobile? ? mb_body : pc_body,
        })
        send_state = "sent"
        
        Script.success
      rescue Exception => e
        send_state = "error"
        send_msg   = e.to_s
        
        Script.error e.to_s
      end
      
      ## log
      log = Newsletter::Log.new({
        :content_id  => @content.id,
        :doc_id      => @doc.id,
        :member_id   => mem.id,
        :email       => mem.email,
        :letter_type => mem.letter_type,
        :state       => send_state,
        :message     => send_msg,
      })
      log.save
    end
    
    ## sent
    @doc.delivery_state = 'delivered'
    @doc.delivered_at   = Time.now
    @doc.total_count    = Script.total(0)
    @doc.success_count  = Script.success(0)
    @doc.error_count    = Script.error
    @doc.save
  end
end
