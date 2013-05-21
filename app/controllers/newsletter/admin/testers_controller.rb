# encoding: utf-8
class Newsletter::Admin::TestersController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
    return error_auth unless @content = Cms::Content.find(params[:content])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
    #default_url_options[:content] = @content
  end

  def index
    item = Newsletter::Tester.new
    item.and :content_id, @content.id
    item.page  params[:page], params[:limit]
    item.order params[:sort], 'email ASC'
    @items = item.find(:all)
    _index @items
  end

  def show
    @item = Newsletter::Tester.new.find(params[:id])
    _show @item
  end

  def new
    @item = Newsletter::Tester.new({
      :state        => 'enabled',
      :agent_state  => 'pc',
    })
  end

  def create
    @item = Newsletter::Tester.new(params[:item])
    @item.content_id = @content.id

    _create @item
  end

  def update
    @item = Newsletter::Tester.new.find(params[:id])
    @item.attributes = params[:item]

    _update(@item)
  end

  def destroy
    @item = Newsletter::Tester.new.find(params[:id])
    _destroy @item
  end

protected
end
