# encoding: utf-8
class Article::Admin::Docs::RecognizeController < Article::Admin::DocsController
  def index
    item = Article::Doc.new
    if @recognition_type == 'with_admin' && Core.user.has_auth?(:manager)
      item.join_creator
      item.join_recognition
      cond = Condition.new do |c|
        c.or "sys_recognitions.user_id", Core.user.id
        c.or 'sys_recognitions.recognizer_ids', 'REGEXP', "(^| )#{Core.user.id}( |$)"
        c.or "sys_recognitions.info_xml", 'LIKE', '%<admin/>%'
      end
      item.and cond
      item.and "#{item.class.table_name}.state", 'recognize'
    else
      item.recognizable
    end
    
    item.and :content_id, @content.id
    item.search params
    item.page  params[:page], params[:limit]
    item.order params[:sort], 'updated_at DESC'
    @items = item.find(:all)
    _index @items
  end
end
