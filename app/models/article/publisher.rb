class Article::Publisher < ActiveRecord::Base
  include Sys::Model::Base

  def item
    case item_model
    when 'Article::Category'
      return Article::Category.find_by_id(item_id)
    when 'Article::Attribute'
      return Article::Attribute.find_by_id(item_id)
    when 'Article::Area'
      return Article::Area.find_by_id(item_id)
    when 'Article::Unit'
      return Article::Unit.find_by_id(item_id)
    end
    return nil
  end
  
  def self.register_item(content_id, item, item_model, lower_layer_item_ids = nil)
    item_id = if item.kind_of?(Article::Category) || item.kind_of?(Article::Attribute) ||
                 item.kind_of?(Article::Area)
                item.id
              else
                item.to_i
              end
    if item_id > 0
      publisher = self.where(content_id: content_id, item_model: item_model, item_id: item_id).first
      
      if publisher
        ids = if !lower_layer_item_ids.blank?
                publisher.lower_layer_item_ids.to_s.split(' ').uniq | lower_layer_item_ids
              else
                lower_layer_item_ids
              end
        ids = ids.map{|i| i.to_i }.uniq
        publisher.lower_layer_item_ids = ids.join(' ')
        publisher.save! if publisher.changed?
      else
        self.create(content_id: content_id,
                    item_model: item_model,
                    item_id: item_id,
                    lower_layer_item_ids: lower_layer_item_ids.join(' '))

      end
    end
  end

  def self.register_items(content_id, items, item_model, lower_layer_item_ids = nil)
    items.each{|i| self.register_item(content_id, i, item_model, lower_layer_item_ids) }
  end
  
  def self.publish_items(item_model)
    item_ids = {}
    self.where(item_model: item_model).all.each do |publisher|
      unless (i = publisher.item)
        publisher.destroy
        next
      end
      item_ids[publisher.content_id] ||= {}
      item_ids[publisher.content_id][i.id] = publisher.lower_layer_item_ids.to_s.split(' ').uniq
    end
    
    item_ids.each do |key, value|
      value.each do |k, v|
        content = Article::Content::Doc.find_by_id(key)
        
        case item_model
        when 'Article::Category'
          target_node = content.category_node
        when 'Article::Attribute'
          target_node = content.attribute_node
        when 'Article::Area'
          target_node = content.area_node
        when 'Article::Unit'
          target_node = content.unit_node
        end
        
        next if target_node.blank?
        ids = v.map{|vv| "target_child_id[]=#{vv}" }.join('&')
        script_params = "target_module=article&target_node_id=#{target_node.id}&target_content_id[]=#{key}&target_id[]=#{k}&#{ids}"
        self.where(item_model: item_model, item_id: k).destroy_all
        ::Script.run("cms/nodes/publish?all=all&#{script_params}")
      end
    end
  end
end
