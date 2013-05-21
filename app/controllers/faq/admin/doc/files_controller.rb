# encoding: utf-8
class Faq::Admin::Doc::FilesController < Article::Admin::Doc::FilesController
  
  def pre_dispatch
    simple_layout
    
    @parent  = params[:parent]
    @tmp     = true if @parent.size == 32
    @content = Faq::Content::Doc.find_by_id(params[:content]) if params[:content]
    
    return http_error(404) if @content.nil? || @content.model != 'Faq::Doc'
  end
end
