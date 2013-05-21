// スマートフォン用表示切り替え
// require "jquery-cookie.js"

function SmartSwitch(elem, msg) {
  if (!navigator.userAgent.match(/(Android|iPhone|iPod|MSIEMobile|Windows\sPhone)/)) return false;
  if (!msg) msg = '';
  if ($.cookie('pc_view') == 'on') {
    $(elem).html('<span class="switch">' + msg + '<a class="sp" href="#" onclick="return SmartSwitch_sp();">スマートフォン表示</a></span>');
  } else {
    $(elem).html('<span class="switch">' + msg + '<a class="pc" href="#" onclick="return SmartSwitch_pc();">PC表示</a></span>');
  }
}
function SmartSwitch_sp() {
  $.cookie('pc_view', 'off', { path: '/' });
  location.reload();
  return false;
}
function SmartSwitch_pc() {
  $.cookie('pc_view', 'on', { path: '/' });
  location.reload();
  return false;
}
