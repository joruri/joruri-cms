# encoding: utf-8
class Sys::Sequence < ActiveRecord::Base
  self.table_name = 'sys_sequences'

  scope :versioned, ->(v) {
    where(version: v.to_s)
  }
end
