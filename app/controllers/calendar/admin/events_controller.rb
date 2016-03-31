# encoding: utf-8
class Calendar::Admin::EventsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  include Sys::Controller::Scaffold::Recognition
  include Sys::Controller::Scaffold::Publication

  def pre_dispatch
    @content = Cms::Content.find(params[:content])
    return error_auth unless @content
    return error_auth unless Core.user.has_priv?(:read, item: @content.concept)

    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end

  def index
    sort = nil
    sort = 'event_date' if params[:sort] == 'event_date'
    sort = 'event_date DESC' if params[:sort] == 'event_date -1'

    @items = Calendar::Event
             .where(content_id: @content.id)
             .search(params)
             .order(sort, updated_at: :desc, id: :desc)
             .paginate(page: params[:page], per_page: params[:limit])

    _index @items
  end

  def show
    @item = Calendar::Event.find(params[:id])
    _show @item
  end

  def new
    @item = Calendar::Event.new(state: 'public')
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
    @item = Calendar::Event.find(params[:id])
    _destroy @item
  end

  protected
end
