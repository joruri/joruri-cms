# encoding: utf-8
class Sys::Base::Status < ActiveRecord::Base
  class Value
    attr_accessor :id

    def initialize(id)
      @id = id
    end

    def name
      case @id
      when 'enabled' then return '有効'
      when 'disabled' then return '無効'
      when 'visible' then return '表示'
      when 'hidden' then return '非表示'
      when 'draft' then return '下書き'
      when 'recognize' then return '承認待ち'
      when 'recognized' then return '公開待ち'
      when 'prepared' then return '公開'
      when 'public' then return '公開中'
      when 'closed' then return '非公開'
      when 'completed' then return '完了'
      end
      nil
    end
  end

  def self.columns_hash
    column_defaults
  end

  def self.column_defaults
    cols = {}
    cols['id'] = ActiveRecord::ConnectionAdapters::Column.new('id', nil)
    cols['name'] = ActiveRecord::ConnectionAdapters::Column.new('name', nil)
    cols
  end

  def self.columns
    column_defaults.collect { |_k, v| v }
  end

  def self.find_by_sql(*args)
    id = args[0].where_sql.to_s.gsub(/.*'(.*?)'$/, '\\1')
    [Value.new(id)]
  end

  def to_xml(options = {})
    options[:builder] ||= Builder::XmlMarkup.new(indent: options[:indent])

    _root = options[:root] || 'status'

    xml = options[:builder]
    xml.tag!(_root) do |n|
      n.id key.to_s
      n.name name.to_s
    end
  end
end
