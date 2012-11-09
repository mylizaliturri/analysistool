var map;
var selectControl;

var SHADOW_Z_INDEX = 10;
var MARKER_Z_INDEX = 11;

var animationTimer;
var currentDate;

var ini=document.getElementById('inicio').value/1;
var startDate=new Date(ini); // lower bound of when values
document.getElementById('inicio1').value=startDate.toString();
var fin=document.getElementById('fin').value/1;
var endDate=new Date(fin); // upper value of when values
document.getElementById('fin1').value=endDate.toString();

var step = 10; // seconds to advance each interval
var interval = 0.125; // seconds between each step in the animation

document.getElementById("start").onclick = startAnimation;
document.getElementById("stop").onclick = stopAnimation;
spanEl = document.getElementById("span");

filter = new OpenLayers.Filter.Comparison({
    type: OpenLayers.Filter.Comparison.BETWEEN,
    property: "when",
    lowerBoundary: startDate,
    //upperBoundary: new Date(startDate.getTime() + (parseInt(spanEl.value, 10) * 1000))
    upperBoundary: endDate
});

filterStrategy = new OpenLayers.Strategy.Filter({filter: filter});

function startAnimation() {

    if (animationTimer) {
        stopAnimation(true);
    }
    if (!currentDate) {
        currentDate = startDate;
    }
    var spanEl = document.getElementById("span");
    var next = function() {
        var span = parseInt(spanEl.value, 10);
        if (currentDate < endDate) {
            filter.lowerBoundary = currentDate;
            document.getElementById('inicio1').value= filter.lowerBoundary.toString();
            filter.upperBoundary = new Date(currentDate.getTime() + (span * 1000));
            document.getElementById('fin1').value= filter.upperBoundary.toString();
            filterStrategy.setFilter(filter);
            currentDate = new Date(currentDate.getTime() + (step * 1000));
        } else {
            stopAnimation(true);
        }
    };
    animationTimer = window.setInterval(next, interval * 1000);
}

function stopAnimation(reset) {
    window.clearInterval(animationTimer);
    animationTimer = null;
    if (reset === true) {
        currentDate = null;
    }
}

function addRoute(ruta, id) {
    var userid=eval('('+id+')');

    if (ruta!=null) {
        var locationsJSON = eval('(' + ruta + ')');
        var fromProjection = new OpenLayers.Projection("EPSG:4326"); // Transform from WGS 1984
        var toProjection = new OpenLayers.Projection("EPSG:900913"); // to Spherical Mercator Projection

        var style = {
            //externalGraphic: 'http://www.humanized.com/weblog/images/persimmon.gif',
            graphicHeight: 20,
            graphicWidth: 20,
            strokeOpacity: 0.5,
            strokeWidth: 5
        };



        //var locationsRouteLayer = new OpenLayers.Layer.Vector("LocationsRoute");
        var locationsRouteLayer = new OpenLayers.Layer.Vector("LocationsRoute", {strategies: [new OpenLayers.Strategy.Fixed(), filterStrategy]});

        for (var location in locationsJSON) {
            var locationPosition = new OpenLayers.LonLat(locationsJSON[location].longitude, locationsJSON[location].latitude).transform(fromProjection, toProjection);
            punto=new OpenLayers.Geometry.Point(locationPosition.lon, locationPosition.lat,{
                when: locationsJSON[location].time/1
            });

            var locationMarker = new OpenLayers.Feature.Vector(punto);
            locationsRouteLayer.addFeatures(locationMarker);
        }
        map.addLayer(locationsRouteLayer);
    }
}

