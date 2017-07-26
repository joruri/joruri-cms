# encoding: utf-8
class Cms::Admin::Node::BaseController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  include Sys::Controller::Scaffold::Recognition
  include Sys::Controller::Scaffold::Publication

  before_filter :pre_dispatch_node

  def pre_dispatch_node
    return error_auth unless Core.user.has_auth?(:designer)
    id = params[:parent] == '0' ? Core.site.node_id : params[:parent]
    @parent = Cms::Node.find(id)
  end

  def model
    return @model_class if @model_class
    mclass = '::' + self.class.to_s.gsub(/^(\w+)::Admin/, '\1')
                                   .gsub(/Controller$/, '')
                                   .singularize
    mclass.constantize
    @model_class = mclass.constantize
  rescue
    @model_class = Cms::Node
  end

  def index
    exit
  end

  def show
    @item = model.find(params[:id])
    _show @item
  end

  def new
    exit
  end

  def create
    exit
  end

  def update
    @item = model.find(params[:id])
    @item.attributes = base_params
    @item.state      = params[:commit_public] ? 'public' : 'closed'

    _update @item do
      @item.close_page unless @item.public?
      respond_to do |format|
        format.html { return redirect_to(cms_nodes_path) }
      end
    end
  end

  def destroy
    @item = model.find(params[:id])
    _destroy @item do
      respond_to do |format|
        format.html { return redirect_to(cms_nodes_path) }
      end
    end
  end

  private

  def base_params
    nested = {in_creator: base_params_item_in_creator,
              in_settings: base_params_item_in_settings}
    params.require(:item).permit(*base_params_item, nested)
  end
  
  def base_params_item
    [:concept_id, :layout_id, :name, :parent_id, :route_id,
      :sitemap_sort_no, :sitemap_state, :title]
  end

  def base_params_item_in_creator
    [:group_id, :user_id]
  end
  
  def base_params_item_in_settings
    []
  end
  
end
