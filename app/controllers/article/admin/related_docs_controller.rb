# encoding: utf-8
require 'csv'
class Article::Admin::RelatedDocsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  layout :select_layout

  def pre_dispatch
    @content = Cms::Content.find(params[:content])
    return error_auth unless @content
    return error_auth unless Core.user.has_priv?(:read, item: @content.concept)
  end

  def show
    @item = Article::Doc.find_by(id: params[:id])
    @doc = {
      id: @item.id,
      title: @item.title,
      link: @item.state == 'public' ? view_context.link_to(@item.title, @item.public_full_uri, target: 'preview') : @item.title,
      name: @item.name,
      content_id: @item.content_id,
      updated_at: @item.updated_at.strftime('%Y/%m/%d %H:%M'),
      status: @item.status.name,
      user_name: @item.creator.user.try(:name),
      group_name: @item.creator.group.try(:name)
    }
    render json: @doc
  end
end
