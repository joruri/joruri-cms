# encoding: utf-8
class Cms::Admin::Content::BaseController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  before_filter :pre_dispatch_content
  
  def pre_dispatch_content
    @content = Cms::Content.new.find(params[:id])
    return error_auth if params[:action] != 'show' && !Core.user.has_auth?(:designer)
  end
  
  def model
    return @model_class if @model_class
    mclass = self.class.to_s.gsub(/^(\w+)::Admin/, '\1').gsub(/Controller$/, '').singularize
    eval(mclass)
    @model_class = eval(mclass)
  rescue
    @model_class = Cms::Content
  end
  
  def index
    exit
  end
  
  def show
    @item = model.find(params[:id])
    return error_auth if params[:action] != 'show' && !@item.readable?
    
    @pieces      = []
    @directories = []
    @pages       = []
    
    Cms::Lib::Modules.pieces(@item.model).each do |data|
      @pieces << {
        :name  => data[0].gsub(/.*\//, ""),
        :model => data[1],
        :items => Cms::Piece.find(:all, :conditions => {:content_id => @item.id, :model => data[1]})
      }
    end
    
    Cms::Lib::Modules.directories(@item.model).each do |data|
      @directories << {
        :name  => data[0].gsub(/.*\//, ""),
        :model => data[1],
        :items => Cms::Node.find(:all, :conditions => {:content_id => @item.id, :model => data[1]})
      }
    end
    
    Cms::Lib::Modules.pages(@item.model).each do |data|
      @pages << {
        :name  => data[0].gsub(/.*\//, ""),
        :model => data[1],
        :items => Cms::Node.find(:all, :conditions => {:content_id => @item.id, :model => data[1]})
      }
    end
    
    _show @item
  end

  def new
    exit
  end
  
  def create
    exit
  end
  
  def update
    @item = model.find(params[:id])
    @item.attributes = params[:item]
    
    _update @item do
      respond_to do |format|
        format.html { return redirect_to(cms_contents_path) }
      end
    end
  end
  
  def destroy
    @item = model.find(params[:id])
    _destroy @item do
      respond_to do |format|
        format.html { return redirect_to(cms_contents_path) }
      end
    end
  end
end
