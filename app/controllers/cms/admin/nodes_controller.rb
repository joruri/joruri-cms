# encoding: utf-8
class Cms::Admin::NodesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
    return redirect_to(cms_nodes_path(0)) if params[:reset]

    id = params[:parent] == '0' ? Core.site.node_id : params[:parent]
    @parent = Cms::Node.find(id)
  end

  def index
    @dirs = Cms::Node
            .where(site_id: Core.site.id)
            .where(parent_id: @parent.id)
            .where(directory: 1)
            .order(params[:sort], :name, :id)

    @pages = Cms::Node
             .where(site_id: Core.site.id)
             .where(parent_id: @parent.id)
             .where(directory: 0)
             .order(params[:sort], :name, :id)

    _index @pages
  end

  def search
    @items = Cms::Node
             .where(site_id: Core.site.id)
             .search(params)
             .order(params[:sort], :parent_id, directory: :desc, name: :asc)
             .paginate(page: params[:page], per_page: params[:limit])

    @skip_navi = true
    render action: :search
  end

  def show
    @item = Cms::Node.find(params[:id])
    return error_auth unless @item.readable?

    _show @item
  end

  def new
    @item = Cms::Node.new(
      concept_id: Core.concept(:id),
      site_id: Core.site.id,
      state: 'public',
      parent_id: @parent.id,
      route_id: @parent.id,
      layout_id: @parent.layout_id)
    @contents = content_options(false)
    @models   = model_options(false)
  end

  def create
    @item = Cms::Node.new(node_params)
    @item.site_id      = Core.site.id
    @item.state        = 'closed'
    @item.published_at = Core.now
    @item.directory    = (@item.model_type == :directory)
    @item.name         = 'tmp' # for validation
    @item.title        = (@item.module_name || "新規").to_s.gsub(/.*\//, '')

    @contents = content_options(false)
    @models   = model_options(false)

    _create(@item) do
      @item.name = nil # for validation
      @item.save(validate: false)
      respond_to do |format|
        format.html { return redirect_to(@item.admin_uri) }
      end
    end
  end

  def update
    exit
  end

  def destroy
    exit
  end

  def content_options(rendering = true)
    contents = []

    concept_id = params[:concept_id]
    concept_id = @item.concept_id if @item && @item.concept_id
    concept_id ||= Core.concept.id
    concept = Cms::Concept.find_by(id: concept_id)

    if concept
      concept.parents_tree.each do |c|
        contents += Cms::Content.where(concept_id: c.id).order(:name, :id)
      end
    end

    @options = []
    @options << [Cms::Lib::Modules.module_name(:cms), '']
    @options += contents.collect do |c|
      concept_name = c.concept ? "#{c.concept.name} : " : nil
      ["#{concept_name}#{c.name}", c.id]
    end
    return @options unless rendering

    concept_name = concept ? "#{concept.name}:" : nil
    @options.unshift ["// 一覧を更新しました（#{concept_name}#{contents.size + 1}件）", '']

    respond_to do |format|
      format.html { render layout: false }
    end
  end

  def model_options(rendering = true)
    content_id = params[:content_id]
    content_id = @item.content.id if @item && @item.content

    model = 'cms'
    content = Cms::Content.find_by(id: content_id)
    if content
      model = content.model
    end
    models  = Cms::Lib::Modules.directories(model)
    models += Cms::Lib::Modules.pages(model)

    @options  = []
    @options += models
    return models unless rendering

    content_name = content ? content.name : Cms::Lib::Modules.module_name(:cms)
    @options.unshift ["// 一覧を更新しました（#{content_name}:#{models.size}件）", '']

    respond_to do |format|
      format.html { render layout: false }
    end
  end

  private

  def node_params
    params.require(:item).permit(
      :concept_id, :content_id, :layout_id, :model, :parent_id, :route_id,
      :sitemap_sort_no, :sitemap_state,
      in_creator: [:group_id, :user_id]
    )
  end
end
