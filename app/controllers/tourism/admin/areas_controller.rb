# encoding: utf-8
class Tourism::Admin::AreasController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  
  def pre_dispatch
    return error_auth unless @content = Cms::Content.find(params[:content])
    #default_url_options[:content] = @content
    
    if params[:parent] == '0'
      @parent = Tourism::Area.new({
        :level_no => 0
      })
      @parent.id = 0
    else
      @parent = Tourism::Area.new.find(params[:parent])
    end
  end
  
  def index
    item = Tourism::Area.new#.readable
    item.and :content_id, @content
    item.and :parent_id, @parent
    item.page  params[:page], params[:limit]
    item.order params[:sort], :sort_no
    @items = item.find(:all)
    _index @items
  end
  
  def show
    @item = Tourism::Area.new.find(params[:id])
    _show @item
  end

  def new
    @item = Tourism::Area.new({
      :state      => 'public',
      :sort_no    => 1,
    })
  end
  
  def create
    @item = Tourism::Area.new(params[:item])
    @item.parent_id = @parent.id
    @item.content_id = @content.id
    @item.level_no  = @parent.level_no + 1
    _create @item
  end
  
  def update
    @item = Tourism::Area.new.find(params[:id])
    @item.attributes = params[:item]
    _update @item
  end
  
  def destroy
    @item = Tourism::Area.new.find(params[:id])
    _destroy @item
  end
end
