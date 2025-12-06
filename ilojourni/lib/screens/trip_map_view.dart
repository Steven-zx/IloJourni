import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/destination.dart';
import '../theme/app_theme.dart';
import '../widgets/minimal_map.dart';

class TripMapView extends StatelessWidget {
  final GeneratedItinerary? itinerary;
  final List<Destination> destinations;
  final String selectedDay;
  const TripMapView({super.key, required this.itinerary, required this.destinations, this.selectedDay = 'All'});

  List<MapEntry<LatLng, int>> get _numberedWaypoints {
    if (itinerary == null) return [];
    final points = <MapEntry<LatLng, int>>[];
    int number = 0;
    
    if (selectedDay == 'All') {
      for (final day in itinerary!.days) {
        for (final act in day.activities) {
          if (act.type.toLowerCase() == 'transport') continue;
          final dest = destinations.firstWhere(
            (d) => d.name.toLowerCase() == act.name.toLowerCase(),
            orElse: () => Destination(
              id: '',
              name: '',
              description: '',
              district: '',
              category: '',
              latitude: 0,
              longitude: 0,
              image: '',
              entranceFee: 0,
              estimatedTime: '',
              tags: const [],
              openingHours: '',
            ),
          );
          if (dest.name.isNotEmpty) {
            number++;
            points.add(MapEntry(LatLng(dest.latitude, dest.longitude), number));
          }
        }
      }
    } else {
      final dayNumber = int.parse(selectedDay.split(' ')[1]);
      final day = itinerary!.days.firstWhere((d) => d.dayNumber == dayNumber, orElse: () => itinerary!.days.first);
      for (final act in day.activities) {
        if (act.type.toLowerCase() == 'transport') continue;
        final dest = destinations.firstWhere(
          (d) => d.name.toLowerCase() == act.name.toLowerCase(),
          orElse: () => Destination(
            id: '',
            name: '',
            description: '',
            district: '',
            category: '',
            latitude: 0,
            longitude: 0,
            image: '',
            entranceFee: 0,
            estimatedTime: '',
            tags: const [],
            openingHours: '',
          ),
        );
        if (dest.name.isNotEmpty) {
          number++;
          points.add(MapEntry(LatLng(dest.latitude, dest.longitude), number));
        }
      }
    }
    return points;
  }

  @override
  Widget build(BuildContext context) {
    final waypoints = _numberedWaypoints;
    return MinimalMap(
      center: waypoints.isNotEmpty ? waypoints.first.key : LatLng(10.7202, 122.5621),
      zoom: 13,
      markers: [
        for (final entry in waypoints)
          Marker(
            point: entry.key,
            width: 40,
            height: 40,
            alignment: Alignment.center,
            child: NumberedMarker(number: entry.value),
          ),
      ],
    );
  }
}

class NumberedMarker extends StatelessWidget {
  final int number;
  const NumberedMarker({super.key, required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppTheme.teal,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 2))],
      ),
      alignment: Alignment.center,
      child: Text(
        number.toString(),
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.white),
      ),
    );
  }
}