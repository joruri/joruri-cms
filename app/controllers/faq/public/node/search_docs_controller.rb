# encoding: utf-8
class Faq::Public::Node::SearchDocsController < Cms::Controller::Public::Base
  include Faq::Controller::Feed

  def pre_dispatch
    @node = Page.current_node
    @content = @node.content
    return http_error(404) unless @content
  end

  def index
    @s_cate = params[:s_category1_id].blank? ? nil : params[:s_category1_id]
    @s_cate = params[:s_category2_id] unless params[:s_category2_id].blank?
    @s_cate = params[:s_category3_id] unless params[:s_category3_id].blank?
    @s_word = params[:s_keyword] unless params[:s_keyword].blank?

    search_params = {}
    search_params['s_category_id'] = @s_cate unless @s_cate.blank?
    search_params['s_keyword']     = params[:s_keyword] unless params[:s_keyword].blank?

    doc = Faq::Doc.new.public
    doc.agent_filter(request.mobile)
    doc.and :content_id, @content.id

    size = doc.condition.where.size
    doc.search search_params
    if size == doc.condition.where.size
      @nosearch = true
      @docs = []
      return
    end

    doc.page params[:page], (request.mobile? ? 20 : 50)
    @docs = doc.find(:all, order: 'published_at DESC')
  end
end
