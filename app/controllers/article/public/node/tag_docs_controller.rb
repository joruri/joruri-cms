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
      return redirect_to("#{@base_uri}#{CGI::escape(@tag)}")
    end
    
    if @tag
      doc = Article::Doc.new.public
      doc.agent_filter(request.mobile)
      doc.and :content_id, Page.current_node.content.id
      doc.and 'language_id', 1
      doc.tag_is @tag
      doc.page params[:page], (request.mobile? ? 20 : 50)
      @docs = doc.find(:all, :order => 'published_at DESC')
    else
      @docs = Article::Doc.find(:all, :conditions => ["0 = 1"])
    end
    
    return true if render_feed(@docs)
  end
end
