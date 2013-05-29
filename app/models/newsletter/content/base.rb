# encoding: utf-8
class Newsletter::Content::Base < Cms::Content
  
  has_many :docs, :foreign_key => :content_id, :class_name => 'Newsletter::Doc',
    :dependent => :destroy
  has_many :members, :foreign_key => :content_id, :class_name => 'Newsletter::Member',
    :dependent => :destroy
  has_many :requests, :foreign_key => :content_id, :class_name => 'Newsletter::Request',
    :dependent => :destroy
  has_many :testers, :foreign_key => :content_id, :class_name => 'Newsletter::Tester',
    :dependent => :destroy
  has_many :logs, :foreign_key => :content_id, :class_name => 'Newsletter::Log',
    :dependent => :destroy

  def form_node
    return @form_node if @form_node
    item = Cms::Node.new.public
    item.and :content_id, id
    item.and :model, 'Newsletter::Form'
    @form_node = item.find(:first, :order => :id)
  end
  
  def mail_from
    addr = setting_value("sender_address")
    !addr.blank? ? addr : "webmaster@" + site.full_uri.gsub(/^.*?\/\/(.*?)(:|\/).*/, '\\1')
  end
  
  def sender_address
    setting_value(:sender_address)
  end

  def template_state
    setting_value(:template_state)
  end

  def template
    setting_value(:template)
  end

  def template_mobile
    setting_value(:template_mobile)
  end

  def signature_state
    setting_value(:signature_state)
  end

  def signature
    setting_value(:signature)
  end

  def signature_mobile
    setting_value(:signature_mobile)
  end

  def summary
    setting_value(:summary)
  end

  def summary_mobile
    setting_value(:summary)
  end

  def addition_body
    setting_value(:addition_body)
  end

  def addition_body_mobile
    setting_value(:addition_body)
  end

  def deletion_body
    setting_value(:deletion_body)
  end

  def deletion_body_mobile
    setting_value(:deletion_body)
  end

  def sent_addition_body
    setting_value(:sent_addition_body)
  end

  def sent_addition_body_mobile
    setting_value(:sent_addition_body)
  end

  def sent_deletion_body
    setting_value(:sent_deletion_body)
  end

  def sent_deletion_body_mobile
    setting_value(:sent_deletion_body)
  end
end