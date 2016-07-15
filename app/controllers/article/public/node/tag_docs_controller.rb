# encoding: utf-8
class Article::Public::Node::TagDocsController < Cms::Controller::Public::Base
  include Article::Controller::Feed

  def index
    @base_uri = Page.current_node.public_uri
    return redirect_to(@base_uri) if params[:reset]

    @tag = params[:tag] || params[:s_tag]
    @tag = @tag.to_s.force_encoding('utf-8')

    if request.post? || @tag =~ / /
      @tag = @tag.strip.gsub(/ .*/, '')
      return redirect_to("#{@base_uri}#{CGI.escape(@tag)}")
    end

    if @tag
      @docs = Article::Doc
              .published
              .agent_filter(request.mobile)
              .where(content_id: Page.current_node.content.id)
              .where('language_id': 1)
              .tag_is(@tag)
              .order(published_at: :desc)
              .paginate(page: params[:page],
                        per_page: (request.mobile? ? 20 : 50))
    else
      @docs = Article::Doc.none
    end

    return true if render_feed(@docs)
  end
end
