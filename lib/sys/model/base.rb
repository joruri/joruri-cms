# encoding: utf-8
module Sys::Model::Base
  extend ActiveSupport::Concern
  include Sys::Model::Scope

  included do
    self.table_name = to_s.underscore.tr('/', '_').downcase.pluralize
  end

  def locale(name)
    label = I18n.t name, scope: [:activerecord, :attributes, self.class.to_s.underscore]
    label =~ /^translation missing:/ ? name.to_s.humanize : label
  end

  def error_locale(name)
    label = I18n.t name, scope: [:errors, :messages]
    label =~ /^translation missing:/ ? name.to_s.humanize : label
  end

  def expand_join_query(joins)
    join_dependency = ActiveRecord::Associations::ClassMethods::InnerJoinDependency.new(self.class, joins, nil)
    " #{join_dependency.join_associations.collect(&:association_join).join} "
  end

  def save_with_direct_sql # TODO
    quote = proc { |v| self.class.connection.quote(v) }

    table = self.class.table_name
    sql = "INSERT INTO #{table} ("
    sql += self.class.column_names.sort.join(',')
    sql += ') VALUES ('

    self.class.column_names.sort.each_with_index do |name, i|
      sql += ',' if i != 0
      value = send(name)
      sql += if value.nil?
               'NULL'
             elsif value.class == Time
               "'#{value.strftime('%Y-%m-%d %H:%M:%S')}'"
             else
               quote.call(value)
             end
    end

    sql += ')'

    self.class.connection.execute(sql)
    rs = self.class.connection.execute("SELECT LAST_INSERT_ID() AS id FROM #{table}")
    rs.first
  end
end
