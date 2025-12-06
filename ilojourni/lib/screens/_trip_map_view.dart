import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/destination.dart';
import '../theme/app_theme.dart';

class _TripMapView extends StatelessWidget {
  final GeneratedItinerary? itinerary;
  const _TripMapView({super.key, required this.itinerary});

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
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.ilojourni.app',
          keepBuffer: 2,
          panBuffer: 0,
        ),
        MarkerLayer(
          markers: [
            for (int i = 0; i < waypoints.length; i++)
              Marker(
                width: 36,
                height: 36,
                point: waypoints[i],
                child: _NumberedMarker(number: i + 1),
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
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppTheme.navy,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 1))],
      ),
      alignment: Alignment.center,
      child: Text(
        number.toString(),
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.white),
      ),
    );
  }
}