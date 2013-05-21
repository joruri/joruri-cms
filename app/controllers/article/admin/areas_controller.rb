# encoding: utf-8
class Article::Admin::AreasController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  
  def pre_dispatch
    return error_auth unless @content = Cms::Content.find(params[:content])
    #default_url_options[:content] = @content
    
    if params[:parent] == '0'
      @parent = Article::Area.new({
        :level_no => 0
      })
      @parent.id = 0
    else
      @parent = Article::Area.new.find(params[:parent])
    end
  end
  
  def index
    item = Article::Area.new#.readable
    item.and :content_id, @content
    item.and :parent_id, @parent
    item.page  params[:page], params[:limit]
    item.order params[:sort], :sort_no
    @items = item.find(:all)
    _index @items
  end
  
  def show
    @item = Article::Area.new.find(params[:id])
    _show @item
  end

  def new
    @item = Article::Area.new({
      :state      => 'public',
      :sort_no    => 1,
    })
  end
  
  def create
    @item = Article::Area.new(params[:item])
    @item.parent_id = @parent.id
    @item.content_id = @content.id
    @item.level_no  = @parent.level_no + 1
    _create @item
  end
  
  def update
    @item = Article::Area.new.find(params[:id])
    @item.attributes = params[:item]
    _update @item
  end
  
  def destroy
    @item = Article::Area.new.find(params[:id])
    _destroy @item
  end
end
