/**
 * Initializes the tinyMCE.
 */
function initTinyMCE(originalSettings) {
  var settings = {
    // General options
    language: "ja",
    mode: "specific_textareas",
    editor_selector: "mceEditor",
    theme: "advanced",
    plugins: "table,fullscreen,media,template,preview",
    //plugins: "table,searchreplace,contextmenu,fullscreen,paste,emotions,media,template,preview",
    
    // Theme options
    theme_advanced_buttons1: "undo,redo,separator,copy,paste,pasteword,separator,search,fontselect,fontsizeselect,formatselect,styleselect,separator,visualaid,tablecontrols",
    theme_advanced_buttons2: "removeformat,separator,forecolor,backcolor,separator,bold,italic,underline,strikethrough,separator,sub,sup,separator,justifyleft,justifycenter,justifyright,justifyfull,hr,separator,bullist,numlist,separator,outdent,indent,blockquote,separator,template,separator,link,unlink,anchor,code,cleanup,separator,charmap,image,media,separator,fullscreen,preview",
    theme_advanced_buttons3: "",
    theme_advanced_buttons4: "",
    theme_advanced_toolbar_location: "top",
    theme_advanced_toolbar_align: "left",
    theme_advanced_statusbar_location: "bottom",
    theme_advanced_resizing: true,
    
    // Joruri original settings.
    extended_valid_elements : "iframe[src|width|height|name|align|id|style]",
    theme_advanced_path: false,
    theme_advanced_font_sizes: "最大=large,大=medium,中=small,小=x-small",//最小=xx-small
    theme_advanced_blockformats: "h2,h3,h4",
    theme_advanced_statusbar_location : "none",
    indentation: '1em',
    relative_urls: false,
    convert_urls: false,
    remove_script_host : false,
    table_default_border: 1,
    //document_base_url : "./",
    //readonly : true,
    
    // Example content CSS (should be your site CSS)
    content_css: "/_common/themes/admin/tiny_mce.css",
    
    // Drop lists for link/image/media/template dialogs
    template_external_list_url: "/_common/js/tiny_mce/lists/template_list.js",
    external_link_list_url: "/_common/js/tiny_mce/lists/link_list.js",
    external_image_list_url: "/_common/js/tiny_mce/lists/image_list.js",
    media_external_list_url: "/_common/js/tiny_mce/lists/media_list.js",
    
    // Style formats
    style_formats: [{
      title: 'Bold text',
      inline: 'b'
    }, {
      title: 'Red text',
      inline: 'span',
      styles: {
        color: '#ff0000'
      }
    }, {
      title: 'Red header',
      block: 'h1',
      styles: {
        color: '#ff0000'
      }
    }, {
      title: 'Example 1',
      inline: 'span',
      classes: 'example1'
    }, {
      title: 'Example 2',
      inline: 'span',
      classes: 'example2'
    }, {
      title: 'Table styles'
    }, {
      title: 'Table row 1',
      selector: 'tr',
      classes: 'tablerow1'
    }],
    
    // Replace values for the template plugin
    template_replace_values: {
      //username : "Some User",
      //staffid : "991234"
    }
  };
  for (var key in originalSettings) {
    settings[key] = originalSettings[key];
  }
  tinyMCE.init(settings);
};
