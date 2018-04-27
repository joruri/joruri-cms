# encoding: utf-8
class Portal::Admin::FeedEntriesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  include Sys::Controller::Scaffold::Recognition
  include Sys::Controller::Scaffold::Publication

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
    @content = Cms::Content.find(params[:content])
    return error_auth unless @content
    @feed = Cms::Feed.find(params[:feed])
    return error_auth unless @feed
    return error_auth unless Core.user.has_priv?(:read, item: @content.concept)
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end

  def index
    return update_entries if params[:do] == 'update_entries'
    return delete_entries if params[:do] == 'delete_entries'

    @items = Portal::FeedEntry
             .where(feed_id: @feed.id)
             .search(params)
             .order(entry_updated: :desc, id: :desc)
             .paginate(page: params[:page], per_page: params[:limit])

    _index @items
  end

  def show
    @item = Portal::FeedEntry.find(params[:id])
    _show @item
  end

  def new
    error_auth
  end

  def create
    error_auth
  end

  def update
    @item = Portal::FeedEntry.find(params[:id])
    @item.attributes = feed_entry_params
    _update @item
  end

  def destroy
    error_auth
  end

  protected

  def update_entries
    flash[:notice] = if @feed.update_feed(destroy: true)
                       "エントリを更新しました。"
                     else
                       "エントリの更新に失敗しました。"
                     end
    redirect_to portal_feed_entries_path
  end

  def delete_entries
    flash[:notice] = if @feed.entries.destroy_all
                       "エントリを削除しました。"
                     else
                       "エントリの削除に失敗しました。"
                     end
    redirect_to portal_feed_entries_path
  end

  private

  def feed_entry_params
    params.require(:item).permit(
      :state, :link_alternate, :title, :summary)
  end
end
