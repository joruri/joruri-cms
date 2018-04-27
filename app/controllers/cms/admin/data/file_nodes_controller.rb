# encoding: utf-8
class Cms::Admin::Data::FileNodesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  include Sys::Controller::Scaffold::Publication

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
    return redirect_to action: 'index' if params[:reset]

    @parent = params[:parent] || '0'
  end

  def index
    @items = Cms::DataFileNode.where(site_id: Core.site.id)
    @items = @items.readable if params[:s_target] != 'all'
    @items = @items.search(params)
                   .paginate(page: params[:page], per_page: params[:limit])
                   .order(:name, :id)

    _index @items
  end

  def show
    @item = Cms::DataFileNode.find(params[:id])
    return error_auth unless @item.readable?

    _show @item
  end

  def new
    @item = Cms::DataFileNode.new(concept_id: Core.concept(:id))
  end

  def create
    @item = Cms::DataFileNode.new(nodes_params)
    @item.site_id = Core.site.id
    _create @item
  end

  def update
    @item = Cms::DataFileNode.find(params[:id])
    @item.attributes = nodes_params
    @old_concept_id  = @item.concept_id_was

    _update(@item) do
      if @old_concept_id != @item.concept_id
        cond = { concept_id: @old_concept_id, node_id: @item.id }
        Cms::DataFile.update_all({ concept_id: @item.concept_id }, cond)
      end
    end
  end

  def destroy
    @item = Cms::DataFileNode.find(params[:id])
    _destroy @item
  end

  private

  def nodes_params
    params.require(:item).permit(
      :concept_id, :name, :title, :parent
    )
  end
end
