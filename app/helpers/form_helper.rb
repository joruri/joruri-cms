# encoding: utf-8
module FormHelper
  
  ## tinyMCE
  def init_tiny_mce(options = {})
    settings = []
    options.each do |k, v|
      v = %Q("#{v}") if v.class == String
      settings << "#{k}:#{v}"
    end
    [
      javascript_include_tag("/_common/js/tiny_mce/tiny_mce.js"),
      javascript_include_tag("/_common/js/tiny_mce/init.js"),
      javascript_tag("initTinyMCE({#{settings.join(',')}});")
    ].join("\n").html_safe
  end
  
  def submission_label(name)
    {
      :add       => '追加する',
      :create    => '作成する',
      :register  => '登録する',
      :edit      => '編集する',
      :update    => '更新する',
      :change    => '変更する',
      :delete    => '削除する',
      :make      => '作成する'
    }[name]
  end

  def submit(*args)
    make_tag = Proc.new do |_name, _label|
      _label ||= submission_label(_name) || _name.to_s.humanize
      submit_tag _label, :name => "commit_#{_name}"
    end
    
    h = '<div class="submitters">'
    if args[0].is_a?(String) || args[0].class == Symbol
      h += make_tag.call(args[0], args[1])
    elsif args[0].class == Hash
      args[0].each {|k, v| h += make_tag.call(k, v) }
    elsif args[0].class == Array
      args[0].each {|v, k| h += make_tag.call(k, v) }
    end
    h += '</div>'
    h.html_safe
  end
  
  def disable_enter_key_js
    render :partial => 'sys/admin/_partial/disable_enter_key/js'
  end
  
  def use_text_range_js
    render :partial => 'sys/admin/_partial/text_range/js'
  end
  
  def observe_field(field, params)
    on     = params[:on] ? params[:on].to_s : "change"
    url    = url_for(params[:url])
    method = params[:method] ? params[:method].to_s : 'get'
    with   = params[:with]
    update = params[:update]
    before = params[:before]
    
    data  = []
    data << "#{with}=' + encodeURIComponent($('##{field}').val()) + '" if with
    data << "authenticity_token=' + encodeURIComponent('#{form_authenticity_token}') + '" if method == 'post'
    data = data.join('&')
    
    h  = '<script type="text/javascript">' + "\n//<![CDATA[\n"
    h += "$(function() {"
    h += "$('##{field}').bind('#{on}', function() {"
    h += "#{before};" if before
    h += "jQuery.ajax({"
    h += "data:'#{data}',"
    h += "url:'#{url}',"
    h += "success:function(response){ $('##{update}').html(response) }"
    h += "})"
    h += "})"
    h += "});"
    h += "\n//]]>\n</script>"
    h.html_safe
  end

end