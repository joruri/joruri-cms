//<script type="text/javascript">

function MapEditor(map) {
  this.map        = map;
  this.markers    = {}
  this.centerDisp = 'centerDisp';
  this.zoomDisp   = 'zoomDisp';
  this.clickDisp  = 'clickDisp';
  this.clicked    = null;
  
  this.syncMap = function() {
    var pos = this.map.getCenter();
    if (pos) {
      document.getElementById(this.centerDisp + 'Lat').value = pos.lat();
      document.getElementById(this.centerDisp + 'Lng').value = pos.lng();
    }
    document.getElementById(this.zoomDisp).value = this.map.getZoom();
  }
  
  this.setMapInfo = function(name) {
    var pos = this.map.getCenter();
    if (pos) {
      document.getElementById(name + 'Lat').value = pos.lat();
      document.getElementById(name + 'Lng').value = pos.lng();
    }
    document.getElementById(name + 'Zoom').value = this.map.getZoom();
  }
  
  this.syncClick = function(event) {
    if (this.clicked) {
      this.clicked.setMap();
    }
    if (event) {
      document.getElementById(this.clickDisp + 'Lat').value = event.latLng.lat();
      document.getElementById(this.clickDisp + 'Lng').value = event.latLng.lng();
      this.clicked = new google.maps.Marker({
        position: event.latLng,
        map: this.map,
        icon: 'http://maps.google.co.jp/mapfiles/ms/icons/ltblue-dot.png'
      });
    }
  }
  
  this.search = function(name, event) {
    if (event) {
      var key = (event.keyCode != 0 && event.keyCode != 229) ? event.keyCode : event.charCode;
      if (key != 13) return;
    }
    var geocoder = new google.maps.Geocoder();
    var address  = document.getElementById(name).value;
    var _this    = this;
    geocoder.geocode({'address': address},
      function(results, status) {
        if (status == google.maps.GeocoderStatus.OK) {
          _this.map.setCenter(results[0].geometry.location);
          //var marker = new google.maps.Marker({
          //    map: _this.map, 
          //    position: results[0].geometry.location
          //});
        } else {
          alert("座標を取得できませんでした。");
        }
      }
    );
  }
  
  this.setMarker = function(name) {
    if (!this.clicked) {
      alert("座標を指定してください。");
      return;
    }
    var pos = this.clicked.getPosition();
    document.getElementById(name + 'Lat').value = pos.lat();
    document.getElementById(name + 'Lng').value = pos.lng();
    
    if (this.markers[name]) {
      this.markers[name].setMap();
    }
    this.markers[name] = new google.maps.Marker({
      title: document.getElementById(name + 'Name').value,
      position: new google.maps.LatLng(pos.lat(), pos.lng()),
      map: this.map
    });
    var infowindow = new google.maps.InfoWindow({
      content: document.getElementById(name + 'Name').value,
      disableAutoPan: false
    });
    var _this = this;
    google.maps.event.addListener(this.markers[name], 'click', function() {
      infowindow.open(this.map, _this.markers[name]);
    });
  }
  
  this.unsetMarker = function(name) {
    document.getElementById(name + 'Name').value = '';
    document.getElementById(name + 'Lat').value  = '';
    document.getElementById(name + 'Lng').value  = '';
    if (this.markers[name]) {
      this.markers[name].setMap();
    }
  }
}
