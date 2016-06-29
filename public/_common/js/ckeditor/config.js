/**
 * @license Copyright (c) 2003-2015, CKSource - Frederico Knabben. All rights reserved.
 * For licensing, see LICENSE.md or http://ckeditor.com/license
 */

CKEDITOR.editorConfig = function( config ) {
	// Define changes to default configuration here. For example:
	// config.language = 'fr';
	// config.uiColor = '#AADC6E';

  	// ツールバーの設定
    // http://docs.cksource.com/ckeditor_api/symbols/CKEDITOR.config.html#.toolbar_Full
    if (cms && cms.Page && cms.Page.smart_phone) {
      config.toolbar = [
        { name: 'styles',      items : [ 'Format' ] },
        { name: 'basicstyles', items : [ 'TextColor','Bold','Italic','Underline','Strike' ] },
        '/',
        { name: 'paragraph',   items : [ 'NumberedList','BulletedList','-','JustifyLeft','JustifyCenter','JustifyRight' ] },
        { name: 'links',       items : [ 'CmsLink','CmsUnlink' ] },
        { name: 'insert',      items : [ 'Image' ] }
      ];
    } else {
      config.toolbar = [
        { name: 'document',    items : [ 'Source','-','DocProps','Preview','-','Templates' ] },
        { name: 'clipboard',   items : [ 'Cut','Copy','Paste','PasteText','PasteFromWord','-','Undo','Redo' ] },
        { name: 'styles',      items : [ 'FontSize','Font','Format','Styles' ] },
        { name: 'editing',     items : [ 'Find','Replace','-','SelectAll' ] },
        { name: 'tools',       items : [ 'Maximize', 'ShowBlocks' ] },
        '/',
        { name: 'basicstyles', items : [ 'TextColor','Bold','Italic','Underline','Strike','Subscript','Superscript','-','RemoveFormat' ] },
        { name: 'paragraph',   items : [ 'NumberedList','BulletedList','-','Outdent','Indent','-','Blockquote','CreateDiv','-','JustifyLeft','JustifyCenter','JustifyRight','JustifyBlock' ] },
        { name: 'links',       items : [ 'CmsLink','CmsUnlink','CmsAnchor' ] },
        { name: 'insert',      items : [ 'Image','Table','HorizontalRule','SpecialChar','PageBreak','Flash','Iframe','Youtube','Audio','Video' ] }
      ];
    }

    // 外部CSSを読み込み
    var css = [config.contentsCss];
    css.push(css[0].substring(0, css[0].lastIndexOf('/')+1) + 'file_icons.css');
    css.push(css[0].substring(0, css[0].lastIndexOf('/')+1) + 'cms_contents.css');
    config.contentsCss = css;

    // フォントサイズをパーセンテージに変更
    config.fontSize_sizes = '10px/71.53%;12px/85.71%;14px(標準)/100%;16px/114.29%;18px/128.57%;21px/150%;24px/171.43%;28px/200%';

    // フォーマットからh1を除外
    config.format_tags = 'p;h2;h3;h4;h5;h6;pre;address;div';

    // 使用するテンプレート
    config.templates_files = [ '/_common/js/ckeditor/plugins/templates/templates/cms_template.js' ];
    config.templates = 'cms';

    // インデント
    config.indentOffset = 1;
    config.indentUnit = 'em';

    // カラーコード制限
    config.colorButton_colors = '000000,333333,663333,420401,993333,660000,CC0000,A9180D,993300,663300,666633,424006,666600,336600,336633,003F04,00750E,336666,003333,006666,006699,336699,024577,0033FF,0033CC,003399,333366,000033,3333CC,333399,000066,3333FF,0000FF,0000CC,000099,3300FF,3300CC,330099,6633CC,663399,330066,6600FF,6600CC,660099,663366,330033,993399,660066,990099,990066,993366,660033,CC0066,CC0033,990033';

    // その他のカラーコード選択を許可しない
    config.colorButton_enableMore = false;

    // テンプレート内容の置き換えしない
    config.templates_replaceContent = false;

    // プラグイン
    config.extraPlugins = 'youtube,audio,video,zomekilink';

    // tagの許可
    config.allowedContent = true;

    // Wordからの貼付で装飾を削除する
    config.pasteFromWordRemoveFontStyles = true;
    config.pasteFromWordRemoveStyles = true;
  };

  // スタイルの設定
  CKEDITOR.stylesSet.add('my_styles', [
    // Block-level styles
    { name: '枠線', element: 'p', styles: { 'border': '1px solid #999' , 'padding' : '10px' } },

    // Inline styles
    { name: '強調（赤文字）', element: 'span', styles: { 'color': '#e00' } }
  ]);

  CKEDITOR.config.stylesSet = 'my_styles';
  CKEDITOR.config.coreStyles_strike = { element : 'del' };
  CKEDITOR.config.coreStyles_underline = { element : 'ins' };
