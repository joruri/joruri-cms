# encoding: utf-8
class Bbs::Item < ActiveRecord::Base
  include Sys::Model::Base
  include Cms::Model::Base::Page
  include Sys::Model::Auth::Free

  attr_accessor :block_uri, :block_word, :block_ipaddr
  
  belongs_to :status, :foreign_key => :state,
    :class_name => 'Sys::Base::Status'
  has_many :responses, :foreign_key => :parent_id, :order => "id",
    :class_name => 'Bbs::Item', :dependent => :destroy, :conditions => "parent_id != 0"
  has_many :all_responses, :foreign_key => :thread_id, :order => "id",
    :class_name => 'Bbs::Item', :conditions => "parent_id != 0"
  
  validates_presence_of :name, :title, :body
  validates_format_of :email, :with => /^(([A-Za-z0-9]+_+)|([A-Za-z0-9]+-+)|([A-Za-z0-9]+.+)|([A-Za-z0-9]+\++))*[A-Za-z0-9]+@((\w+-+)|(\w+.))*\w{1,63}.[a-zA-Z]{2,6}$/ix,
    :if => %Q(!email.blank?)
  validates_length_of :name, :title, :uri, :email,
    :maximum => 50, :allow_nil => true
  validates_length_of :body,
    :maximum => 100000, :allow_nil => true
  validates_format_of :body, :with => /^((?!(http|https):\/\/).)*$/i,
    :if => %Q(block_uri), :message => "にURLを含めることはできません。"
  validate :validate_block_word
  validate :validate_block_ipaddr
  
  apply_simple_captcha :message => "の画像と文字が一致しません。"
  
  after_save :save_thread_id,
    :if => %Q(parent_id == 0 && thread_id.nil?)
  
  def public
    self.and "#{self.class.table_name}.state", 'public'
    self
  end
  
  def public_uri
    
  end
  
  def search(params)
    params.each do |n, v|
      next if v.to_s == ''
      
      case n
      when 's_id'
        self.and :id, v
      when 's_keyword'
        self.and_keywords v, :name, :title, :body, :email, :uri
      end
    end if params.size != 0
    
    return self
  end
  
protected
  def validate_block_word
    block_word.to_s.split(/(\r\n|\n|\t| |　)+/).uniq.each do |w|
      next if w.strip.blank?
      if body.index(w)
        errors.add :body, "に禁止されている語句が含まれています。"
        return false
      end
    end
    true
  end
  
  def validate_block_ipaddr
    block_ipaddr.to_s.split(/(\r\n|\n|\t| |　)+/).uniq.each do |w|
      next if w.strip.blank?
      reg = Regexp.new("^" + Regexp.quote(w).gsub('\\*', '[0-9]+') + "$")
      if ipaddr =~ reg
        errors.add :base, "ご利用の環境からの投稿は禁止されています。"
        return false
      end
    end
    true
  end
  
  def save_thread_id
    self.thread_id = id
    save(:validate => false)
  end
end