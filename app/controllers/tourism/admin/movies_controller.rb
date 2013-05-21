# encoding: utf-8
class Tourism::Admin::MoviesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  helper Cms::EmbeddedFileHelper
  helper Tourism::FormHelper
  
  def pre_dispatch
    return error_auth unless @content = Cms::Content.find(params[:content])
    #default_url_options[:content] = @content
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end
  
  def index
    @item = Tourism::Movie.new(params.reject{|k,v| k.to_s !~ /^s_/ }) # search
    
    item = Tourism::Movie.new#.readable
    item.and :content_id, @content
    item.search params
    item.page  params[:page], params[:limit]
    item.order (params[:sort] || "updated_at DESC")
    @items = item.find(:all)
    _index @items
  end
  
  def show
    @item = Tourism::Movie.new.find(params[:id])
    _show @item
  end

  def new
    @item = Tourism::Movie.new({
      :state      => 'public',
      :content_id => @content.id,
    })
  end
  
  def create
    @item = Tourism::Movie.new(params[:item])
    @item.content_id = @content.id
    _create @item
  end
  
  def update
    @item = Tourism::Movie.new.find(params[:id])
    @item.attributes = params[:item]
    _update @item
  end
  
  def destroy
    @item = Tourism::Movie.new.find(params[:id])
    _destroy @item
  end
end
