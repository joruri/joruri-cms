/* admin.js */

jQuery.extend(jQuery.fn, {
  // toggle open
  toggleOpen: function(target, openLabel, closeLabel) {
    if (!openLabel)  openLabel  = "開く▼";
    if (!closeLabel) closeLabel = "閉じる▲";
    if (jQuery(target).css('display') == 'none') {
      jQuery(this).html(closeLabel);
    } else {
      jQuery(this).html(openLabel);
    }
    jQuery(target).toggle();
    return false;
  }
});

// init
$(function() {
  
  // jquery-ui
  $('input.date').datepicker({ dateFormat: 'yy-mm-dd' });
  $('input.datetime').datetimepicker({
    dateFormat: 'yy-mm-dd',
    controlType: 'select',
    timeFormat: 'HH:mm',
    minuteGrid: 15
  });
  
  // navi.sites, navi.concepts
  $('#currentNaviSite').click(function(){
    return Admin_toggleNavi($(this), $('#naviSites'));
  });
  $('#currentNaviConcept').click(function(){
    return Admin_toggleNavi($(this), $('#naviConcepts'));
  });
  
  // inline files
  $('#inlineFiles iframe').load(function() {
    $(this).css('height', $(this).contents().find('body').height() + 10 + 'px');
  });
  
});

// toggle navi
function Admin_toggleNavi(src, dst) {
  // visible
  if (dst.is(':visible')) {
    $('#naviSites').hide();
    $('#naviConcepts').hide();
    $('#content').show();
    return false;
  }
  // hidden
  if ($(dst).attr('id')) {
    $('#naviSites').hide();
    $('#naviConcepts').hide();
    $('#content').hide();
    dst.show();
    return false;
  }
  // load 
  jQuery.ajax({
    url: src.attr('href'),
    success: function(data, type) {
      $('#naviSites').hide();
      $('#naviConcepts').hide();
      $('#content').hide();
      $('#content').before(data);
    }
  });
  return false;
}
