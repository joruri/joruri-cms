# encoding: utf-8
class Cms::FeedEntry < ActiveRecord::Base
  include Sys::Model::Base
  include Cms::Model::Base::Page
  include Sys::Model::Auth::Free

  belongs_to :status,         :foreign_key => :state,             :class_name => 'Sys::Base::Status'
  belongs_to :feed,           :foreign_key => :feed_id,           :class_name => 'Cms::Feed'
  
  validates_presence_of :link_alternate, :title
  
  def public
    self.and "#{self.class.table_name}.state", 'public'
    self.join "INNER JOIN `cms_feeds` ON `cms_feeds`.id = `cms_feed_entries`.feed_id"
    self.and "#{Cms::Feed.table_name}.state", 'public'
    self
  end

  def search(params)
    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_id'
        self.and "#{Cms::FeedEntry.table_name}.id", v
      when 's_title'
        self.and_keywords v, :title
      when 's_keyword'
        self.and_keywords v, :title, :summary
      end
    end if params.size != 0

    return self
  end

  def event_date_in(sdate, edate)
    self.and Condition.new do |c|
      c.or Condition.new do |c2|
        c2.and :event_date, "<", edate.to_s
        c2.and :event_close_date, ">=", sdate.to_s
      end
      c.or Condition.new do |c2|
        c2.and :event_close_date, "IS", nil
        c2.and :event_date, ">=", sdate.to_s
        c2.and :event_date, "<", edate.to_s
      end
    end
    self
  end

  def event_date_is(options = {})
    if options[:year] && options[:month]
      sd = Date.new(options[:year], options[:month], 1)
      ed = sd >> 1
      self.and :event_date, 'IS NOT', nil
      self.and :event_date, '>=', sd
      self.and :event_date, '<' , ed
    end
  end

  def public_uri
    return nil unless self.link_alternate
    self.link_alternate
  end

  def public_full_uri
    return nil unless self.link_alternate
    self.link_alternate
  end

  def agent_filter(agent)
    self
  end
  
  def category_is(cate)
    return self if cate.blank?
    cate = [cate] unless cate.class == Array
    cate.each do |c|
      if c.level_no == 1
        cate += c.public_children
      end
    end
    cate = cate.uniq

    cond = Condition.new
    added = false
    cate.each do |c|
      if c.entry_categories
        arr = c.entry_categories.split(/\r\n|\r|\n/)
        arr.each do |label|
          label = label.gsub(/\/$/, '')
          cond.or :categories, 'REGEXP', "(^|\n)#{label}"
          added = true
        end
      end
    end
    cond.and '1', '=', '0' unless added
    self.and cond
  end

  def group_is(group)
    return self unless group
    conditions = []
#    if group.category.size > 0
#      entry = self.class.new
#      entry.category_is(group.category_items)
#      conditions << entry.condition
#    end
    entry = self.class.new
    entry.category_is(group)
    conditions << entry.condition
    
    condition = Condition.new
    conditions.each {|c| condition.or(c) if c.where }
    
    self.and condition if conditions.size > 0
    self
  end

end