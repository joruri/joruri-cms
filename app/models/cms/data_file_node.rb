# encoding: utf-8
class Cms::DataFileNode < ActiveRecord::Base
  include Sys::Model::Base
  include Cms::Model::Base::Page
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Cms::Model::Rel::Site
  include Cms::Model::Rel::Concept
  include Cms::Model::Auth::Concept

  has_many :files, foreign_key: :node_id, class_name: 'Cms::DataFile', primary_key: :id

  validates_presence_of :concept_id, :name
  validates_uniqueness_of :name, scope: :concept_id
  validate :validate_name

  after_destroy :remove_files

  scope :search, -> (params) {
    rel = all

    file_nodes = arel_table

    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_keyword'
        rel = rel.where(file_nodes[:title].matches("%#{v}%")
          .or(file_nodes[:name].matches("%#{v}%"))
                       )
      end
    end if params.size != 0

    rel
  }

  def label(separator = ' : ')
    label = name
    label += "#{separator}#{title}" unless title.blank?
    label
  end

  def validate_name
    unless name.blank?
      errors.add :name, "は半角英数字を入力してください。" if name !~ /^[0-9a-zA-Z_\-]+$/
    end
  end

  private

  def remove_files
    files.each(&:destroy)
    true
  end
end
