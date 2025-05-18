import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key, required String childId});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  LatLng? currentLocation;
  LatLng? targetLocation;
  List<LatLng> routePoints = [];
  final mapController = MapController();
  double currentZoom = 13.0;
  bool isFollowingUser = true;

  final Distance distance = const Distance();
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    await _getCurrentLocation();
    await _fetchLatestCoordinatesFromAPI();
  }

  Future<void> _getCurrentLocation() async {
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.denied) return;
      }

      final pos = await Geolocator.getCurrentPosition();
      final newLoc = LatLng(pos.latitude, pos.longitude);

      setState(() {
        currentLocation = newLoc;
      });

      mapController.move(newLoc, currentZoom);
    } catch (e) {
      debugPrint("GPS Error: $e");
    }
  }

  Future<void> _fetchLatestCoordinatesFromAPI() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:5000/api/status/last-coordinates'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final lat = data['Latitude'] as double;
        final lon = data['Longitude'] as double;

        final apiLocation = LatLng(lat, lon);

        setState(() {
          targetLocation = apiLocation;
        });

        mapController.move(apiLocation, currentZoom);
        _fetchRoute();
      } else {
        debugPrint('Failed to load coordinates: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching coordinates: $e');
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    setState(() => targetLocation = point);
    _fetchRoute();
  }

  Future<void> _fetchRoute() async {
    if (currentLocation == null || targetLocation == null) return;

    final from = '${currentLocation!.longitude},${currentLocation!.latitude}';
    final to = '${targetLocation!.longitude},${targetLocation!.latitude}';
    final url = 'https://router.project-osrm.org/route/v1/driving/$from;$to?overview=full&geometries=geojson';

    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final jsonBody = json.decode(res.body);
        final coords = (jsonBody['routes'][0]['geometry']['coordinates'] as List).cast<List>();
        setState(() {
          routePoints = coords.map((c) => LatLng(c[1] as double, c[0] as double)).toList();
        });
      } else {
        debugPrint('OSRM error: ${res.statusCode}');
      }
    } catch (e) {
      debugPrint('Route fetch error: $e');
    }
  }

  String _formatDistance(double m) {
    return m >= 1000 ? '${(m / 1000).toStringAsFixed(2)} km' : '${m.toStringAsFixed(0)} m';
  }

  bool _doCirclesIntersect() {
    if (currentLocation == null || targetLocation == null) return false;
    final d = distance.as(LengthUnit.Meter, currentLocation!, targetLocation!);
    return d <= 2000; // 1km radius each
  }

  @override
  Widget build(BuildContext context) {
    String distText = '';
    if (currentLocation != null && targetLocation != null) {
      final m = distance.as(LengthUnit.Meter, currentLocation!, targetLocation!);
      distText = _formatDistance(m);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Routeur'),
        backgroundColor: Colors.pinkAccent,
        actions: [
          IconButton(
            icon: Icon(isFollowingUser ? Icons.gps_fixed : Icons.gps_not_fixed),
            onPressed: () {
              setState(() {
                isFollowingUser = !isFollowingUser;
                if (isFollowingUser) _getCurrentLocation();
              });
            },
          ),
        ],
      ),
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: currentLocation ?? LatLng(48.8566, 2.3522),
          initialZoom: currentZoom,
          onPositionChanged: (pos, byGesture) {
            if (byGesture) currentZoom = pos.zoom ?? currentZoom;
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          ),
          if (routePoints.isNotEmpty)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: routePoints,
                  color: Colors.pinkAccent,
                  strokeWidth: 4,
                ),
              ],
            ),
          CircleLayer(
            circles: [
              if (currentLocation != null)
                CircleMarker(
                  point: currentLocation!,
                  radius: 1000,
                  useRadiusInMeter: true,
                  color: _doCirclesIntersect()
                      ? Colors.green.withOpacity(0.3)
                      : Colors.red.withOpacity(0.3),
                  borderStrokeWidth: 1,
                ),
              if (targetLocation != null)
                CircleMarker(
                  point: targetLocation!,
                  radius: 1000,
                  useRadiusInMeter: true,
                  color: _doCirclesIntersect()
                      ? Colors.green.withOpacity(0.3)
                      : Colors.red.withOpacity(0.3),
                  borderStrokeWidth: 1,
                ),
            ],
          ),
          MarkerLayer(
            markers: [
              if (currentLocation != null)
                Marker(
                  point: currentLocation!,
                  width: 40,
                  height: 40,
                  child: const Icon(Icons.my_location, color: Colors.blue),
                ),
              if (targetLocation != null)
                Marker(
                  point: targetLocation!,
                  width: 40,
                  height: 40,
                  child: const Icon(Icons.flag, color: Colors.red),
                ),
            ],
          ),
        ],
      ),
      bottomSheet: currentLocation == null || targetLocation == null
          ? null
          : Card(
              margin: const EdgeInsets.all(12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Distance : $distText'),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: _getCurrentLocation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pinkAccent,
                          ),
                          child: const Text('📍 Ma position'),
                        ),
                        ElevatedButton(
                          onPressed: _fetchLatestCoordinatesFromAPI,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                          child: const Text('🎲 Mon enfant'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
