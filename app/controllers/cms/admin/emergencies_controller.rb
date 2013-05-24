# encoding: utf-8
class Cms::Admin::EmergenciesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  
  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
    
    @parent   = Core.site.root_node
    @node     = @parent.children.find(:first, :conditions => {:state => "public", :name => 'index.html'})
    @node   ||= @parent.children.find(:first, :conditions => {:state => "public", :name => 'index.htm'})
  end
  
  def index
    item = Cms::SiteSetting::EmergencyLayout.new.current_site
    @items = item.find(:all, :conditions => {:name => 'emergency_layout'}, :order => :sort_no)
  end
  
  def show
    @item = Cms::SiteSetting::EmergencyLayout.new.current_site.find(params[:id])
    @item.value = @item.value.to_i if @item.value
    
    return error_auth unless @item.readable?
    
    _show @item
  end

  def new
    @item = Cms::SiteSetting::EmergencyLayout.new({
      :site_id => Core.site.id,
      :name    => 'emergency_layout',
      :sort_no => 0
    })
  end
  
  def create
    @item = Cms::SiteSetting::EmergencyLayout.new(params[:item])
    @item.site_id = Core.site.id
    @item.name    = 'emergency_layout'
    _create @item
  end
  
  def update
    @item = Cms::SiteSetting::EmergencyLayout.new.current_site.find(params[:id])
    @item.attributes = params[:item]
    _update @item
  end
  
  def destroy
    @item = Cms::SiteSetting::EmergencyLayout.new.current_site.find(params[:id])
    _destroy @item
  end
  
  def change
    @item = Cms::SiteSetting::EmergencyLayout.new.current_site.find(params[:id])
    
    if @item.value.blank?
      @item.errors.add :base, "レイアウトが登録されていません。"
    end
    unless layout = Cms::Layout.find_by_id(@item.value)
      @item.errors.add :base, "レイアウトが見つかりません。"
    end
    unless @node
      @item.errors.add :base, "トップページが見つかりません。"
    end
    
    if @item.errors.size == 0
      @node.layout_id = @item.value
      @node.save(:validate => false)
      publish_page(@node)
    end
    
    if @item.errors.size == 0
      flash[:notice] = '反映処理が完了しました。'
      respond_to do |format|
        format.html { redirect_to url_for(:action => :index) }
        format.xml  { head :ok }
      end
    else
      flash[:notice] = '反映処理に失敗しました。'
      respond_to do |format|
        format.html { redirect_to url_for(:action => :index) }
        format.xml  { render(:xml => @item.errors, :status => :unprocessable_entity) }
      end
    end
  end
  
  def publish_page(item)
    uri  = item.public_uri
    uri  = (uri =~ /\?/) ? uri.gsub(/(.*\.html)\?/, '\\1') : "#{uri}"
    path = "#{item.public_path}"
    item.publish_page(render_public_as_string(uri, :site => item.site), :path => path, :uri => uri)
    
    uri  = item.public_uri
    uri  = (uri =~ /\?/) ? uri.gsub(/(.*\.html)\?/, '\\1.r?') : "#{uri}.r"
    path = "#{item.public_path}.r"
    item.publish_page(render_public_as_string(uri, :site => item.site), :path => path, :uri => uri, :dependent => :ruby)
  end
end
