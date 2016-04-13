# encoding: utf-8
class Cms::Admin::ConceptsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer) # observe_field

    @parent = Cms::Concept.find_by(id: params[:parent])

    unless @parent
      @parent = Cms::Concept.new(name: 'コンセプト', level_no: 0)
      @parent.id = 0
    end
  end

  def index
    @items = Cms::Concept
             .where(parent_id: @parent.id)
             .where(site_id: Core.site.id)
             .order(params[:sort], :sort_no)
    _index @items
  end

  def show
    @item = Cms::Concept.find(params[:id])
    return error_auth unless @item.readable?
    _show @item
  end

  def new
    @item = Cms::Concept.new(parent_id: @parent.id,
                             state: 'public',
                             sort_no: 0)
  end

  def create
    @item = Cms::Concept.new(params[:item])
    @item.parent_id = 0 unless @item.parent_id
    @item.site_id   = Core.site.id
    @item.level_no  = @parent.level_no + 1
    _create @item
  end

  def update
    @item = Cms::Concept.find(params[:id])
    @item.attributes = params[:item]
    @item.parent_id  = 0 unless @item.parent_id
    @item.level_no   = @parent.level_no + 1

    parent = Cms::Concept.find_by(id: @item.parent_id)
    @item.level_no = (parent ? parent.level_no + 1 : 1)

    _update @item
  end

  def destroy
    @item = Cms::Concept.find(params[:id])
    _destroy @item do
      respond_to do |format|
        format.html { return redirect_to cms_concepts_path(@parent) }
      end
    end
  end

  def layouts(_rendering = true)
    layouts = []
    concept = nil

    if params[:concept_id].to_i > 0
      concept = Cms::Concept.find_by(id: params[:concept_id])
    elsif params[:parent].to_i > 0
      if node = Cms::Node.find_by(id: params[:parent])
        concept = node.inherited_concept
      end
    else
      concept = Core.concept(:id)
    end

    concept.parents_tree.each { |c| layouts += c.layouts }
    layouts = layouts.collect { |i| ["#{i.concept.name} : #{i.title}", i.id] }

    concept_name = concept ? "#{concept.name}:" : nil
    @layouts = [["// 一覧を更新しました（#{concept_name}#{layouts.size}件）", '']] + layouts

    respond_to do |format|
      format.html { render layout: false }
    end
  end
end
