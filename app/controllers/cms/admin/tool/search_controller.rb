# encoding: utf-8
class Cms::Admin::Tool::SearchController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  
  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end
  
  def index
    @item  = []
    @items = []
    def @item.keyword ; @keyword ; end
    def @item.keyword=(v) ; @keyword = v ; end
     
    return true if params[:do] != 'search'
    return true if params[:item][:keyword].blank?
    @item.keyword = params[:item][:keyword]
    
    group = [ "ページ", [] ]
    item = Cms::Node.new
    item.and :site_id, Core.site.id
    item.and :model, "Cms::Page"
    item.and Condition.new do |c|
      c.or :body, 'LIKE', "%#{@item.keyword}%"
      c.or :mobile_body, 'LIKE', "%#{@item.keyword}%"
    end
    item.find(:all, :order => :id).each {|c| group[1] << [c.id, "#{c.title} #{c.public_uri}"] }
    @items << group
    
    cond = ["site_id = ? AND model = ?", Core.site.id, 'Article::Doc'] 
    Cms::Content.find(:all, :conditions => cond, :order => :id).each do |content|
      group = [ "記事：#{content.name}", [] ]
      item = Article::Doc.new
      item.and :content_id, content.id
      item.and Condition.new do |c|
        c.or :body, 'LIKE', "%#{@item.keyword}%"
        c.or :mobile_body, 'LIKE', "%#{@item.keyword}%"
      end
      item.find(:all, :order => :id).each {|c| group[1] << [c.id, c.title] }
      @items << group
    end
  end
end
