# encoding: utf-8
class Cms::Admin::PreviewController < Cms::Controller::Admin::Base
  after_filter :replace_preview_data
  
  def index
    path = Core.request_uri.gsub(/^#{Regexp.escape(cms_preview_path)}/, "")
    
    render_preview(path, :mobile => Page.mobile?, :smart_phone => request.smart_phone?, :preview => true)
  end

  def render_preview(path, options = {})
    Core.publish = true unless options[:preview]
    mode = Core.set_mode('preview')
    
    Page.initialize
    Page.site   = options[:site] || Core.site
    Page.uri    = path
    Page.mobile = options[:mobile]
    
    node = Core.search_node(path)
    env  = {}
    opt  = _routes.recognize_path(node, env)
    ctl  = opt[:controller]
    act  = opt[:action]
    
    opt.each {|k,v| params[k] = v }
    
    res = render_component :controller => ctl, :action => act, :params => params, :jpmobile => (options[:smart_phone] ? envs_to_request_as_smart_phone : nil)
    response.content_type = res.content_type
  end

protected
  def replace_preview_data
    return if response.content_type != 'text/html' && response.content_type != 'application/xhtml+xml'
    return if response.body.class != String
    
    mobile   = Page.mobile? ? 'm' : ''
    base_uri = "/_preview/#{format('%08d', Page.site.id)}#{mobile}"
    
    response.body = response.body.gsub(/<a[^>]+?href="\/[^"]*?"[^>]*?>/i) do |m|
      if m =~ /href="\/_(files|emfiles|layouts)\//
        m
      else
        m.gsub(/^(<a[^>]+?href=")(\/[^"]*?)("[^>]*?>)/i, '\\1' + base_uri + '\\2\\3')
      end
    end
    
    ## preview mark
    html = %Q(<div id="cmsPreviewMark") +
      %Q( style="position: absolute; top: 0px; left: 0px; width: 80px; margin: 1px; padding: 2px; ) +
      %Q(   border: 1px solid #777; background-color: #dfd; ) +
      %Q(   line-height: 1.5; font-family: sans-serif; text-align: center; cursor: pointer; ") +
      %Q( onclick="document.getElementById('cmsPreviewMark').style.display='none';" ) +
      %Q(>プレビュー</div>)
    response.body = response.body.gsub(/(<body[^>]*?>)/i, '\\1' + html)
  end
end
