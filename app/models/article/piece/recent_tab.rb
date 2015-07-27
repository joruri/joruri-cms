# encoding: utf-8
class Article::Piece::RecentTab < Cms::Piece
  validate :validate_settings
  
  def list_types
    [['タイトル（公開日時　作成者）','title'],['公開日時　タイトル（作成者）','published_at']]
  end

  def validate_settings
    if !in_settings['list_count'].blank?
      errors.add(:list_count, :not_a_number) if in_settings['list_count'] !~ /^[0-9]+$/
    end
  end

  def setting_label(name)
    value = setting_value(name)
    case name
    when :list_type
      list_types.each {|c| return c[0] if c[1].to_s == value.to_s}
    end
    value
  end
end