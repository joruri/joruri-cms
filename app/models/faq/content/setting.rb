# encoding: utf-8
class Faq::Content::Setting < Cms::ContentSetting
  
  set_config :word_dictionary, :name => "本文/単語変換辞書",
    :form_type => :text, :lower_text => "CSV形式（例　対象文字,変換後文字 ）"
  set_config :inquiry_email_display, :name => "連絡先/メールアドレス表示",
    :options => [["表示","visible"],["非表示","hidden"]]
  set_config :recognition_type, :name => "承認/承認フロー",
    :options => [['管理者承認が必要','with_admin']]
  #set_config :default_recognizers, :name => "承認/デフォルト承認者"
  set_config :allowed_attachment_type, :name => "添付ファイル/許可する種類",
    :comment => "（例　<tt>gif,jpg,png,pdf,doc,xls,ppt,odt,ods,odp</tt> ）"
  set_config :attachment_resize_size, :name => "添付ファイル/自動リサイズ",
    :options => Sys::Model::Base::File.sizes,
    :style   => 'width: 100px;'
  set_config :attachment_thumbnail_size, :name => "添付ファイル/サムネイルサイズ",
    :comment => "（例　<tt>120x90</tt> ）",
    :style   => 'width: 100px;'
  
  validate :validate_value
  
  def validate_value
    case name
    when 'default_map_position'
      if !value.blank? && value !~ /^[0-9\.]+ *, *[0-9\.]+$/
        errors.add :value, :invalid
      end
    end
  end
  
  def config_options
    case name
    when 'default_recognizers'
      users = Sys::User.new.enabled.find(:all, :order => :account)
      return users.collect{|c| [c.name_with_account, c.id.to_s]}
    end
    super
  end
  
  def value_name
    if !value.blank?
      case name
      when 'default_recognizers'
        user = Sys::User.find_by_id(value)
        return user.name_with_account if user
      end
    end
    super
  end
end