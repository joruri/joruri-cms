module Article::DocsCommon
  extend ActiveSupport::Concern

  included do
  end

  def publish_related_pages(item)
    Delayed::Job.where(queue: 'publish_top_page').destroy_all
    if (root_node = item.content.site.root_node) &&
       (top_page = root_node.children.where(name: 'index.html').first)
      ::Script.delay(queue: 'publish_top_page', priority: 10)
              .run("cms/nodes#publish?target_module=cms&target_node_id=#{top_page.id}")
    end

    category_ids = if (@old_category_ids.kind_of?(Array) && @new_category_ids.kind_of?(Array))
                     @old_category_ids | @new_category_ids
                   else
                     item.category_items.inject([]){|result, item|
                       result | item.ancestors.map(&:id)
                     }
                   end
    attribute_ids = if (@old_attribute_ids.kind_of?(Array) && @new_attribute_ids.kind_of?(Array))
                     @old_attribute_ids | @new_attribute_ids
                   else
                     item.attribute_items.map(&:id)
                   end
    area_ids = if (@old_area_ids.kind_of?(Array) && @new_area_ids.kind_of?(Array))
                 @old_area_ids | @new_area_ids
               else
                 item.area_items.inject([]){|result, item|
                   result | item.ancestors.map(&:id)
                 }
               end
    unit_ids = if (@old_unit_ids.kind_of?(Array) && @new_unit_ids.kind_of?(Array))
                 @old_unit_ids | @new_unit_ids
               else
                 unit_id = item.unit.try(:id)
                 unit_id ? [unit_id] : []
               end
    dependent_ids = unit_ids.map do |id|
                      unit = Article::Unit.find_by_id(id)
                      unit_id = nil
                      if unit.level_no > 2
                        unit.ancestors.each do |u|
                          unit_id = u.id if u.level_no == 2
                        end
                      elsif unit.level_no == 2
                        unit_id = unit.id
                      end
                      unit_id
                    end

    # category
    Delayed::Job.where(queue: 'publish_category_pages').destroy_all
    Article::Publisher.register_items(item.content_id, category_ids, 'Article::Category', dependent_ids)
    Article::Publisher.delay(queue: 'publish_category_pages', priority: 100).publish_items('Article::Category')
    
    # attributes
    Delayed::Job.where(queue: 'publish_attribute_pages').destroy_all
    Article::Publisher.register_items(item.content_id, attribute_ids, 'Article::Attribute', dependent_ids)
    Article::Publisher.delay(queue: 'publish_attribute_pages', priority: 100).publish_items('Article::Attribute')

    # area
    Delayed::Job.where(queue: 'publish_area_pages').destroy_all
    Article::Publisher.register_items(item.content_id, area_ids, 'Article::Area', attribute_ids)
    Article::Publisher.delay(queue: 'publish_area_pages', priority: 100).publish_items('Article::Area')

    # units
    Delayed::Job.where(queue: 'publish_unit_pages').destroy_all
    Article::Publisher.register_items(item.content_id, unit_ids, 'Article::Unit', attribute_ids)
    Article::Publisher.delay(queue: 'publish_unit_pages', priority: 100).publish_items('Article::Unit')
  end
end
