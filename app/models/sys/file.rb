# encoding: utf-8
class Sys::File < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Base::File
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator

  attr_accessor :in_resize_size, :in_thumbnail_size

  ## garbage collect
  def self.garbage_collect
    where.not(tmp_id: nil)
         .where(parent_unid: nil)
         .where(arel_table[:created_at].lt(
                  Date.strptime(Core.now, '%Y-%m-%d') - 2))
         .destroy_all
  end

  ## Remove the temporary flag.
  def self.fix_tmp_files(tmp_id, parent_unid)
    where(parent_unid: nil, tmp_id: tmp_id)
      .update_all(parent_unid: parent_unid, tmp_id: nil)
  end

  def duplicated?
    files = self.class.where(name: name)

    files = files.where.not(id: id) if id

    files = if tmp_id
              files.where(tmp_id: tmp_id).where(parent_unid: nil)
            else
              files.where(tmp_id: nil).where(parent_unid: parent_unid)
            end

    files.first
  end
end