function initMap(locations, casco) {
    map = new OpenLayers.Map("map");
    var mapnik = new OpenLayers.Layer.OSM();
    var bing = new OpenLayers.Layer.Bing({
        key: "AvMWbfAOLj7TwpafrYzZliDCtn2rjVhfErn_kE5fO2QS0FBmx0ujfB3449IZMY46", //Get your API key at https://www.bingmapsportal.com
        type: "Aerial"
    });
    var fromProjection = new OpenLayers.Projection("EPSG:4326"); // Transform from WGS 1984
    var toProjection = new OpenLayers.Projection("EPSG:900913"); // to Spherical Mercator Projection
    var position = new OpenLayers.LonLat(-116.60520, 31.86648).transform(fromProjection, toProjection); //Ensenada, BC, MX
    var zoom = 12;

    map.addLayers([mapnik, bing]);
    map.setBaseLayer(mapnik);
    map.addControl(new OpenLayers.Control.LayerSwitcher());
    map.addControl(new OpenLayers.Control.MousePosition({
        displayProjection: "EPSG:4326"
    }));
    map.setCenter(position, zoom);

    var locationsJSON = eval('(' + locations + ')');
    var perimetroJSON = eval('(' + casco + ')');

    //todo: use reviver function?
//    var locationsJSON = JSON.parse(locations, reviver);

    var styles = new OpenLayers.StyleMap({
        "default": new OpenLayers.Style(OpenLayers.Util.applyDefaults({
            externalGraphic: "/assets/maps/icons/blue-dot.png",
            backgroundGraphic: "/assets/maps/icons/balloon-shadow.png",
            graphicZIndex: MARKER_Z_INDEX,
            backgroundGraphicZIndex: SHADOW_Z_INDEX,
            backgroundXOffset: -7,
            graphicHeight: 32,
            fillOpacity: 1
        }, OpenLayers.Feature.Vector.style["default"])),
        "select": new OpenLayers.Style({
            externalGraphic: "/assets/maps/icons/red-dot.png"
        })
    });

    var locationsLayer = new OpenLayers.Layer.Vector("Locations", {styleMap: styles});

    for (var location in locationsJSON) {
        var locationPosition = new OpenLayers.LonLat(locationsJSON[location].longitude, locationsJSON[location].latitude).transform(fromProjection, toProjection);

        var locationMarker = new OpenLayers.Feature.Vector(
            new OpenLayers.Geometry.Point(locationPosition.lon, locationPosition.lat), {
                title: locationsJSON[location].name,
                description: locationsJSON[location].description
            }
        );
        locationsLayer.addFeatures(locationMarker);
    }
    map.addLayer(locationsLayer);

    var site_points = [];
    var cascoLayer = new OpenLayers.Layer.Vector("Casco");
    for (var location in perimetroJSON) {
        var locationPosition = new OpenLayers.LonLat(perimetroJSON[location].longitude, perimetroJSON[location].latitude).transform(fromProjection, toProjection);
        site_points.push(new OpenLayers.Geometry.Point(locationPosition.lon, locationPosition.lat));
    }

    var linear_ring = new OpenLayers.Geometry.LinearRing(site_points);
    polygonFeature = new OpenLayers.Feature.Vector(
        new OpenLayers.Geometry.Polygon([linear_ring]));
    cascoLayer.addFeatures([polygonFeature]);

    map.addLayer(cascoLayer);

    selectControl = new OpenLayers.Control.SelectFeature(
        locationsLayer,
        {
            clickout: true,
            toggle: false,
            multiple: false,
            hover: false,
            toggleKey: "ctrlKey", // ctrl key removes from selection
            multipleKey: "shiftKey" // shift key adds to selection
        }
    );
    map.addControl(selectControl);
    selectControl.activate();
    locationsLayer.events.on({
        'featureselected': onFeatureSelect,
        'featureunselected': onFeatureUnselect
    });
}

function addMarker(layer, markerPosition, popupClass, popupContentHTML, closeBox, overflow) {
    var feature = new OpenLayers.Feature(layer, markerPosition);
    feature.closeBox = closeBox;
    feature.popupClass = popupClass;
    feature.data.popupContentHTML = popupContentHTML;
    feature.data.overflow = (overflow) ? "auto" : "hidden";

    var marker = feature.createMarker();

    var markerClick = function (evt) {
        if (this.popup == null) {
            this.popup = this.createPopup(this.closeBox);
            map.addPopup(this.popup);
            this.popup.show();
        } else {
            this.popup.toggle();
        }
        currentPopup = this.popup;
        OpenLayers.Event.stop(evt);
    };
    marker.events.register("mousedown", feature, markerClick);

    layer.addFeatures(marker);
}


function onPopupClose(evt) {
    // 'this' is the popup.
    var feature = this.feature;
    if (feature.layer) { // The feature is not destroyed
        selectControl.unselect(feature);
    } else { // After "moveend" or "refresh" events on POIs layer all
        // features have been destroyed by the Strategy.BBOX
        this.destroy();
    }
}
function onFeatureSelect(evt) {
    feature = evt.feature;
    popup = new OpenLayers.Popup.FramedCloud(
        "featurePopup",
        feature.geometry.getBounds().getCenterLonLat(),
        null,
        "<h1>"+feature.attributes.title + "</h1>" + feature.attributes.description,
        null,
        true,
        onPopupClose
    );
    feature.popup = popup;
    popup.feature = feature;
    map.addPopup(popup, true);
}
function onFeatureUnselect(evt) {
    feature = evt.feature;
    if (feature.popup) {
        popup.feature = null;
        map.removePopup(feature.popup);
        feature.popup.destroy();
        feature.popup = null;
    }
}