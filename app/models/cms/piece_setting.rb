# encoding: utf-8
class Cms::PieceSetting < ActiveRecord::Base
  include Sys::Model::Base

  belongs_to :piece, :foreign_key => :piece_id, :class_name => 'Cms::Piece'

  validates_presence_of :piece_id, :name
end
