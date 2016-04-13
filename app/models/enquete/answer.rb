# encoding: utf-8
class Enquete::Answer < ActiveRecord::Base
  include Sys::Model::Base
  include Cms::Model::Base::Page
  include Sys::Model::Auth::Free

  include StateText

  belongs_to :content, foreign_key: :content_id,
                       class_name: 'Article::Content::Doc'

  belongs_to :form, foreign_key: :form_id, class_name: 'Enquete::Form'

  has_many :columns, foreign_key: :answer_id,
                     class_name: 'Enquete::AnswerColumn', dependent: :destroy

  validates :form_id, presence: true

  def column_value(column_id)
    columns.each do |col|
      return col.value if col.column_id == column_id
    end
    nil
  end
end
