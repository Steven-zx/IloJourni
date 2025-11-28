import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../theme/app_theme.dart';
import '../widgets/pin_marker.dart';
import '../widgets/minimal_map.dart';
import '../data/destinations_database.dart';

class DestinationMapPoint {
  final int number;
  final String name;
  final LatLng location;
  DestinationMapPoint({required this.number, required this.name, required this.location});
}

class MapViewScreen extends StatelessWidget {
  static const route = '/map-view';
  const MapViewScreen({super.key});

  // Build a single waypoint for the provided destination id
  DestinationMapPoint? _pointFor(String? id) {
    if (id == null) return null;
    final d = DestinationsDatabase.getById(id);
    if (d == null) return null;
    return DestinationMapPoint(
      number: 1,
      name: d.name,
      location: LatLng(d.latitude, d.longitude),
    );
  }

  @override
  Widget build(BuildContext context) {
    final destId = ModalRoute.of(context)?.settings.arguments as String?;
    final singlePoint = _pointFor(destId);
    final center = singlePoint?.location ?? const LatLng(10.7202, 122.5621);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map View'),
        backgroundColor: AppTheme.teal,
      ),
      body: MinimalMap(
        center: center,
        zoom: 13,
        markers: singlePoint == null
            ? const []
            : [
                Marker(
                  width: 24,
                  height: 34,
                  alignment: Alignment.bottomCenter,
                  point: singlePoint.location,
                  child: const PinMarker(size: 24),
                ),
              ],
      ),
    );
  }
}
