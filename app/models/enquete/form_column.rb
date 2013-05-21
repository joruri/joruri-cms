# encoding: utf-8
class Enquete::FormColumn < ActiveRecord::Base
  include Sys::Model::Base
  include Cms::Model::Base::Page
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Sys::Model::Auth::Free

  cattr_accessor :column_types
  
  belongs_to :content,        :foreign_key => :content_id,        :class_name => 'Article::Content::Doc'
  belongs_to :status,         :foreign_key => :state,             :class_name => 'Sys::Base::Status'
  
  validates_presence_of :name, :sort_no, :column_type, :required
  validates_numericality_of :sort_no
  
  @@column_types = [
    {:name => "text_field"   , :options => false, :label => "入力/１行（テキストフィールド）"},
    {:name => "text_area"    , :options => false, :label => "入力/複数行（テキストエリア）"},
    {:name => "select"       , :options => true,  :label => "選択/単数回答（プルダウン）"},
    {:name => "radio_button" , :options => true,  :label => "選択/単数回答（ラジオボタン）"},
    {:name => "check_box"    , :options => true,  :label => "選択/複数回答（チェックボックス）"},
  ]
  
  def column_types
    @@column_types
  end
  
  def column_spec
    return @column_spec if @column_spec
    column_types.each {|c| @column_spec = c if c[:name] == column_type}
    @column_spec
  end
  
  def element_name
    "col#{id}"
  end
  
  def element_options
    eopt = {}
    eopt[:message]  = body if !body.blank?
    eopt[:required] = (required == 1)
    eopt[:class]    = column_spec[:name].camelize(:lower)
    eopt[:style]    = column_style
    eopt[:options]  = options if column_spec && column_spec[:options]
    eopt
  end
end