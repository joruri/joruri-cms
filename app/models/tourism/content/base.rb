# encoding: utf-8
class Tourism::Content::Base < Cms::Content
  has_many :dependent_spots, :foreign_key => :content_id, :class_name => 'Tourism::Spot',
    :dependent => :destroy
  has_many :dependent_genres, :foreign_key => :content_id, :class_name => 'Tourism::Genre',
    :dependent => :destroy
  has_many :dependent_areas, :foreign_key => :content_id, :class_name => 'Tourism::Area',
    :dependent => :destroy
end