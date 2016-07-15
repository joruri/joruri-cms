# encoding: utf-8
class EntityConversion::Admin::TestsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    @content = Cms::Content.find(params[:content])
    return error_auth unless @content
    return error_auth unless Core.user.has_priv?(:read, item: @content.concept)

    @log = EntityConversion::Log.find_by(content_id: @content.id, env: :test)

    return redirect_to action: 'index' if params[:reset]
  end

  def index
    return test if params[:do] == 'test'

    @item = EntityConversion::Unit.new

    @new_items = EntityConversion::Unit
                 .where(content_id: @content.id)
                 .where(state: 'new')
                 .order(:sort_no)

    @edit_items = EntityConversion::Unit
                  .where(content_id: @content.id)
                  .where(state: 'edit')
                  .order(:sort_no)

    @move_items = EntityConversion::Unit
                  .where(content_id: @content.id)
                  .where(state: 'move')
                  .order(:sort_no)

    @end_items = EntityConversion::Unit
                 .where(content_id: @content.id)
                 .where(state: 'end')
                 .order(:old_parent_id, :old_id)
  end

  protected

  def test
    conv = EntityConversion::Lib::Convertor.factory(:test, content: @content)
    conv.convert
    redirect_to url_for(action: :index)
  end
end
