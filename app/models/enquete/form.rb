# encoding: utf-8
class Enquete::Form < ActiveRecord::Base
  include Sys::Model::Base
  include Cms::Model::Base::Page
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Cms::Model::Rel::Content
  include Cms::Model::Auth::Concept

  belongs_to :status,         :foreign_key => :state,             :class_name => 'Sys::Base::Status'
  has_many   :columns,        :foreign_key => :form_id,         :class_name => 'Enquete::FormColumn',
    :dependent => :destroy
  has_many   :answers,        :foreign_key => :form_id,         :class_name => 'Enquete::Answer',
    :dependent => :destroy

  validates_presence_of :name
  
  apply_simple_captcha :message => "の画像と文字が一致しません。"
  
  def public
    self.and "#{self.class.table_name}.state", 'public'
    self
  end
  
  def public_columns
    item = Enquete::FormColumn.new
    item.and :state, "public"
    item.and :form_id, id
    item.find(:all, :order => :sort_no)
  end
  
  def save_answer(values, client = {})
    ans = Enquete::Answer.new({
      :form_id    => id,
      :content_id => content_id,
      :state      => 'enabled',
      :ipaddr     => client[:ipaddr],
      :user_agent => client[:user_agent]
    })
    return false unless ans.save
    
    columns.each do |col|
      value = values[col.element_name]
      next if value.blank?
      
      acol = Enquete::AnswerColumn.new({
        :answer_id => ans.id,
        :form_id   => id,
        :column_id => col.id,
        :value     => value
      })
      acol.save
    end
    ans
  end
end