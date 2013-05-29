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
    
    table = options.has_key?(:table_name) ? options[:table_name] + '.' : ''
    order = "CASE #{table}concept_id"
    concepts.each_with_index {|c, i| order << " WHEN #{c.id} THEN #{i}"}
    order << ' ELSE 100 END, id'
  end
  
  def self.find_design_pieces(html, concepts, params)
    names = []
    #html.scan(/\[\[piece\/([0-9a-zA-Z\._-]+)\]\]/) {|name| names << name[0]}
    html.scan(/\[\[piece\/([^\]]+)\]\]/) {|name| names << name[0]}
    
    items = {}
    names.uniq.each do |name|
      item = Cms::Piece.new
      item.and :state, 'public'
      if name =~ /#[0-9]+$/ ## [[piece/name#id]]
        item.and :id, name.gsub(/.*#/, '')
        item.and :name, name.gsub(/#.*/, '')
      else ## [[piece/name]]
        item.and :name, name
        cond = Condition.new do |c|
          c.or :concept_id, 'IS', nil
          c.or :concept_id, 'IN', concepts
        end
        item.and cond
      end
      items[name] = item if item = item.find(:first, :order => concepts_order(concepts))
    end
    
    if Core.mode == "preview" && params[:piece_id]
      item = Cms::Piece.find_by_id(params[:piece_id])
      items[item.name] = item if item
    end
    
    return items
  end
  
  def self.find_data_texts(html, concepts)
    names = []
    html.scan(/\[\[text\/([0-9a-zA-Z\._-]+)\]\]/) {|name| names << name[0]}
    
    items = {}
    names.uniq.each do |name|
      item = Cms::DataText.new
      item.and :state, 'public'
      item.and :name, name
      cond = Condition.new do |c|
        c.or :concept_id, 'IS', nil
        c.or :concept_id, 'IN', concepts
      end
      item.and cond
      items[name] = item if item = item.find(:first, :order => concepts_order(concepts))
    end
    return items
  end
  
  def self.find_data_files(html, concepts)
    names = []
    html.scan(/\[\[file\/([^\]]+)\]\]/) {|name| names << name[0]}
    
    items = {}
    names.uniq.each do |name|
      dirname  = ::File.dirname(name)
      basename = dirname == '.' ? name : ::File.basename(name)
      
      tab  = Cms::DataFile.table_name
      item = Cms::DataFile.new.public
      item.and "#{tab}.name", basename
      cond = Condition.new do |c|
        c.or "#{tab}.concept_id", 'IS', nil
        c.or "#{tab}.concept_id", 'IN', concepts
      end
      item.and cond
      
      if dirname == '.'
        item.and "#{tab}.node_id", "IS", nil
      else
        node_tab = Cms::DataFileNode.table_name
        item.join "LEFT OUTER JOIN #{node_tab} ON #{node_tab}.id = #{Cms::DataFile.table_name}.node_id"
        item.and "#{node_tab}.name", dirname
      end
      
      items[name] = item if item = item.find(:first, :order => concepts_order(concepts, :table_name => tab))
    end
    return items
  end
end