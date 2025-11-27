import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/destination.dart';
import '../theme/app_theme.dart';

class _TripMapView extends StatelessWidget {
  final GeneratedItinerary? itinerary;
  const _TripMapView({Key? key, required this.itinerary}) : super(key: key);

  List<LatLng> get _waypoints {
    if (itinerary == null) return [];
    final points = <LatLng>[];
    for (final day in itinerary!.days) {
      for (final act in day.activities) {
        // You may want to filter only destination-type activities
        if (act.location != null && act.location!.isNotEmpty && act.latitude != null && act.longitude != null) {
          points.add(LatLng(act.latitude!, act.longitude!));
        }
      }
    }
    return points;
  }

  @override
  Widget build(BuildContext context) {
    final waypoints = _waypoints;
    return FlutterMap(
      options: MapOptions(
        center: waypoints.isNotEmpty ? waypoints.first : LatLng(10.7202, 122.5621),
        zoom: 13,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tiles.stadiamaps.com/tiles/alidade_smooth/{z}/{x}/{y}{r}.png',
          subdomains: const ['a', 'b', 'c'],
        ),
        MarkerLayer(
          markers: [
            for (int i = 0; i < waypoints.length; i++)
              Marker(
                width: 40,
                height: 40,
                point: waypoints[i],
                builder: (ctx) => _NumberedMarker(number: i + 1),
              ),
          ],
        ),
      ],
    );
  }
}

class _NumberedMarker extends StatelessWidget {
  final int number;
  const _NumberedMarker({required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
        border: Border.all(color: AppTheme.teal, width: 2),
      ),
      padding: const EdgeInsets.all(8),
      child: Text(
        number.toString(),
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.teal),
      ),
    );
  }
}