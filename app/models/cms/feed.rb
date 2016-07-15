# encoding: utf-8
class Cms::Feed < ActiveRecord::Base
  include Sys::Model::Base
  include Cms::Model::Base::Page
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Cms::Model::Rel::Content
  include Cms::Model::Auth::Concept

  include StateText

  has_many :entries, foreign_key: :feed_id,
                     class_name: 'Cms::FeedEntry',
                     dependent: :destroy

  validates :name, :title, :uri, presence: true

  def safe(alt = nil)
    yield
  rescue NoMethodError => e
    if e.respond_to?(:args) && (e.args.nil? || (!e.args.blank? && e.args.first.nil?))
      alt
    end
  end

  def request_feed
    res = Util::Http::Request.get(uri)
    if res.status != 200
      errors.add :base, "RequestError: #{uri}"
      return nil
    end
    res.body
  end

  def update_feed(options = {})
    unless xml = request_feed
      errors.add :base, "FeedRequestError: #{uri}"
      return false
    end

    entries.destroy_all if options[:destroy] == true

    require 'rexml/document'
    doc  = REXML::Document.new(xml)
    root = doc.root
    if root.name.downcase =~ /^(rss|rdf)$/
      return update_feed_rss(root)
    else
      return update_feed_atom(root)
    end

  rescue => e
    errors.add :base, "Error: #{e.class}"
    return false
  end

  def update_feed_rss(root)
    latest = []

    channel = root.elements['channel']
    self.feed_id        = nil
    self.feed_type      = root.name.downcase
    self.feed_updated   = Core.now
    self.feed_title     = channel.elements['title'].text
    self.link_alternate = channel.elements['link'].text
    self.entry_count ||= 20
    save

    ## entries
    begin
      path = root.elements['item'] ? 'item' : 'channel/item'
      root.elements.each(path) do |e|
        entry_id      = e.elements['link'].text
        entry_updated = (e.elements['pubDate'] || e.elements['dc:date']).text

        entry = Cms::FeedEntry.find_by(feed_id: id, entry_id: entry_id)
        if entry
          arr = Date._parse(entry_updated, false).values_at(:year, :mon, :mday, :hour, :min, :sec, :zone, :wday)

          newt = Time.local(*arr[0..-3]).strftime('%s').to_i
          oldt = entry.entry_updated.strftime('%s').to_i
          if newt <= oldt
            latest << entry.id
            next
          end
        else
          entry = Cms::FeedEntry.new
        end

        ## base
        entry.content_id       = content_id
        entry.feed_id          = id
        entry.state          ||= 'public'
        entry.entry_id         = entry_id
        entry.entry_updated    = entry_updated
        entry.title            = safe { e.elements['title'].texts.join }
        entry.summary          = safe { e.elements['description'].texts.join }
        entry.link_alternate   = e.elements['link'].text

        ## category xml
        if fixed_categories_xml.blank?
          cates = []
          e.each_element('category') { |c| cates << c.to_s }
          entry.categories_xml = cates.join("\n")
        else
          entry.categories_xml = fixed_categories_xml
        end

        ## category
        set_entry_category(entry)

        ## save
        latest << entry.id if entry.save
      end
    rescue StandardError => e
      errors.add :base, "FeedEntryError: #{e}"
    end

    if latest.size > 0
      Cms::FeedEntry.where.not(id: latest)
                    .where(feed_id: id)
                    .destroy_all
    end
    errors.empty?
  end

  def update_feed_atom(root)
    latest = []

    ## feed
    self.feed_id      = root.elements['id'].text
    self.feed_type    = 'atom'
    self.feed_updated = root.elements['updated'].text
    self.feed_title   = root.elements['title'].text
    root.each_element('link') do |l|
      self.link_alternate = l.attribute('href').to_s if l.attribute('rel').to_s == 'alternate'
    end
    self.entry_count ||= 20
    save

    ## entries
    begin
      root.get_elements('entry').each_with_index do |e, i|
        break if i >= self.entry_count

        entry_id      = e.elements['id'].text
        entry_updated = e.elements['updated'].text

        entry = Cms::FeedEntry.find_by(feed_id: id, entry_id: entry_id)
        if entry
          arr  = Date._parse(entry_updated, false).values_at(:year, :mon, :mday, :hour, :min, :sec, :zone, :wday)
          newt = Time.local(*arr[0..-3]).strftime('%s').to_i
          oldt = entry.entry_updated.strftime('%s').to_i
          if newt <= oldt
            latest << entry.id
            next
          end
        else
          entry = Cms::FeedEntry.new
        end

        ## base
        entry.content_id       = content_id
        entry.feed_id          = id
        entry.state          ||= 'public'
        entry.entry_id         = entry_id
        entry.entry_updated    = entry_updated
        entry.title            = safe { e.elements['title'].texts.join }
        entry.summary          = safe { e.elements['summary'].texts.join }

        ## links
        e.each_element('link') do |l|
          entry.link_alternate = l.attribute('href').to_s if l.attribute('rel').to_s == 'alternate'
          entry.link_enclosure = l.attribute('href').to_s if l.attribute('rel').to_s == 'enclosure'
        end

        ## category xml
        if fixed_categories_xml.blank?
          cates = []
          e.each_element('category') { |c| cates << c.to_s }
          entry.categories_xml = cates.join("\n")
        else
          entry.categories_xml = fixed_categories_xml
        end

        ## category
        set_entry_category(entry)

        ## author
        if author = e.elements['author']
          entry.author_name    = safe { author.elements['name'].text }
          entry.author_email   = safe { author.elements['email'].text }
          entry.author_uri     = safe { author.elements['uri'].text }
        end

        ## save
        latest << entry.id if entry.save
      end
    rescue StandardError => e
      errors.add :base, "FeedEntryError: #{e}"
    end

    if latest.size > 0
      Cms::FeedEntry.where.not(id: latest)
                    .where(feed_id: id)
                    .destroy_all
    end
    errors.empty?
  end

  def set_entry_category(entry)
    labels = []
    entry.categories_xml.to_s.scan(/<category [^>]*?label=['"](.*?)['"][^>]+>/) do |m|
      labels << m[0].to_s.tr(' ', '_')
    end
    entry.categories = labels.join("\n")

    entry.event_date = nil
    entry.categories_xml.to_s.scan(/<category [^>]*term=['"]event['"].*>/) do |m|
      next if m !~ /イベント\/\d{4}-\d{2}-\d{2}T/
      year, month, day = m.match(/イベント\/(\d{4})-(\d{2})-(\d{2})T/).to_a.values_at(1, 2, 3)
      if year && month && day
        entry.event_date = begin
                             Date.new(year.to_i, month.to_i, day.to_i)
                           rescue
                             nil
                           end
      end
    end
  end
end
