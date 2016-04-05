# encoding: utf-8
class Bbs::Item < ActiveRecord::Base
  include Sys::Model::Base
  include Cms::Model::Base::Page
  include Sys::Model::Auth::Free

  include StateText

  attr_accessor :block_uri, :block_word, :block_ipaddr

  has_many :responses, ->{ where.not(parent_id: 0).order(:id) },
           foreign_key: :parent_id, class_name: 'Bbs::Item',
           dependent: :destroy
  has_many :all_responses, ->{ where.not(parent_id: 0).order(:id) },
           foreign_key: :thread_id, class_name: 'Bbs::Item'

  validates :name, :title, :body, presence: true
  validates :email, format: { with: /\A^(([A-Za-z0-9]+_+)|([A-Za-z0-9]+-+)|([A-Za-z0-9]+.+)|([A-Za-z0-9]+\++))*[A-Za-z0-9]+@((\w+-+)|(\w+.))*\w{1,63}.[a-zA-Z]{2,6}\z/ix,
                              if: %(!email.blank?)  }
  validates :name, :title, :uri, :email,
            length: { maximum: 50 }, allow_nil: true
  validates :body, length: { maximum: 100_000 }, allow_nil: true
  validates :body, format: { with: /\A((?!(http|https):\/\/).)*\z/i ,
                             if: %(block_uri),
                             message: "にURLを含めることはできません。" }
  validate :validate_block_word
  validate :validate_block_ipaddr

  apply_simple_captcha message: "の画像と文字が一致しません。"

  after_save :save_thread_id, if: %(parent_id == 0 && thread_id.nil?)

  scope :published, -> {
    where(state: 'public')
  }

  scope :search, -> (params) {
    rel = all

    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_id'
        rel = rel.where(id: v)
      when 's_keyword'
        rel = rel.where(arel_table[:name].matches("%#{v}%")
                        .or(arel_table[:title].matches("%#{v}%"))
                        .or(arel_table[:body].matches("%#{v}%"))
                        .or(arel_table[:email].matches("%#{v}%"))
                        .or(arel_table[:uri].matches("%#{v}%")))
      end
    end if params.size != 0

    rel
  }


  def public_uri
  end

  protected

  def validate_block_word
    block_word.to_s.split(/(\r\n|\n|\t| |　)+/).uniq.each do |w|
      next if w.strip.blank?
      if body.index(w)
        errors.add :body, "に禁止されている語句が含まれています。"
        return false
      end
    end
    true
  end

  def validate_block_ipaddr
    block_ipaddr.to_s.split(/(\r\n|\n|\t| |　)+/).uniq.each do |w|
      next if w.strip.blank?
      reg = Regexp.new('^' + Regexp.quote(w).gsub('\\*', '[0-9]+') + '$')
      if ipaddr =~ reg
        errors.add :base, "ご利用の環境からの投稿は禁止されています。"
        return false
      end
    end
    true
  end

  def save_thread_id
    self.thread_id = id
    save(validate: false)
  end
end
