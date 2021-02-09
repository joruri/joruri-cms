# encoding: utf-8
class Enquete::AnswerColumn < ActiveRecord::Base
  include Sys::Model::Base
  include Cms::Model::Base::Page
  include Sys::Model::Auth::Free

  has_one :attachment, dependent: :destroy

  belongs_to :form_column, foreign_key: :column_id,
                           class_name: 'Enquete::FormColumn'
end
