# encoding: utf-8
class Article::Admin::UnitsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  
  def pre_dispatch
    return error_auth unless @content = Cms::Content.find(params[:content])
    #default_url_options[:content] = @content
    
    if params[:parent].to_s == '0'
      @parent = Article::Unit.root_item
    else
      @parent = Article::Unit.find(params[:parent])
    end
  end
  
  def index
    item = Article::Unit.new#.readable
    item.and :parent_id, @parent.id
    item.page  params[:page], params[:limit]
    item.order params[:sort], :sort_no #'(id + 0)'
    @items = item.find(:all)
    _index @items
  end
  
  def show
    @item = Article::Unit.new.find(params[:id])
    _show @item
  end

  def new
    @item = Article::Unit.new({
      :state       => 'public',
      :parent_code => @parent.code,
      :level_no    => @parent.level_no + 1,
      :sort_no     => 1
    })
  end
  
  def create
    @item = Article::Unit.new(params[:item])
    @item.content_id = @content.id
    _create @item
  end
  
  def update
    @item = Article::Unit.new.find(params[:id])
    @item.attributes = params[:item]
    _update @item
  end
  
  def destroy
    @item = Article::Unit.new.find(params[:id])
    _destroy @item
  end
end
