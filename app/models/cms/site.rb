# encoding: utf-8
class Cms::Site < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Base::Page
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Sys::Model::Auth::Manager
  
  belongs_to :status,   :foreign_key => :state,
    :class_name => 'Sys::Base::Status'
  has_many   :concepts, :foreign_key => :site_id, :order => 'name, id',
    :class_name => 'Cms::Concept', :dependent => :destroy
  has_many   :contents, :foreign_key => :site_id, :order => 'name, id',
    :class_name => 'Cms::Content'
  has_many   :settings, :foreign_key => :site_id, :order => 'name, sort_no',
    :class_name => 'Cms::SiteSetting'
  
  validates_presence_of :state, :name, :full_uri
  
  validate :validate_attributes
  
  def states
    [['公開','public']]
  end
  
  def public_path
    "#{Rails.public_path}_#{format('%08d', id)}"
  end
  
  def rewrite_config_path
    "#{Rails.root}/config/rewrite/#{format('%08d', id)}.conf"
  end
  
  def uri
    return '/' unless full_uri.match(/^[a-z]+:\/\/[^\/]+\//)
    full_uri.sub(/^[a-z]+:\/\/[^\/]+\//, '/')
  end
  
  def dirname
    return nil if full_uri !~ /^.*?:\/\/[^\/]+\/.+/
    full_uri.gsub(/^.*?:\/\/[^\/]+\//, '').gsub(/\/$/, '')
  end
  
  def domain
    full_uri.gsub(/^[a-z]+:\/\/([^\/]+)\/.*/, '\1')
  end
  
  def admin_uri(options = {}) # full_uri
    uri  = admin_full_uri.blank? ? Core.full_uri : admin_full_uri
    uri += options[:path].gsub(/^\//, '') if options[:path]
    uri
  end
  
  def has_mobile?
    !mobile_full_uri.blank?
  end
  
  def root_node
    Cms::Node.find_by_id(node_id)
  end
  
  def related_sites(options = {})
    sites = []
    related_site.to_s.split(/(\r\n|\n)/).each do |line|
      sites << line if line.strip != ''
    end
    if options[:include_self]
      sites << "#{full_uri}" if !full_uri.blank?
      sites << "#{alias_full_uri}" if !alias_full_uri.blank?
      sites << "#{mobile_full_uri}" if !mobile_full_uri.blank?
    end
    sites
  end
  
  def self.find_by_script_uri(script_uri)
    find = Proc.new do |_base|
      item = Cms::Site.new.public
      item.and Condition.new do |c|
        c.or :full_uri, 'LIKE', "http://#{_base}%"
        c.or :alias_full_uri, 'LIKE', "http://#{_base}%"
        c.or :mobile_full_uri, 'LIKE', "http://#{_base}%"
      end
      item.find(:first, :order => :id)
    end
    
    ## dir
    if script_uri =~ /^[a-z]+:\/\/[^\/]+\/[^\/]+\/.*/
      base = script_uri.gsub(/^[a-z]+:\/\/([^\/]+\/[^\/]+\/).*/, '\1')
      item = find.call(base)
      return item if item
    end
    
    base = script_uri.gsub(/^[a-z]+:\/\/([^\/]+\/).*/, '\1')
    return find.call(base)
  end
  
protected
  def validate_attributes
    if !full_uri.blank? && full_uri !~ /^[a-z]+:\/\/[^\/]+\//
      self.full_uri += '/'
    end
    return true
  end
end
