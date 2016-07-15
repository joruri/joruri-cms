# encoding: utf-8
module Cms::Lib::Layout
  def self.current_concept
    concept = defined?(Page.current_item.concept) ? Page.current_item.concept : nil
    concept ||= Page.current_node.inherited_concept
  end

  def self.inhertited_concepts
    return [] unless current_concept
    current_concept.parents_tree.reverse
  end

  def self.inhertited_layout
    layout = defined?(Page.current_item.layout) ? Page.current_item.layout : nil
    layout ||= Page.current_node.inherited_layout
  end

  def self.concepts_order(concepts, options = {})
    return 'concept_id' if concepts.blank?

    table = options.key?(:table_name) ? options[:table_name] + '.' : ''
    order = "CASE #{table}concept_id"
    concepts.each_with_index { |c, i| order << " WHEN #{c.id} THEN #{i}" }
    order << ' ELSE 100 END, id'
  end

  def self.find_design_pieces(html, concepts, params)
    names = []
    # html.scan(/\[\[piece\/([0-9a-zA-Z\._-]+)\]\]/) {|name| names << name[0]}
    html.scan(/\[\[piece\/([^\]]+)\]\]/) { |name| names << name[0] }

    items = {}
    arel_table = Cms::Piece.arel_table

    names.uniq.each do |name|
      item = Cms::Piece.where(state: 'public')

      if name =~ /#[0-9]+$/ ## [[piece/name#id]]
        item = item.where(id: name.gsub(/.*#/, ''))
                   .where(name: name.gsub(/#.*/, ''))
      else ## [[piece/name]]
        item = item.where(name: name)
                   .where(arel_table[:concept_id].eq(nil)
                          .or(arel_table[:concept_id].in(concepts)))
      end

      item = item.order(concepts_order(concepts)).first

      items[name] = item if item
    end

    if Core.mode == 'preview' && params[:piece_id]
      item = Cms::Piece.find_by(id: params[:piece_id])
      items[item.name] = item if item
    end

    items
  end

  def self.find_data_texts(html, concepts)
    names = []
    html.scan(/\[\[text\/([0-9a-zA-Z\._-]+)\]\]/) { |name| names << name[0] }

    items = {}
    arel_table = Cms::DataText.arel_table

    names.uniq.each do |name|
      item = Cms::DataText
             .where(state: 'public')
             .where(name: name)
             .where(arel_table[:concept_id].eq(nil)
                    .or(arel_table[:concept_id].in(concepts)))

      item = item.order(concepts_order(concepts)).first

      items[name] = item if item
    end
    items
  end

  def self.find_data_files(html, concepts)
    names = []
    html.scan(/\[\[file\/([^\]]+)\]\]/) { |name| names << name[0] }

    items = {}
    names.uniq.each do |name|
      dirname  = ::File.dirname(name)
      basename = dirname == '.' ? name : ::File.basename(name)

      arel_table = Cms::DataFile.arel_table

      item = Cms::DataFile
             .published
             .where(arel_table[:name].eq(basename))
             .where(arel_table[:concept_id].eq(nil)
                    .or(arel_table[:concept_id].in(concepts)))

      if dirname == '.'
        item = item.where(arel_table[:node_id].eq(nil))
      else
        arel_node = Cms::DataFileNode.arel_table
        item = item.joins(:node)
                   .where(arel_node[:name].eq(dirname))
      end

      tab  = Cms::DataFile.table_name
      item = item.order(concepts_order(concepts, table_name: tab)).first

      items[name] = item if item
    end
    items
  end
end
