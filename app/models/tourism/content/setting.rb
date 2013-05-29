# encoding: utf-8
class Tourism::Content::Setting < Cms::ContentSetting
  set_config :doc_content_id, :name => "記事コンテンツ"
  
  set_config :genre_resize_size, :name => "ジャンル/画像リサイズ",
    :comment => "（例　<tt>640x480</tt> ）",
    :style   => 'width: 100px;'
  set_config :genre_thumbnail_size, :name => "ジャンル/サムネイル",
    :comment => "（例　<tt>120x90</tt> ）",
    :style   => 'width: 100px;'
  set_config :spot_resize_size, :name => "観光地/メイン画像リサイズ",
    :comment => "（例　<tt>640x480</tt> ）",
    :style   => 'width: 100px;'
  set_config :spot_thumbnail_size, :name => "観光地/メイン画像サムネイル",
    :comment => "（例　<tt>120x90</tt> ）",
    :style   => 'width: 100px;'
  set_config :spot_detail_thumbnail_size, :name => "観光地/詳細画像サムネイル",
    :comment => "（例　<tt>640x480</tt> ）",
    :style   => 'width: 100px;'
  set_config :photo_resize_size, :name => "写真/画像リサイズ",
    :comment => "（例　<tt>640x480</tt> ）",
    :style   => 'width: 100px;'
  set_config :photo_thumbnail_size, :name => "写真/サムネイル",
    :comment => "（例　<tt>120x90</tt> ）",
    :style   => 'width: 100px;'
  set_config :mouth_resize_size, :name => "クチコミ/画像リサイズ",
    :comment => "（例　<tt>640x480</tt> ）",
    :style   => 'width: 100px;'
  set_config :mouth_thumbnail_size, :name => "クチコミ/サムネイル",
    :comment => "（例　<tt>120x90</tt> ）",
    :style   => 'width: 100px;'
  set_config :mouth_sent_message, :name => "クチコミ/投稿完了メッセージ",
    :form_type => :text
  set_config :default_map_position, :name => "地図/デフォルト座標",
    :comment => "（経度, 緯度）"
  
  validate :validate_value
  
  def validate_value
    case name
    when 'default_map_position'
      errors.add(:value, :invalid) if !value.blank? && value !~ /^[0-9\.]+ *, *[0-9\.]+$/
    when "genre_resize_size"
      errors.add(:value, :invalid) if !value.blank? && value !~ /^[0-9]+x[0-9]+$/
    when "genre_thumbnail_size"
      errors.add(:value, :invalid) if !value.blank? && value !~ /^[0-9]+x[0-9]+$/
    when "spot_resize_size"
      errors.add(:value, :invalid) if !value.blank? && value !~ /^[0-9]+x[0-9]+$/
    when "spot_thumbnail_size"
      errors.add(:value, :invalid) if !value.blank? && value !~ /^[0-9]+x[0-9]+$/
    when "photo_resize_size"
      errors.add(:value, :invalid) if !value.blank? && value !~ /^[0-9]+x[0-9]+$/
    when "photo_thumbnail_size"
      errors.add(:value, :invalid) if !value.blank? && value !~ /^[0-9]+x[0-9]+$/
    end
  end
  
  def config_options
    case name
    when 'doc_content_id'
      contents = Core.site.contents.find(:all, :conditions => {:model => 'Article::Doc'})
      return contents.collect{|c| [c.name, c.id.to_s]}
    end
    super
  end
  
  def value_name
    if !value.blank?
      case name
      when 'doc_content_id'
        content = Cms::Content.find_by_id(value)
        return content.name if content
      end
    end
    super
  end
end