# encoding: utf-8
class Cms::Admin::LayoutsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  include Sys::Controller::Scaffold::Publication

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
    return redirect_to action: 'index' if params[:reset]
  end

  def index
    @items = Cms::Layout.search(params)
    @items = @items.readable if params[:s_target] != 'all'
    @items = @items.order(params[:sort], :name, :id)
                   .paginate(page: params[:page], per_page: params[:limit])

    _index @items
  end

  def show
    @item = Cms::Layout.readable.find(params[:id])
    return error_auth unless @item.readable?

    _show @item
  end

  def new
    @item = Cms::Layout.new(concept_id: Core.concept(:id),
                            state: 'public')
  end

  def create
    @item = Cms::Layout.new(layouts_params)
    @item.site_id = Core.site.id
    @item.state   = 'public'
    _create @item do
      @item.put_css_files
    end
  end

  def update
    @item = Cms::Layout.new.find(params[:id])
    @item.attributes = layouts_params
    _update(@item) do
      @item.put_css_files
    end
  end

  def destroy
    @item = Cms::Layout.new.find(params[:id])
    _destroy @item
  end

  def duplicate(item)
    if dupe_item = item.duplicate
      flash[:notice] = '複製処理が完了しました。'
      respond_to do |format|
        format.html { redirect_to url_for(action: :index) }
        format.xml  { head :ok }
      end
    else
      flash[:notice] = "複製処理に失敗しました。"
      respond_to do |format|
        format.html { redirect_to url_for(action: :show) }
        format.xml  { render xml: item.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def layouts_params
    params.require(:item).permit(
      :concept_id, :name, :title, :body, :head, :stylesheet,
      :mobile_body, :mobile_head, :mobile_stylesheet, :smart_phone_body,
      :smart_phone_head, :smart_phone_stylesheet,
      in_creator: [:group_id, :user_id]
    )
  end
end
