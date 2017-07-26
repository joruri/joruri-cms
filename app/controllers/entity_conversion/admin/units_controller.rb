# encoding: utf-8
class EntityConversion::Admin::UnitsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    @content = Cms::Content.find(params[:content])
    return error_auth unless @content
    return error_auth unless Core.user.has_priv?(:read, item: @content.concept)

    return redirect_to action: 'index' if params[:reset]
  end

  def index
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

  def show
    @item = EntityConversion::Unit.find(params[:id])
    _show @item
  end

  def new
    @item = EntityConversion::Unit.new(ldap: 1,
                                       sort_no: 0,
                                       web_state: 'public')
  end

  def create
    @item = EntityConversion::Unit.new(unit_params)
    @item.content_id = @content.id

    if params[:sync]
      sync(@item)
      return render(:new)
    end

    _create @item, location: entity_conversion_units_path
  end

  def update
    @item = EntityConversion::Unit.find(params[:id])
    @item.attributes = unit_params

    if params[:sync]
      sync(@item)
      return render(:edit)
    end

    _update @item, location: entity_conversion_units_path
  end

  def destroy
    @item = EntityConversion::Unit.find(params[:id])

    _destroy @item, location: entity_conversion_units_path
  end

  protected

  def sync(item)
    return false if item.old_id.blank?

    group = Sys::Group.find_by(id: item.old_id)
    return false unless group

    item.code        = group.code
    item.name        = group.name
    item.name_en     = group.name_en
    item.ldap        = group.ldap
    item.sort_no     = group.sort_no
    item.web_state   = group.web_state
    item.layout_id   = group.layout_id
    item.email       = group.email
    item.tel         = group.tel
    item.outline_uri = group.outline_uri

    true
  end

  private

  def unit_params
    params.require(:item).permit(
      :state, :parent_id, :new_parent_id, :code, :name, :name_en, :ldap,
      :sort_no, :web_state, :layout_id, :email, :tel, :outline_uri, :old_id
    )
  end
end
