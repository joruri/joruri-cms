# encoding: utf-8
class Enquete::Form < ActiveRecord::Base
  include Sys::Model::Base
  include Cms::Model::Base::Page
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Cms::Model::Rel::Content
  include Cms::Model::Auth::Concept

  include StateText

  has_many :columns, foreign_key: :form_id,
                     class_name: 'Enquete::FormColumn',
                     dependent: :destroy

  has_many :answers, foreign_key: :form_id,
                     class_name: 'Enquete::Answer',
                     dependent: :destroy

  validates :name, presence: true

  apply_simple_captcha message: "の画像と文字が一致しません。", valid_and_not_remove: true

  scope :published, -> {
    where(state: 'public')
  }

  def public_columns
    Enquete::FormColumn.where(state: 'public')
                       .where(form_id: id)
                       .order(:sort_no)
  end

  def save_answer(values, client = {})
    ans = Enquete::Answer.new(form_id: id,
                              content_id: content_id,
                              state: 'enabled',
                              ipaddr: client[:ipaddr],
                              user_agent: client[:user_agent])
    return false unless ans.save

    columns.each do |col|
      value = values[col.element_name]
      next if value.blank?
      case col.column_type
      when 'attachment'
        if value[:name].present?
          acol = Enquete::AnswerColumn.new(answer_id: ans.id,
            form_id: id,
            column_id: col.id,
            value: value[:name])
          if value[:data].present?
            at = acol.build_attachment(site_id: self.content.site_id)
            at.name = at.sanitize_filename(value[:name])
            at.title = value[:name]
            at.use_resize(false)
            at.file = Sys::Lib::File::NoUploadedFile.new(nil, data: Base64.strict_decode64(value[:data]), filename: at.name)
          end
          acol.save
        end
      else
        acol = Enquete::AnswerColumn.new(answer_id: ans.id,
                                         form_id: id,
                                         column_id: col.id,
                                         value: value)
        acol.save
      end
    end
    ans
  end
end
