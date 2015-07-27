# encoding: utf-8
require 'digest/md5'
module Cms::Model::Base::Page::Publisher
  def self.included(mod)
    mod.has_many :publishers, :foreign_key => 'unid', :primary_key => 'unid', :class_name => 'Sys::Publisher',
      :dependent => :destroy
    mod.has_many :rel_publishers, :foreign_key => 'rel_unid', :primary_key => 'unid', :class_name => 'Sys::Publisher',
      :conditions=>"#{Sys::Publisher.table_name}.rel_unid is not null", :dependent => :destroy
    mod.after_save :close_page
  end
  
  def public_status
    return published_at ? '公開中' : '非公開'
  end

  def public_path
    Page.site.public_path + public_uri
  end

  def public_uri
    '/'#TODO
  end

  def preview_uri(options = {})
    return nil unless public_uri
    site   = options[:site] || Page.site
    mobile = options[:mobile] ? 'm' : nil
    params = []
    options[:params].each {|k, v| params << "#{k}=#{v}" } if options[:params]
    params = params.size > 0 ? "?#{params.join('&')}" : ""
    "#{Core.site.admin_uri}_preview/#{format('%08d', site.id)}#{mobile}#{public_uri}#{params}"
  end

  def publishable
    editable
    self.and "#{self.class.table_name}.state", 'recognized'
    return self
  end

  def closable
    editable
    public
    return self
  end

  def publishable?
    return false unless editable?
    return false unless recognized?
    return true
  end

  def rebuildable?
    return false unless editable?
    return state == 'public'# && published_at
  end

  def closable?
    return false unless editable?
    return state == 'public'# && published_at
  end
  
  def mobile_page?
    false
  end
  
  def published?
    @published
  end
  
  def publish_page(data, options = {})
    @published = nil
    return false if data.nil?
    save(:validate => false) if unid.nil? # path for Article::Unit
    return false if unid.nil?
    
    path = (options[:path] || public_path).gsub(/\/$/, "/index.html")
    hash = data ? Digest::MD5.new.update(data).to_s : nil
    
    cond = {}
    cond[:site_id]      = options[:site].id if options[:site]
    cond[:dependent] = options[:dependent] ? options[:dependent].to_s : nil;
    pub  = publishers.find(:first, :conditions => cond)
    
    return false if mobile_page?
    
    if hash != nil && pub != nil && hash == pub.content_hash && ::Storage.exists?(path)
      #::Storage.touch([path])
      return pub
    end
    
    if ::Storage.exists?(path) && ::Storage.read(path) == data
      #::Storage.touch([path])
    else
      ::Storage.mkdir_p(::File.dirname(path))
      ::Storage.write(path, data)
      @published = true
    end
    
    pub ||= Sys::Publisher.new
    pub.unid           = unid
    pub.rel_unid       = options[:rel_unid]
    pub.site_id        = site_id if respond_to?(:site_id)
    pub.site_id        = content.site_id if respond_to?(:content) && content
    pub.site_id        = options[:site].id if !pub.site_id && options[:site]
    pub.dependent      = options[:dependent] ? options[:dependent].to_s : nil
    pub.path           = path
    pub.uri            = options[:uri].gsub(/\?.*/, '')
    pub.uri          ||= public_uri.gsub(/\?.*/, '') rescue nil
    pub.content_hash   = hash
    if pub.changed?
      search_links(pub, data) if options[:dependent].to_s !~ /(^|.\/)ruby$/
      pub.save
    end
    
    return pub
  end
  
  def close_page(options = {})
    publishers.destroy_all
    rel_publishers.destroy_all
    return true
  end
  
  ## for link_check
  def search_links(pub, data)
    return false if pub.site_id.blank?
    return false if pub.uri.blank?
    
    site = Cms::Site.find_by_id(pub.site_id)
    return false unless site
    
    inlinks = []
    exlinks = []
    
    site_uri = site.full_uri.gsub(/^(.*?\/\/.*?\/).*/, '\\1')
    base_uri = pub.uri
    base_uri = "#{base_uri}index.html" if base_uri =~ /\/$/
    base_uri = ::File.dirname(base_uri) + "/"
    
    data.scan(/<a href="([^"]+)">/i).uniq.each do |m|
      uri = m[0].to_s
      next if uri.strip.blank?
      next if uri =~ /^#/
      next if uri =~ /^javascript:/i
      next if uri =~ /^mailto:/i
      uri = uri.gsub(/\/index\.html$/, '/')
      
      if uri =~ /^\//
        inlinks << uri
      elsif uri.index(site_uri) == 0
        inlinks << uri
      elsif uri =~ /^https?:/
        exlinks << uri
      else
        uri = ::File.join(base_uri, uri)
        uri.gsub!(/\/\.\//, '/')
        while uri =~ /\/[^\/]+\/\.\.\// do
          uri.gsub!(/\/[^\/]+\/\.\.\//, '/')
        end
        inlinks << uri
      end
    end
    
    inlinks.uniq!
    exlinks.uniq!
    pub.internal_links = inlinks.size > 0 ? inlinks.join("\n") : nil
    pub.external_links = exlinks.size > 0 ? exlinks.join("\n") : nil
    return true
  end
end
