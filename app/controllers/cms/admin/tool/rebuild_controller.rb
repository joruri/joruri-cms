# encoding: utf-8
class Cms::Admin::Tool::RebuildController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
  end

  def index
    @item = Cms::Node.new(params[:item])

    if params[:do] == 'styleseet'
      Core.messages << '--'

      results = [0, 0]

      items = Cms::Layout.where(site_id: Core.site.id)

      if @item.concept_id
        items = items.where(concept_id: @item.concept_id)
      end

      items.each do |item|
        begin
          results[0] += 1 if item.put_css_files
        rescue => e
          results[1] += 1
        end
      end

      Core.messages << "成功 #{results[0]}件"
      Core.messages << "失敗 #{results[1]}件"
    end

    unless Core.messages.empty?
      max_messages = 3000
      messages = Core.messages.join('<br />')
      if messages.size > max_messages
        messages = ApplicationController.helpers.truncate(messages, length: max_messages)
      end
      flash[:notice] = ('再構築が完了しました。<br />' + messages).html_safe
      redirect_to action: :index
    end
  end
end
