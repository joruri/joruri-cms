# encoding: utf-8
class Cms::DataText < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Base::Page
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Cms::Model::Rel::Site
  include Cms::Model::Rel::Concept
  include Cms::Model::Auth::Concept

  include StateText

  belongs_to :concept, foreign_key: :concept_id, class_name: 'Cms::Concept'

  validates :concept_id, :state, :name, :title, :body, presence: true
  validates :name, presence: true, uniqueness: { scope: :concept_id },
                   format: { with: /\A[0-9a-zA-Z\-_]+\z/, if: 'name.present?',
                             message: "は半角英数字、ハイフン、アンダースコアで入力してください。" }

  scope :search, -> (params) {
    rel = all

    data_texts = arel_table

    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_name_or_title'
        rel = rel.where(data_texts[:title].matches("%#{v}%")
          .or(data_texts[:name].matches("%#{v}%")))
      when 's_keyword'
        rel = rel.where(data_texts[:title].matches("%#{v}%")
          .or(data_texts[:name].matches("%#{v}%")
            .or(data_texts[:body].matches("%#{v}%"))
             )
                       )
      end
    end if params.size != 0

    rel
  }
end
