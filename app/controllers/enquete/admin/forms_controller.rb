# encoding: utf-8
class Enquete::Admin::FormsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  include Sys::Controller::Scaffold::Recognition
  include Sys::Controller::Scaffold::Publication
  helper Article::FormHelper

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
    return error_auth unless @content = Cms::Content.find(params[:content])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
    #default_url_options[:content] = @content
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end

  def index
    item = Enquete::Form.new#.public#.readable
    #item.public unless Core.user.has_auth?(:manager)
    item.and :content_id, @content.id
    #item.search params
    item.page  params[:page], params[:limit]
    item.order params[:sort], 'sort_no ASC, id DESC'
    @items = item.find(:all)
    _index @items
  end

  def show
    @item = Enquete::Form.new.find(params[:id])
    #return error_auth unless @item.readable?
    
    _show @item
  end

  def new
    @item = Enquete::Form.new({
      :state        => 'public',
      :sort_no      => 0
    })
  end

  def create
    @item = Enquete::Form.new(params[:item])
    @item.content_id = @content.id

    _create @item
  end

  def update
    @item = Enquete::Form.new.find(params[:id])
    @item.attributes = params[:item]

    _update(@item)
  end

  def destroy
    @item = Enquete::Form.new.find(params[:id])
    _destroy @item
  end
end
