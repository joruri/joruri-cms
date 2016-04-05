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
    @item = Calendar::Event.new(events_params)
    @item.content_id = @content.id
    _create @item
  end

  def update
    @item = Calendar::Event.find(params[:id])
    @item.attributes = events_params
    _update(@item)
  end

  def destroy
    @item = Calendar::Event.find(params[:id])
    _destroy @item
  end

  private

  def events_params
    params.require(:item).permit(
      :state, :title, :body, :event_date, :event_close_date, :event_uri,
      in_creator: [:group_id, :user_id])
  end
end
