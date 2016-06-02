# encoding: utf-8
module FormHelper
  ## CKEditor

  def is_ckeditor
    case Joruri.config[:cms_editor]
    when 'ckeditor'
      return true
    when 'tiny_mce'
      return false
    else
      return true
    end
  end

  def editor_class
    if is_ckeditor
      'ckeditor'
    else
      'mceEditor'
    end
  end

  def editor_wrapper_class
    if is_ckeditor
      'cke_editor_wrapper'
    else
      'mceEditor'
    end
  end

  def init_editor(options = {})
    if is_ckeditor
      init_ckeditor(options)
    else
      init_tiny_mce(options)
    end
  end

  ## ckeditor
  def init_ckeditor(options = {})
    settings = []
    if options[:document_base_url].present?
      options[:baseHref] = options[:document_base_url]
      options.delete(:document_base_url)
    end
    if options[:readonly].present?
      options[:readOnly] = options[:readonly]
      options.delete(:readonly)
    end
    # リードオンリーではツールバーを表示しない・リンクを動作させる
    unless (options[:toolbarStartupExpanded] = !options[:readOnly])
      settings.push(<<-EOS)
        CKEDITOR.on('instanceReady', function (e) {
          $('#'+e.editor.id+'_top').hide();
          var links = $('#'+e.editor.id+'_contents > iframe:first').contents().find('a');
          for (var i = 0; i < links.length; i++) {
            $(links[i]).click(function (ee) { location.href = ee.target.href; });
          }
        });
      EOS
    end

    settings.concat(options.map {|k, v|
      %Q(CKEDITOR.config.#{k} = #{v.kind_of?(String) ? "'#{v}'" : v};)
    })

    [ '<script type="text/javascript" src="/_common/js/ckeditor/ckeditor.js"></script>',
      javascript_tag(settings.join) ].join.html_safe
  end

  ## tinyMCE
  def init_tiny_mce(options = {})
    settings = []
    options.each do |k, v|
      v = %("#{v}") if v.class == String
      settings << "#{k}:#{v}"
    end
    [
      javascript_include_tag('/_common/js/tiny_mce/tiny_mce.js'),
      javascript_include_tag('/_common/js/tiny_mce/init.js'),
      javascript_tag("initTinyMCE({#{settings.join(',')}});")
    ].join("\n").html_safe
  end


  def submission_label(name)
    {
      add: '追加する',
      create: '作成する',
      register: '登録する',
      edit: '編集する',
      update: '更新する',
      change: '変更する',
      delete: '削除する',
      make: '作成する'
    }[name]
  end

  def submit(*args)
    make_tag = proc do |_name, _label|
      _label ||= submission_label(_name) || _name.to_s.humanize
      submit_tag _label, name: "commit_#{_name}"
    end

    h = '<div class="submitters">'
    if args[0].is_a?(String) || args[0].class == Symbol
      h += make_tag.call(args[0], args[1])
    elsif args[0].class == Hash
      args[0].each { |k, v| h += make_tag.call(k, v) }
    elsif args[0].class == Array
      args[0].each { |v, k| h += make_tag.call(k, v) }
    end
    h += '</div>'
    h.html_safe
  end

  def disable_enter_key_js
    render partial: 'sys/admin/_partial/disable_enter_key/js'
  end

  def use_text_range_js
    render partial: 'sys/admin/_partial/text_range/js'
  end

  def observe_field(field, params)
    on     = params[:on] ? params[:on].to_s : 'change'
    url    = url_for(params[:url])
    method = params[:method] ? params[:method].to_s : 'get'
    with   = params[:with]
    update = params[:update]
    before = params[:before]

    data = []
    data << "#{with}=' + encodeURIComponent($('##{field}').val()) + '" if with
    data << "authenticity_token=' + encodeURIComponent('#{form_authenticity_token}') + '" if method == 'post'
    data = data.join('&')

    h  = '<script type="text/javascript">' + "\n//<![CDATA[\n"
    h += '$(function() {'
    h += "$('##{field}').bind('#{on}', function() {"
    h += "#{before};" if before
    h += 'jQuery.ajax({'
    h += "data:'#{data}',"
    h += "url:'#{url}',"
    h += "success:function(response){ $('##{update}').html(response) }"
    h += '})'
    h += '})'
    h += '});'
    h += "\n//]]>\n</script>"
    h.html_safe
  end
end
