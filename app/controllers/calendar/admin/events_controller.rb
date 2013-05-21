# encoding: utf-8
class Calendar::Admin::EventsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  include Sys::Controller::Scaffold::Recognition
  include Sys::Controller::Scaffold::Publication

  def pre_dispatch
    #return error_auth unless Core.user.has_auth?(:designer)
    return error_auth unless @content = Cms::Content.find(params[:content])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
    #default_url_options[:content] = @content
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end

  def index
    sort = nil
    sort = "event_date" if params[:sort] == "event_date"
    sort = "event_date DESC" if params[:sort] == "event_date -1"
    
    item = Calendar::Event.new#.public#.readable
    item.and :content_id, @content.id
    item.search params
    item.page  params[:page], params[:limit]
    item.order sort, 'updated_at DESC, id DESC'
    @items = item.find(:all)
    _index @items
  end

  def show
    @item = Calendar::Event.new.find(params[:id])
    #return error_auth unless @item.readable?
    
    _show @item
  end

  def new
    @item = Calendar::Event.new({
      :state        => 'public'
    })
  end

  def create
    @item = Calendar::Event.new(params[:item])
    @item.content_id = @content.id

    _create @item
  end

  def update
    @item = Calendar::Event.new.find(params[:id])
    @item.attributes = params[:item]

    _update(@item)
  end

  def destroy
    @item = Calendar::Event.new.find(params[:id])
    _destroy @item
  end

protected
end
