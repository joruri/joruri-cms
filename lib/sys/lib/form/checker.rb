# encoding: utf-8
class Sys::Lib::Form::Checker
  @links   = nil
  @alts    = nil
  
  def check_link(text)
    @links ||= {}
    begin
      timeout(20) do
        text.scan(/href="([^"]+)"/i).each do |m|
          uri = m[0]
          uri = ::File.join(Core.site.full_uri, uri) if uri =~ /^\//
          next if uri =~ /^(#|mailto:|javascript:)/i
          next if uri !~ /^https?:/i
          uri = CGI::unescapeHTML(uri)
          @links[uri] = ::Util::Http.exists?(uri) unless @links.key?(uri)
        end
      end
    rescue TimeoutError
      @links['Timeout(20sec)'] = false
    end
    return @links.index(false) ? false : true
  end
  
  def errors
    return false if @links && @links.index(false)
    return false if @alts && @alts.index(false)
    return true
  end
  
  def notice_messages(options = {})
    return nil if @links.blank? && @alts.blank?
    
    html  = %Q(<div class="noticeExplanation" id="noticeExplanation">)
    html += %Q(<h2>リンクチェック結果</h2>)
    
    if @links.size > 0
      html += %Q(<p>次のURLを確認しました。</p><ul>)
      @links.each do |uri, res|
        res = res ? %Q(<span class="success">成功</span>) : %Q(<span class="failed">失敗</span>)
        html += %Q(<li>#{uri}　#{res}</li>)
      end
      html += %Q(</ul>)
    end
    
    if options[:checkbox].is_a?(String) && @links.index(false)
      html += %Q(<div class="checkbox">#{options[:checkbox]}</div>)
    end
    
    html += %Q(</div>)
    html.html_safe
  end
end