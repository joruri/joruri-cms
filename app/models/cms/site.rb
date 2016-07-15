# encoding: utf-8
class Cms::Site < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Base::Page
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Sys::Model::Auth::Manager

  include StateText

  has_many :concepts, -> { order(:name, :id) }, foreign_key: :site_id,
           class_name: 'Cms::Concept', dependent: :destroy
  has_many :contents, -> { order(:name, :id) }, foreign_key: :site_id,
           class_name: 'Cms::Content'
  has_many :settings, -> { order(:name, :sort_no) }, foreign_key: :site_id,
           class_name: 'Cms::SiteSetting'
  belongs_to :root_node, foreign_key: :node_id, class_name: 'Cms::Node'

  validates :state, :name, :full_uri, presence: true
  validate :validate_attributes

  def states
    [%w(公開 public)]
  end

  def public_path
    "#{Rails.public_path}_#{format('%08d', id)}"
  end

  def rewrite_config_path
    "#{Rails.root}/config/rewrite/#{format('%08d', id)}.conf"
  end

  def uri
    return '/' unless full_uri =~ /^[a-z]+:\/\/[^\/]+\//
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

  def related_sites(options = {})
    sites = []
    related_site.to_s.split(/(\r\n|\n)/).each do |line|
      sites << line if line.strip != ''
    end
    if options[:include_self]
      sites << full_uri.to_s unless full_uri.blank?
      sites << alias_full_uri.to_s unless alias_full_uri.blank?
      sites << mobile_full_uri.to_s unless mobile_full_uri.blank?
    end
    sites
  end

  def self.find_by_script_uri(script_uri)
    find = Proc.new do |_base|
      items = Cms::Site.published

      items = items.where(
        arel_table[:full_uri].matches("http://#{_base}%")
        .or(arel_table[:alias_full_uri].matches("http://#{_base}%"))
        .or(arel_table[:mobile_full_uri].matches("http://#{_base}%"))
      )

      items.order(:id).first
    end

    ## dir
    if script_uri =~ /^[a-z]+:\/\/[^\/]+\/[^\/]+\/.*/
      base = script_uri.gsub(/^[a-z]+:\/\/([^\/]+\/[^\/]+\/).*/, '\1')
      item = find.call(base)
      return item if item
    end

    base = script_uri.gsub(/^[a-z]+:\/\/([^\/]+\/).*/, '\1')
    find.call(base)
  end

  protected

  def validate_attributes
    if !full_uri.blank? && full_uri !~ /^[a-z]+:\/\/[^\/]+\//
      self.full_uri += '/'
    end
    true
  end
end
