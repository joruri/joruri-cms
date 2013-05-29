# encoding: utf-8
class Sys::Base::Status < ActiveRecord::Base
  class Value
    def initialize(id)
      @id = id
    end
    
    def name
      case @id
      when 'enabled'; return '有効'
      when 'disabled'; return '無効'
      when 'visible'; return '表示'
      when 'hidden'; return '非表示'
      when 'draft'; return '下書き'
      when 'recognize'; return '承認待ち'
      when 'recognized'; return '公開待ち'
      when 'prepared'; return '公開'
      when 'public'; return '公開中'
      when 'closed'; return '非公開'
      when 'completed'; return '完了'
      end
      nil
    end
  end
  
  def self.columns_hash
    column_defaults
  end
  
  def self.column_defaults
    cols = {}
    cols["id"] = ActiveRecord::ConnectionAdapters::Column.new("id", nil)
    cols["name"] = ActiveRecord::ConnectionAdapters::Column.new("name", nil)
    cols
  end
  
  def self.columns
    column_defaults.collect{|k, v| v }
  end
  
  def self.find_by_sql(*args)
    id = args[0].where_sql.to_s.gsub(/.*'(.*?)'$/, '\\1')
    [ Value.new(id) ]
  end
  
  def to_xml(options = {})
    options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])

    _root = options[:root] || 'status'

    xml = options[:builder]
    xml.tag!(_root) { |n|
      n.id key.to_s
      n.name name.to_s
    }
  end
end