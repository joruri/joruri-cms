# encoding: utf-8
class Newsletter::Doc < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Base::Config
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Cms::Model::Rel::Content
  include Cms::Model::Auth::Concept

  include StateText

  belongs_to :content, foreign_key: :content_id,
             class_name: 'Newsletter::Content::Base'
  has_many :logs, foreign_key: :doc_id,
           class_name: 'Newsletter::Log', dependent: :destroy

  validates :state, :title, :body, presence: true

  scope :search, ->(params) {
    rel = all

    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_id'
        rel = rel.where(id: v)
      when 's_title'
        rel = rel.where(arel_table[:title].maches("%#{v}%"))
      end
    end if params.size != 0

    rel
  }

  def validate
    if content.template_state == 'enabled'
      errors.add :body, "がテンプレートの内容から変更されていません。" if body == content.template
      errors.add :mobile_body, "がテンプレートの内容から変更されていません。" if mobile_body == content.template_mobile
    end
  end

  def delivery_states
    [%w(未配信 yet), %w(配信中 delivering), %w(配信済み delivered), %w(配信失敗 error)]
  end

  def delivery_status
    delivery_states.each { |val, key| return val if delivery_state.to_s == key }
    nil
  end

  def testers
    return @testers if @testers
    @testers = Newsletter::Tester
               .enabled
               .where(content_id: content_id)
               .order(agent_state: :desc, id: :desc)
  end

  def members
    return @members if @members
    @members = Newsletter::Member
               .enabled
               .where(content_id: content_id)
               .order(letter_type: :desc, id: :asc)
  end

  def mail_from
    addr = item.setting_value('sender_address')
    @mail_from[content_id] = !addr.blank? ? addr : 'webmaster@' + item.site.full_uri.gsub(/^.*?\/\/(.*?)(:|\/).*/, '\\1')
  end

  def mail_title(mobile = false)
    return mobile_title.blank? ? title : mobile_title if mobile && mobile
    title
  end

  def mail_body(mobile = false)
    if mobile
      _body  = mobile_body.blank? ? body : mobile_body
      if content.signature_state == 'enabled'
        _body += "\n\n#{content.signature_mobile}"
      end
      return _body
    end

    _body  = body.to_s
    _body += "\n\n#{content.signature}" if content.signature_state == 'enabled'
    _body
  end
end
