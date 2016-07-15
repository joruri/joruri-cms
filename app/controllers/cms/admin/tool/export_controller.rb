# encoding: utf-8
class Cms::Admin::Tool::ExportController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end

  def index
    @item = Cms::Model::Tool::Export.new
    return unless request.post?

    @item.attributes = export_params
    return unless @item.valid?

    ## concept
    @concept = Cms::Concept.find_by(id: @item.concept_id)
    return unless @concept

    export = {
      layouts: [],
      pieces: []
    }

    ## layout
    if @item.target && @item.target[:layout]
      @concept.layouts.each do |layout|
        data = {}
        data[:layout] = layout

        export[:layouts] << { layout: data }
      end
    end

    ## piece
    export[:pieces] = []
    if @item.target && @item.target[:piece]
      @concept.pieces.each do |piece|
        data = {}
        data[:piece]     = piece
        data[:settings]  = piece.settings
        if piece.content
          data[:content]          = piece.content
          data[:content_concepts] = piece.content.concept.parents_tree.collect(&:name)
        end

        if piece.model == 'Cms::Link'
          cond = { piece_id: piece.id }
          data[:link_items] = Cms::PieceLinkItem.where(cond)
        end

        export[:pieces] << { piece: data }
      end
    end

    filename = "export_#{@concept.name}_#{Time.now.to_i}.json"
    filename = filename.gsub(/[\/\<\>\|:"\?\*\\]/, '_')
    filename = URI.escape(filename) if request.env['HTTP_USER_AGENT'] =~ /MSIE/
    send_data export.to_json, type: 'application/json', filename: filename
  end

  private

  def export_params
    params.require(:item).permit(:concept_id, target: [:layout, :piece])
  end
end
