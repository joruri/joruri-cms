# encoding: utf-8
class Newsletter::Doc < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Base::Config
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Cms::Model::Rel::Content
  include Cms::Model::Auth::Concept

  belongs_to :status,  :foreign_key => :state,      :class_name => 'Sys::Base::Status'
  belongs_to :content, :foreign_key => :content_id, :class_name => 'Newsletter::Content::Base'
  has_many   :logs,    :foreign_key => :doc_id,     :class_name => 'Newsletter::Log',
    :dependent => :destroy

  validates_presence_of :state, :title, :body

  def validate
    if content.template_state == 'enabled'
      errors.add :body, "がテンプレートの内容から変更されていません。" if body == content.template
      errors.add :mobile_body, "がテンプレートの内容から変更されていません。" if mobile_body == content.template_mobile
    end
  end

  def delivery_states
    [['未配信','yet'], ['配信中','delivering'], ['配信済み','delivered'], ['配信失敗','error']]
  end

  def delivery_status
    delivery_states.each {|val, key| return val if delivery_state.to_s == key }
    nil
  end
  
  def testers
    return @testers if @testers
    test = Newsletter::Tester.new.enabled
    test.and :content_id, self.content_id
    test.order 'agent_state DESC, id DESC'
    @testers = test.find(:all)
  end

  def members
    return @members if @members
    member = Newsletter::Member.new.enabled
    member.and :content_id, self.content_id
    member.order 'letter_type DESC, id'
    @members = member.find(:all)
  end
  
  def mail_from
    addr = item.setting_value("sender_address")
    @mail_from[content_id] = !addr.blank? ? addr : "webmaster@" + item.site.full_uri.gsub(/^.*?\/\/(.*?)(:|\/).*/, '\\1')
    
  end
  
  def mail_title(mobile = false)
    if mobile
      return mobile_title.blank? ? title : mobile_title if mobile
    end
    return title
  end

  def mail_body(mobile = false)
    if mobile
      _body  = mobile_body.blank? ? body : mobile_body
      _body += "\n\n#{content.signature_mobile}" if content.signature_state == 'enabled'
      return _body
    end
    
    _body  = body.to_s
    _body += "\n\n#{content.signature}" if content.signature_state == 'enabled'
    return _body
  end

  def search(params)
    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_id'
        self.and "#{self.class.table_name}.id", v
      when 's_title'
        self.and_keywords v, :title
      end
    end if params.size != 0

    return self
  end

end