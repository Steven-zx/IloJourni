import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/destination.dart';
import '../theme/app_theme.dart';
import '../widgets/minimal_map.dart';

class TripMapView extends StatelessWidget {
  final GeneratedItinerary? itinerary;
  final List<Destination> destinations;
  const TripMapView({Key? key, required this.itinerary, required this.destinations}) : super(key: key);

  List<LatLng> get _waypoints {
    if (itinerary == null) return [];
    final points = <LatLng>[];
    for (final day in itinerary!.days) {
      for (final act in day.activities) {
        final dest = destinations.cast<Destination?>().firstWhere(
          (d) => d?.name.toLowerCase() == act.name.toLowerCase(),
          orElse: () => null,
        );
        if (dest != null) {
          points.add(LatLng(dest.latitude, dest.longitude));
        }
      }
    }
    return points;
  }

  @override
  Widget build(BuildContext context) {
    final waypoints = _waypoints;
    return MinimalMap(
      center: waypoints.isNotEmpty ? waypoints.first : LatLng(10.7202, 122.5621),
      zoom: 13,
      markers: [
        for (final pt in waypoints)
          Marker(
            point: pt,
            width: 28,
            height: 36,
            alignment: Alignment.bottomCenter,
            child: const _PinMarker(),
          ),
      ],
    );
  }
}

class NumberedMarker extends StatelessWidget {
  final int number;
  const NumberedMarker({required this.number});

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

class _PinMarker extends StatelessWidget {
  const _PinMarker();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: AppTheme.navy,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 1))],
          ),
        ),
        Container(
          width: 4,
          height: 8,
          decoration: BoxDecoration(color: AppTheme.navy, borderRadius: BorderRadius.circular(2)),
        ),
      ],
    );
  }
}