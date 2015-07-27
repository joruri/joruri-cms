# encoding: utf-8
class Cms::Admin::Data::FileNodesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  include Sys::Controller::Scaffold::Publication

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
    return redirect_to :action => 'index' if params[:reset]
    
    @parent = params[:parent] || '0'
  end

  def index
    item = Cms::DataFileNode.new
    item.readable if params[:s_target] != "all"
    item.and :site_id, Core.site.id
    item.search params
    item.page  params[:page], params[:limit]
    item.order params[:sort], 'name, id'
    @items = item.find(:all)
    _index @items
  end

  def show
    item = Cms::DataFileNode.new.readable
    @item = item.find(params[:id])
    return error_auth unless @item.readable?

    _show @item
  end

  def new
    @item = Cms::DataFileNode.new({
      :concept_id => Core.concept(:id)
    })
  end

  def create
    @item = Cms::DataFileNode.new(params[:item])
    @item.site_id = Core.site.id
    _create @item
  end

  def update
    @item = Cms::DataFileNode.new.find(params[:id])
    @item.attributes = params[:item]
    @old_concept_id  = @item.concept_id_was
    
    _update(@item) do
      if @old_concept_id != @item.concept_id
        cond = {:concept_id => @old_concept_id, :node_id => @item.id}
        Cms::DataFile.update_all({:concept_id => @item.concept_id}, cond)
      end
    end
  end

  def destroy
    @item = Cms::DataFileNode.new.find(params[:id])
    _destroy @item
  end
end
