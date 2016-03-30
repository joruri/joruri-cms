# encoding: utf-8
module Sys::Model::Rel::Recognition
  extend ActiveSupport::Concern

  included do
    belongs_to :recognition, foreign_key: 'unid', class_name: 'Sys::Recognition',
                             dependent: :destroy

    after_save :save_recognition

    scope :recognizable, -> {
      rel = joins(:creator, :recognition)

      creators = Sys::Creator.arel_table
      recognitions = Sys::Recognition.arel_table

      rel = rel.where(recognitions[:user_id].eq(Core.user.id)
        .or(recognitions[:recognizer_ids].matches("#{Core.user.id} %")
          .or(recognitions[:recognizer_ids].matches("% #{Core.user.id} %")
            .or(recognitions[:recognizer_ids].matches("% #{Core.user.id}"))
             )
           )
                     )

      rel.where(state: 'recognize')
    }

    scope :recognizable_with_admin, -> {
      rel = joins(:creator, :recognition)

      creators = Sys::Creator.arel_table
      recognitions = Sys::Recognition.arel_table

      rel = rel.where(recognitions[:user_id].eq(Core.user.id)
        .or(recognitions[:recognizer_ids].matches("#{Core.user.id} %")
          .or(recognitions[:recognizer_ids].matches("% #{Core.user.id} %")
            .or(recognitions[:recognizer_ids].matches("% #{Core.user.id}")
              .or(recognitions[:info_xml].matches('%<admin/>%'))
               )
             )
           )
                     )

      rel.where(state: 'recognize')
    }
  end

  def in_recognizer_ids
    @in_recognizer_ids = recognizer_ids.to_s unless @in_recognizer_ids
    @in_recognizer_ids
  end

  def in_recognizer_ids=(ids)
    @_in_recognizer_ids_changed = true
    @in_recognizer_ids = ids.to_s
  end

  def recognizer_ids
    recognition ? recognition.recognizer_ids : ''
  end

  def recognizers
    recognition ? recognition.recognizers : []
  end

  def recognized?
    state == 'recognized'
  end

  def recognizable?(user = nil)
    return false unless state == 'recognize'
    return false unless recognition
    return false unless editable?
    recognition.recognizable?(user)
  end

  def recognize(user)
    return false unless recognition
    rs = recognition.recognize(user)

    if state == 'recognize' && recognition.recognized_all?
      sql = "UPDATE #{self.class.table_name} SET state = 'recognized', recognized_at = '#{Core.now}' WHERE id = #{id}"
      self.state = 'recognized'
      self.recognized_at = Core.now
      self.class.connection.execute(sql)
    end
    rs
  end

  private

  def validate_recognizers
    errors["承認者"] = "を入力してください。" if in_recognizer_ids.blank?
  end

  def save_recognition
    return true unless @_in_recognizer_ids_changed
    return false unless unid
    return false if @sent_save_recognition
    @sent_save_recognition = true

    unless (rec = recognition)
      rec = Sys::Recognition.new
      rec.id = unid
    end

    rec.user_id        = Core.user.id
    rec.recognizer_ids = in_recognizer_ids.strip
    rec.info_xml       = nil
    rec.save

    rec.reset_info

    update_attribute(:recognized_at, nil)

    true
  end
end
