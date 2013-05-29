# encoding: utf-8
class Cms::Controller::Script::Publication < ApplicationController
  include Cms::Controller::Layout
  before_filter :initialize_publication
  
  def self.publishable?
    true
  end
  
  def initialize_publication
    if @node = params[:node]
      @site = @node.site
    end
    @errors = []
    
    @dic_updated = Cms::KanaDictionary.dic_mtime.to_i
  end
  
  def publish_page(item, params = {})
    Script.current
    
    site = params[:site] || @site
    pub = item.publish_page(render_public_as_string(params[:uri], :site => site),
      :rel_unid => params[:rel_unid], :path => params[:path], :uri => params[:uri], :dependent => params[:dependent])
    return false unless pub
    #return true if params[:path] !~ /(\/|\.html)$/

    Script.success if item.published?
    
    ## ruby html
    uri = params[:uri]
    if uri =~ /\.html$/
      uri += ".r"
    elsif uri =~ /\/$/
      uri += "index.html.r"
    elsif uri =~ /\/\?/
      uri = uri.gsub(/(\/)(\?)/, '\\1index.html.r\\2')
    elsif uri =~ /\.html\?/
      uri = uri.gsub(/(\.html)(\?)/, '\\1.r\\2')
    else
      return true
    end
    
    #uri  = (params[:uri] =~ /\.html$/ ? "#{params[:uri]}.r" : "#{params[:uri]}index.html.r")
    path = (params[:path] =~ /\.html$/ ? "#{params[:path]}.r" : "#{params[:path]}index.html.r")
    dep  = params[:dependent] ? "#{params[:dependent]}/ruby" : "ruby"
    
    ruby = nil
    if item.published?
      ruby = true
    elsif !::Storage.exists?(path)
      ruby = true
    elsif ::Storage.mtime(path).to_i <= @dic_updated
      ruby = true
    end
    
    if ruby
      begin
        timeout(80) do
          item.publish_page(render_public_as_string(uri, :site => site),
            :rel_unid => params[:rel_unid], :path => path, :uri => uri, :dependent => dep)
        end
      rescue TimeoutError => e
        Script.error "#{uri} #{e}"
      rescue => e
        Script.error "#{uri} #{e}"
      end
    end
    
    return pub
  rescue Script::InterruptException => e
    raise e
  rescue => e
    return false
  end
  
  def publish_more(item, params = {})
    stopp = nil
    limit = Joruri.config[:cms_publish_more_pages].to_i rescue 0
    limit = (limit < 1 ? 1 : 1 + limit)
    file  = params[:file] || 'index'
    first = params[:first] || 1
    first.upto(limit) do |p|
      page = (p == 1 ? "" : ".p#{p}") 
      uri  = "#{params[:uri]}#{file}#{page}.html"
      path = "#{params[:path]}#{file}#{page}.html"
      dep  = "#{params[:dependent]}#{page}"
      rs   = publish_page(item, :rel_unid => params[:rel_unid], :uri => uri, :site => params[:site], :path => path, :dependent => dep)
      unless rs
        stopp = p
        break
      end
      #return item.published? ## file updated
    end
    
    ## remove over files
    first = stopp ? stopp : (limit + 1)
    first.upto(9999) do |p|
      dep = "#{params[:dependent]}.p#{p}"
      pub = Sys::Publisher.find(:first, :conditions => {:unid => item.unid, :dependent => dep})
      break unless pub
      pub.destroy
      pub = Sys::Publisher.find(:first, :conditions => {:unid => item.unid, :dependent => "#{dep}/ruby"})
      pub.destroy if pub
    end
  end
end
