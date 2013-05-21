# encoding: utf-8
class Cms::Admin::Node::BaseController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  include Sys::Controller::Scaffold::Recognition
  include Sys::Controller::Scaffold::Publication
  
  before_filter :pre_dispatch_node
  
  def pre_dispatch_node
    return error_auth unless Core.user.has_auth?(:designer)
    id      = params[:parent] == '0' ? Core.site.node_id : params[:parent]
    @parent = Cms::Node.new.find(id)
  end
  
  def model
    #@@_models[self.class] ? @@_models[self.class] : Cms::Node
    return @model_class if @model_class
    mclass = '::' + self.class.to_s.gsub(/^(\w+)::Admin/, '\1').gsub(/Controller$/, '').singularize
    eval(mclass)
    @model_class = eval(mclass)
  rescue
    @model_class = Cms::Node
  end
  
  def index
    exit
  end
  
  def show
    @item = model.new.find(params[:id])
    _show @item
  end

  def new
    exit
  end
  
  def create
    exit
  end
  
  def update
    @item = model.new.find(params[:id])
    @item.attributes = params[:item]
    @item.state      = params[:commit_public] ? 'public' : 'closed'
    
    _update @item do
      @item.close_page if !@item.public?
      respond_to do |format|
        format.html { return redirect_to(cms_nodes_path) }
      end
    end
  end
  
  def destroy
    @item = model.new.find(params[:id])
    _destroy @item do
      respond_to do |format|
        format.html { return redirect_to(cms_nodes_path) }
      end
    end
  end
end
