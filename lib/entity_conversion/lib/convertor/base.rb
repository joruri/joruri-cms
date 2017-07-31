# encoding: utf-8
class EntityConversion::Lib::Convertor::Base
  def initialize(options)
    @content   = options[:content]
    @env       = options[:env]
    @state     = nil
    @logs      = []
    @new_codes = {}
    @end_ids   = {}
    @changed   = []
    @ended     = []
  end

  def convert_new(unit); end

  def convert_edit(unit, group); end

  def convert_move(unit, group); end

  def convert_end(unit, group); end

  def replace_group_id_save(item, fields, old_id, new_id); end

  def replace_texts_save(item, fields, texts); end

  attr_reader :logs

  def convert
    @logs << (@env == :test ? "テスト実行\n==========" : "本実行\n======")

    @new_units = EntityConversion::Unit
                 .where(content_id: @content.id)
                 .where(state: 'new')
                 .order(:sort_no)

    @edit_units = EntityConversion::Unit
                  .where(content_id: @content.id)
                  .where(state: 'edit')
                  .order(:sort_no)

    @move_units = EntityConversion::Unit
                  .where(content_id: @content.id)
                  .where(state: 'move')
                  .order(:sort_no)

    @end_units = EntityConversion::Unit
                 .where(content_id: @content.id)
                 .where(state: 'end')
                 .order(:old_parent_id, :old_id)

    @logs << "\n# 新設"
    @logs << '' unless @new_units.empty?

    @new_units.each do |unit|
      @logs << "- #{unit.name} ##{unit.id}"
      convert_new(unit)
    end

    @logs << "\n# 変更"
    @logs << '' unless @edit_units.empty?

    @edit_units.each do |unit|
      group = unit.old
      raise "group is not exists ##{unit.id}" unless group

      clone = group.clone
      texts = unit.replace_texts

      @logs << "- #{group.name} > #{unit.name} ##{unit.id}"
      convert_edit(unit, group)
      replace_texts(texts)
      @changed << [group, clone]
    end

    @logs << "\n# 統合"
    @logs << '' unless @move_units.empty?

    @move_units.each do |unit|
      group = unit.old
      raise "group is not exists ##{unit.id}" unless group

      clone = group.clone
      texts = unit.replace_texts
      move  = unit.move || unit.new_move

      @logs << "- #{group.name} > #{move.name} ##{unit.id}"
      replace_group_id(unit, clone)
      replace_texts(texts)
      convert_move(unit, group)
      @changed << [Sys::Group.uncached { Sys::Group.find_by(code: unit.code) }, clone]
    end

    @logs << "\n# 廃止"
    @logs << '' unless @end_units.empty?

    @end_units.each do |unit|
      group = unit.old
      raise "group is not exists ##{unit.id}" unless group

      clone = group.clone

      @logs << "- #{group.name} ##{unit.id}"
      convert_end(unit, group)
      @ended << clone
    end

    @state = 'success'
    @logs << "\n* 正常終了"

  rescue StandardError => e
    @state = 'error'
    @logs << "\n* エラー\n- #{e}"

  ensure
    cond  = { content_id: @content.id, env: @env.to_s }
    log   = EntityConversion::Log.find_by(cond)
    log ||= EntityConversion::Log.new(cond)
    log.state = @state
    log.body  = @logs.join("\n")
    log.save

    # @changed.size
    # @ended.size
  end

  def replace_group_id(unit, group)
    @logs << '  replace_group_id:'

    new_id = nil
    if unit.move
      new_id = unit.move.id
    elsif unit.new_move
      move = Sys::Group.uncached { Sys::Group.find_by(code: unit.new_move.code) }
      new_id = begin
                 move.id
               rescue
                 nil
               end
    end

    return if group.id == new_id # no change

    target_fields(:group_id).each do |cls, fields|
      records = 0
      
      conds = []
      fields.each do |f|
        conds << Arel.sql("`#{cls.table_name}`.`#{f}` REGEXP '(^| )#{group.id}( |$)'")
      end
      items = cls.uncached { cls.where(conds.join(' or ')) }

      next if items.empty?
      records += items.size
      if new_id
        items.each { |item| replace_group_id_save(item, fields, group.id, new_id) }
      end
      @logs << "    #{cls.table_name}: #{records} records"
    end
  end

  def replace_texts(texts)
    @logs << '  replace_texts:'

    return if texts.empty? # no change

    target_fields(:text).each do |cls, fields|
      records = 0

      conds = []
      fields.each do |f|
        texts.each do |src, _dst|
          conds << Arel.sql("`#{cls.table_name}`.`#{f}` REGEXP '#{Regexp.escape(src)}'")
        end
      end
      items = cls.uncached { cls.where(conds.join(' or ')) }

      next if items.empty?
      records += items.size
      items.each { |item| replace_texts_save(item, fields, texts) }
      @logs << "    #{cls.table_name}: #{records} records"
    end
  end

  def target_fields(key)
    return @fields[key] if @fields && @fields[key]

    @fields = { group_id: {}, text: {} }

    Dir.entries("#{Rails.root}/config/modules").each do |mod|
      next if mod =~ /^\./
      ext = begin
              eval("::#{mod.to_s.camelize}::Lib::EntityConversion")
            rescue
              nil
            end
      next unless ext

      base = EntityConversion::Lib::EntityConversion::Base.new
      base.extend ext

      fields = base.group_id_fields
      @fields[:group_id].merge!(fields) if fields.is_a?(Hash)

      fields = base.text_fields
      @fields[:text].merge!(fields) if fields.is_a?(Hash)
    end

    @fields[:text].each do |cls, val|
      next unless val == true
      cols = []
      cls.columns.each do |c|
        next if c.type.to_s !~ /(text|string)/
        next if c.name.to_s =~ /(state|id|ids)$/
        cols << c.name
      end
      @fields[:text][cls] = cols
    end

    @fields[key]
  end
end
