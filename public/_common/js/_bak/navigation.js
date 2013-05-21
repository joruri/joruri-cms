// require prototype.js, cookiemanager.js

/**
 * Navigation
 */
function Navigation(settings) {
  var self = this;
  this.settings = settings;
  
  this.onLoad = function() {
    Navigation.theme();
    Navigation.fontSize();
    Navigation.ruby($(this.settings['ruby']), null, $(this.settings['notice']));
    
    if (this.settings['theme']) {
      for (var k in this.settings['theme']) {
        Event.observe($(k), 'click', function(evt) {self.theme(evt); Event.stop(evt);}, false);
      }
    }
    if (this.settings['fontSize']) {
      for (var k in this.settings['fontSize']) {
        Event.observe($(k), 'click', function(evt) {self.fontSize(evt); Event.stop(evt);}, false);
      }
    }
    if (this.settings['ruby']) {
      var k = this.settings['ruby'];
      if (k && $(k)) {
        Event.observe($(k), 'click', function(evt) {self.ruby(evt); Event.stop(evt);}, false);
      }
    }
    if (this.settings['talk']) {
      var k = this.settings['talk'];
      if (k && $(k)) {
        $(k).addClassName('talkOff');
        Event.observe($(k), 'click', function(evt) {self.talk(evt); Event.stop(evt);}, false);
      }
    }
  }
  Event.observe(window, 'load', function(){ self.onLoad() }, false);
  
  this.theme = function(evt) {
    var element = Event.element(evt);
    if (this.settings['theme'][element.id]) {
      Navigation.theme(this.settings['theme'][element.id]);
    }
  }
  
  this.fontSize = function(evt) {
    var element = Event.element(evt);
    if (this.settings['fontSize'][element.id]) {
      Navigation.fontSize(this.settings['fontSize'][element.id]);
    }
  }
  
  this.ruby = function(evt) {
    var element = Event.element(evt);
    if ($(element).className.match(/(^| )rubyOn( |$)/)) {
      Navigation.ruby(element, 'off', $(this.settings['notice']));
    } else {
      Navigation.ruby(element, 'on', $(this.settings['notice']));
    }
  }
  
  this.talk = function(evt) {
    var element = Event.element(evt);
    Navigation.talk(element, $(this.settings['player']), $(this.settings['notice']));
  }
}

/**
 * Changes the stylesheets.
 */
function Navigation_theme(theme) {
  if (theme) {
    (new CookieManager()).setCookie('navigation_theme', theme);
  } else {
    theme = (new CookieManager()).getCookie('navigation_theme');
    if (!theme) return false;
  }
  var links = document.getElementsByTagName('link');
  for (var i = 0; i < links.length; i++) {
    if (links.item(i).title != '') links.item(i).disabled = true;
  }
  for (var i = 0; i < links.length; i++) {
    if (links.item(i).title == theme) links.item(i).disabled = false;
  }
  return false;
}
Navigation.theme = Navigation_theme;

/**
 * Changes the fontsize.
 */
function Navigation_fontSize(size) {
  if (size) {
    (new CookieManager()).setCookie('navigation_font_size', size);
  } else {
    size = (new CookieManager()).getCookie('navigation_font_size');
    if (!size) return false;
  }
  document.body.style.fontSize = size;
  return false;
}
Navigation.fontSize = Navigation_fontSize;

/**
 * Toggles the Ruby.
 */
function Navigation_ruby(element, flag, noticeContainer) {
  if (!element) return false;
  
  if (flag) {
    //change
    (new CookieManager()).setCookie('navigation_ruby', flag);
    
    //redirect
    if (flag == 'on') {
      if (location.pathname.search(/\/$/i) != -1) {
        location.href = location.pathname + "index.html.r" + location.search;
      } else if (location.pathname.search(/\.html\.mp3$/i) != -1) {
        location.href = location.pathname.replace(/\.html\.mp3$/, ".html.r") + location.search;
      } else if (location.pathname.search(/\.html$/i) != -1) {
        location.href = location.pathname.replace(/\.html$/, ".html.r") + location.search;
      } else if (location.pathname.search(/\.html$/i) != -1) {
        location.href = location.pathname.replace(/\.html$/, ".html.r") + location.search;
      } else {
        location.href = location.href.replace(/#.*/, '');
      }
    } else {
      if (location.pathname.search(/\.html\.r$/i) != -1) {
        location.href = location.pathname.replace(/\.html\.r$/, ".html") + location.search;
      } else {
        location.reload();
      }
    }
    
  } else {
    // render
    if ((new CookieManager()).getCookie('navigation_ruby') == 'on') {
      if (location.pathname.search(/\/$/i) != -1) {
        location.href = location.pathname + "index.html.r" + location.search;
      } else if (location.pathname.search(/\.html$/i) != -1) {
        location.href = location.pathname.replace(/\.html/, ".html.r") + location.search;
      } else {
        element.removeClassName('rubyOff');
        element.addClassName('rubyOn');
        Navigation.showNotice(noticeContainer);
      }
    } else {
      element.removeClassName('rubyOn');
      element.addClassName('rubyOff');
    }
  }
}
Navigation.ruby = Navigation_ruby;

/**
 * Navigation Speaker.
 */
function Navigation_Talk(element, player, container) {
  Navigation.showNotice(container);
  
  if (element.className.match(/(^| )talkOn( |$)/)) {
    element.removeClassName('talkOn');
    element.addClassName('talkOff');
  } else {
    element.removeClassName('talkOff');
    element.addClassName('talkOn');
  }
  
  var uri = location.pathname;
  if (uri.match(/\/$/)) uri += 'index.html';
  uri = uri.replace(/\.html\.r$/, '.html');
  
  var now   = new Date();
  var param = '?' + now.getDay() + now.getHours();
  
  if (player) {
    uri += '.mp3' + param;
    if (player.innerHTML == '') {
      html = '<script type="text/javascript" src="/_common/swf/niftyplayer/niftyplayer.js"></script>' +
      '<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"' +
      ' codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,0,0"' +
      ' width="165" height="37" id="niftyPlayer1" align="">' +
      '<param name=movie value="/_common/swf/niftyplayer/niftyplayer.swf?file=' + uri + '&as=1">' +
      '<param name=quality value=high>' +
      '<param name=bgcolor value=#FFFFFF>' +
      '<embed src="/_common/swf/niftyplayer/niftyplayer.swf?file=' + uri + '&as=1" quality=high bgcolor=#FFFFFF' +
      ' width="165" height="37" name="niftyPlayer1" align="" type="application/x-shockwave-flash"' +
      ' swLiveConnect="true" pluginspage="http://www.macromedia.com/go/getflashplayer">' +
      '</embed>' +
      '</object>';
      player.innerHTML = html;
    } else {
      uri += '.m3u' + param;
      player.innerHTML = '';
      if ((new CookieManager()).getCookie('navigation_ruby') != 'on') {
        $('navigationNotice').remove();
      }
    }
  } else {
    location.href = uri;
  }
}
Navigation.talk = Navigation_Talk;

/**
 * Shows the notice.
 */
function Navigation_showNotice(container) {
  var notice = $('navigationNotice');
  if (!container || notice) {
    return true;
  }
  var notice = document.createElement('div'); 
  notice.id = 'navigationNotice'; 
  notice.innerHTML = 'ふりがなと読み上げ音声は，' +
    '人名，地名，用語等が正確に発音されない場合があります。';
  container.insertBefore(notice, container.firstChild);
}
Navigation.showNotice = Navigation_showNotice;
