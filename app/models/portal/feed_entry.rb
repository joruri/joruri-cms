# encoding: utf-8
class Portal::FeedEntry < Cms::FeedEntry
  belongs_to :content,
             foreign_key: :content_id,
             class_name: 'Portal::Content::FeedEntry'

  belongs_to :portal_content,
             foreign_key: :portal_content_id,
             class_name: 'Portal::Content::Base'

  belongs_to :doc, foreign_key: :doc_id, class_name: 'Article::Doc'

  scope :public_content_with_own_docs, ->(content, *args) {
    doc_content = content.doc_content

    list_type = args.slice!(0)
    options = args.slice!(0) || {}

    _union_tbl = 'union_entries'
    _order = ''
    _content_id = content.id || 'NULL'

    _feed_tbl = table_name

    entries = published
              .where(content_id: content.id)
              .agent_filter(options[:mobile])

    entries = entries.select(
      "#{_content_id} AS portal_content_id" \
      ", #{_feed_tbl}.content_id" \
      ', NULL AS doc_id, NULL as name' \
      ", #{_feed_tbl}.feed_id" \
      ", #{_feed_tbl}.entry_updated" \
      ", #{_feed_tbl}.title" \
      ", #{_feed_tbl}.event_date" \
      ', NULL as attribute_ids' \
      ", #{_feed_tbl}.summary" \
      ", #{_feed_tbl}.link_alternate" \
      ", #{_feed_tbl}.categories " \
      ", #{_feed_tbl}.categories_xml " \
      ", #{_feed_tbl}.entry_id" \
      ", #{_feed_tbl}.author_name" \
      ", #{_feed_tbl}.author_email" \
      ", #{_feed_tbl}.author_uri"
    )

    if doc_content
      docs = Article::Doc
             .published
             .where(Article::Doc.arel_table[:content_id].eq(doc_content.id))
             .visible_in_recent
    else
      docs = Article::Doc.none
    end

    case list_type
    when :docs
      _order = "#{_union_tbl}.entry_updated desc"
    when :events
      entries = entries.event_date_is(year: options[:year],
                                      month: options[:month])
      docs = docs.event_date_is(year: options[:year],
                                month: options[:month])
      _order = "#{_union_tbl}.event_date desc"
    when :groups
      entries = entries.category_is(options[:category]) if options[:category]
      docs = make_groups_docs(docs, content, options)
      _order = "#{_union_tbl}.entry_updated desc"
    else
      docs = docs.none
    end

    docs = docs.select(
      "#{_content_id} AS portal_content_id" \
      ', content_id' \
      ', id AS doc_id' \
      ', name' \
      ', NULL AS feed_id' \
      ', published_at AS entry_updated' \
      ', title' \
      ', event_date' \
      ', attribute_ids' \
      ', body AS summary' \
      ', NULL AS link_alternate' \
      ', NULL AS categories ' \
      ', NULL AS categories_xml ' \
      ', NULL AS entry_id' \
      ', NULL AS author_name' \
      ', NULL AS author_email' \
      ', NULL AS author_uri' \
    )

    union_sql = entries.union(docs).to_sql

    self.from("#{union_sql} #{_union_tbl}")
        .select("#{_union_tbl}.*")
        .order(_order)
  }

  def source_title
    return @source_title if @source_title
    @source_title = (feed.title if feed)
  end

  def link_target
    feed ? '_blank' : nil
  end

  def date_and_site(options = {})
    values = []

    if options[:date] != false
      values << %(<span class="date">#{entry_updated.strftime('%Y年%-m月%-d日')}</span>) if entry_updated
    end

    if !source_title.blank?
      values << %(<span class="site">#{ERB::Util.html_escape(source_title)}</span>)
    elsif portal_content
      suffix = portal_content.setting_value(:doc_list_suffix)
      if suffix == 'site'
        values << %(<span class="site">#{ERB::Util.html_escape(portal_content.site.name)}</span>) if portal_content.site
      elsif suffix == 'unit'
        doc = Article::Doc.find_by(id: doc_id, content_id: content.id)
        if doc
          if doc.creator && doc.creator.group
            values << %(<span class="unit">#{ERB::Util.html_escape(doc.creator.group.name)}</span>)
          end
        end
      end
    end

    return '' if values.empty?

    separator = %(<span class="separator">　</span>)
    %(<span class="attributes">（#{values.join(separator)}）</span>).html_safe
  end

  def new_mark
    term = portal_content.setting_value(:new_term)
    return false if term =~ /^0(\s|$)/i

    if (term.nil? || term =~ /^[\s|]*$/) && content_id != portal_content_id
      doc_content = portal_content.doc_content
      term = doc_content.setting_value(:new_term) if doc_content
    end
    term = term.to_f * 60
    return false if term <= 0

    published_at = term.minutes.since entry_updated
    (published_at.to_i >= Time.now.to_i)
  end

  def public_uri
    if name
      node = content.doc_node
      return nil unless node
      "#{node.public_uri}#{name}/"
    else
      super
    end
  end

  def public_full_uri
    doc ? doc.public_full_uri : super
  end

  def self.make_groups_docs(docs, content, options = {})
    _docs = Article::Doc
    condition_exist = false

    if options[:category]
      doc_groups = options[:category].article_groups(content.doc_content)

      doc_groups.each do |g|
        next unless g[:instance]

        case g[:kind]
        when 'cate'
          _docs = _docs.category_is(g[:instance])
          condition_exist = true
        when 'attr'
          _docs = _docs.attribute_is(g[:instance])
          condition_exist = true
        when 'unit'
          _docs = _docs.unit_is(g[:instance])
          condition_exist = true
        when 'area'
          _docs = _docs.area_is(g[:instance])
          condition_exist = true
        end
      end

      _docs = _docs.none unless condition_exist
    else
      _docs = _docs.none
    end

    _docs = _docs.where_values.join(" OR ")

    docs.where(_docs)
  end
end
