module Sys::Model::Scope
  extend ActiveSupport::Concern

  included do
    scope :search_with_text, ->(*args) {
      words = args.pop.to_s.split(/[ 　]+/)
      columns = args
      where(words.map { |w| columns.map { |c| arel_table[c].matches("%#{escape_like(w)}%") }.reduce(:or) }.reduce(:and))
    }
  end

  module ClassMethods
    def escape_like(s)
      s.gsub(/[\\%_]/) { |r| "\\#{r}" }
    end

    def union(relations)
      sql = '((' + relations.map(&:to_sql).join(') UNION (') + ')) AS ' + table_name
      from(sql)
    end
  end
end
