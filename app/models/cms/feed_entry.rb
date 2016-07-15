# encoding: utf-8
class Cms::FeedEntry < ActiveRecord::Base
  include Sys::Model::Base
  include Cms::Model::Base::Page
  include Sys::Model::Auth::Free

  include StateText

  belongs_to :feed, foreign_key: :feed_id, class_name: 'Cms::Feed'

  validates :link_alternate, :title, presence: true

  scope :published, -> {
    where(arel_table[:state].eq('public'))
    .joins(:feed)
    .where(Cms::Feed.arel_table[:state].eq('public'))
  }

  scope :search, ->(params) {
    rel = all

    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_id'
        rel = rel.where(arel_table[:id].eq(v))
      when 's_title'
        rel = rel.where(arel_table[:title].matches("#{v}%"))
      when 's_keyword'
        rel = rel.where(arel_table[:title].matches("%#{v}%")
                        .or(arel_table[:summary].matches("%#{v}%")))
      end
    end if params.size != 0

    rel
  }

  scope :event_date_in, ->(sdate, edate) {
    where(
      arel_table[:event_date].lt(edate.to_s)
      .and(arel_table[:event_close_date].gteq(sdate.to_s))
      .or(arel_table[:event_close_date].eq(nil)
          .and(arel_table[:event_date].gteq(sdate.to_s))
          .and(arel_table[:event_date].lt(edate.to_s)))
    )
  }

  scope :event_date_is, ->(options = {}) {
    rel = all

    if options[:year] && options[:month]
      sdate = Date.new(options[:year], options[:month], 1)
      edate = sdate >> 1
      rel = rel.where(
        arel_table[:event_date].not_eq(nil)
        .and(arel_table[:event_date].gteq(sdate.to_s))
        .and(arel_table[:event_date].lt(edate.to_s))
      )
    end

    rel
  }

  scope :agent_filter, ->(_agent) {
    self
  }

  scope :category_is, ->(cate) {
    return self if cate.blank?
    cate = [cate] unless cate.class == Array
    cate.each do |c|
      cate += c.public_children if c.level_no == 1
    end
    cate = cate.uniq

    rel = all

    added = false
    cate.each do |c|
      next unless c.entry_categories
      arr = c.entry_categories.split(/\r\n|\r|\n/)
      arr.each do |label|
        label = label.gsub(/\/$/, '')

        rel = rel.where(arel_table[:categories].matches("#{label}%")
                        .or(arel_table[:categories].matches("%\n#{label}%")))

        added = true
      end
    end

    rel = rel.none unless added
    rel
  }

  scope :group_is, ->(group) {
    return all unless group
    category_is(group)
  }

  def published_at
    entry_updated
  end

  def public_uri
    return nil unless link_alternate
    link_alternate
  end

  def public_full_uri
    return nil unless link_alternate
    link_alternate
  end
end
