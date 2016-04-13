# encoding: utf-8
class Cms::Admin::Content::SettingsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
    @content = Cms::Content.find(params[:content])
    return error_auth unless @content
    return error_auth unless @content.editable?

    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end

  def model
    return @model_class if @model_class
    mclass = self.class.to_s
                 .gsub(/^(\w+)::Admin/, '\1')
                 .gsub(/Controller$/, '')
                 .singularize
    mclass.constantize
    @model_class = mclass.constantize
  rescue
    @model_class = Cms::Content
  end

  def index
    @items = model.configs(@content)
    _index @items
  end

  def show
    @item = model.config(@content, params[:id])
    _show @item
  end

  def new
    error_auth
  end

  def create
    error_auth
  end

  def update
    @item = model.config(@content, params[:id])
    @item.attributes = settings_params
    _update @item
  end

  def destroy
    error_auth
  end

  private

  def settings_params
    params.require(:item).permit(:value)
  end
end
