# encoding: utf-8
class Enquete::Answer < ActiveRecord::Base
  include Sys::Model::Base
  include Cms::Model::Base::Page
  include Sys::Model::Auth::Free

  belongs_to :content, :foreign_key => :content_id, :class_name => 'Article::Content::Doc'
  belongs_to :form   , :foreign_key => :form_id   , :class_name => 'Enquete::Form'
  belongs_to :status , :foreign_key => :state     , :class_name => 'Sys::Base::Status'
  has_many :columns  , :foreign_key => :answer_id , :class_name => 'Enquete::AnswerColumn',
    :dependent => :destroy

  validates_presence_of :form_id
  
  def column_value(column_id)
    columns.each do |col|
      return col.value if col.column_id == column_id
    end
    return nil
  end
end