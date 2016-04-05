# encoding: utf-8
class Enquete::Admin::FormColumnsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  include Sys::Controller::Scaffold::Recognition
  include Sys::Controller::Scaffold::Publication
  helper Article::FormHelper

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
    return error_auth unless @content = Cms::Content.find(params[:content])
    return error_auth unless @form = Enquete::Form.find(params[:form])
    return error_auth unless Core.user.has_priv?(:read, item: @content.concept)
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end

  def index
    @items = Enquete::FormColumn
             .where(form_id: @form.id)
             .order(params[:sort], :sort_no)
             .paginate(page: params[:page], per_page: params[:limit])

    _index @items
  end

  def show
    @item = Enquete::FormColumn.find(params[:id])
    _show @item
  end

  def new
    sort_no = 1

    max_sort_no = Enquete::FormColumn
                  .where(form_id: @form.id)
                  .maximum(:sort_no)

    sort_no = (max_sort_no || 0) + 1 if max_sort_no

    @item = Enquete::FormColumn.new(state: 'public',
                                    required: '1',
                                    sort_no: sort_no)
  end

  def create
    @item = Enquete::FormColumn.new(form_column_params)
    @item.form_id = @form.id

    _create @item
  end

  def update
    @item = Enquete::FormColumn.find(params[:id])
    @item.attributes = form_column_params

    _update(@item)
  end

  def destroy
    @item = Enquete::FormColumn.find(params[:id])
    _destroy @item
  end

  private

  def form_column_params
    params.require(:item).permit(
      :state, :name, :body, :column_type, :options, :required, :column_style,
      :sort_no, in_creator: [:group_id, :user_id]
    )
  end
end
