$( document ).ready(function() {
  mapboxgl.accessToken = 'pk.eyJ1IjoibXVuc2hpb25jbGljayIsImEiOiJjbGQ4b3BldTMwMTA3M3ZvMjQ2M2t5azdkIn0.wtfWOmgnKfW51rkEMA8dxQ';
  const map = new mapboxgl.Map({
    container: 'map',
    zoom: 18,
    center: [74.476, 31.605],

    // Choose from Mapbox's core styles, or make your own style with Mapbox Studio
    style: 'mapbox://styles/mapbox/satellite-streets-v12'
  });

  const bounds = [[74.472, 31.611], [74.479, 31.601]];

  map.fitBounds(bounds);

  map.on('load', () => {
    map.addSource('radar', {
      'type': 'image',
      'url': 'map.png',
      'coordinates': [
        [74.471, 31.613],
        [74.478, 31.613],
        [74.478, 31.602-0.0009],
        [74.471, 31.602-0.0009]
      ]
    });

    map.addLayer({
      id: 'radar-layer',
      'type': 'raster',
      'source': 'radar',
      'paint': {
        'raster-fade-duration': 0
      }
    });
  });
  
  const geocoder = new MapboxGeocoder({
    accessToken: mapboxgl.accessToken,
    flyTo: {
      bearing: 0,
      speed: 1.25, // Make the flying slow.
      curve: 2, // Change the speed at which it zooms out.
      easing: function (t) {
        return t;
      }
    },
    mapboxgl: mapboxgl
  });
  
  // Add the geocoder to the map/
  map.addControl(geocoder);
  map.addControl(new mapboxgl.NavigationControl());
  map.addControl(new mapboxgl.GeolocateControl());
  map.addControl(new mapboxgl.ScaleControl());
  map.addControl(new mapboxgl.FullscreenControl());
  
  // // Create a default Marker and add it to the map.
  const marker1 = new mapboxgl.Marker()
    .setLngLat([74.3436, 31.4774])
    .addTo(map);
});