import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../theme/app_theme.dart';

class DestinationMapPoint {
  final int number;
  final String name;
  final LatLng location;
  DestinationMapPoint({required this.number, required this.name, required this.location});
}

class MapViewScreen extends StatelessWidget {
  static const route = '/map-view';
  const MapViewScreen({super.key});

  // Example destination data (replace with your actual data)
  List<DestinationMapPoint> get _destinations => [
    DestinationMapPoint(number: 1, name: 'Jaro Cathedral', location: LatLng(10.7202, 122.5621)),
    DestinationMapPoint(number: 2, name: 'Molo Church', location: LatLng(10.6978, 122.5611)),
    DestinationMapPoint(number: 3, name: 'Esplanade Walk', location: LatLng(10.7125, 122.5557)),
    DestinationMapPoint(number: 4, name: 'Isla Higantes', location: LatLng(11.5000, 123.2000)),
    DestinationMapPoint(number: 5, name: 'Netong\'s Batchoy', location: LatLng(10.7082, 122.5675)),
    DestinationMapPoint(number: 6, name: 'Molo Mansion', location: LatLng(10.6975, 122.5615)),
    DestinationMapPoint(number: 7, name: 'Garin Farm', location: LatLng(10.5850, 122.4380)),
    DestinationMapPoint(number: 8, name: 'Miag-ao Church', location: LatLng(10.6431, 122.2356)),
    DestinationMapPoint(number: 9, name: 'WaterWorld Iloilo', location: LatLng(10.7482, 122.5852)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map View'),
        backgroundColor: AppTheme.teal,
      ),
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(10.7202, 122.5621),
          zoom: 12.5,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
            tileBuilder: (context, tile, child) => ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: child,
            ),
          ),
          MarkerLayer(
            markers: _destinations.map((dest) => Marker(
              width: 60,
              height: 60,
              point: dest.location,
              builder: (ctx) => _NumberedMarker(number: dest.number, label: dest.name),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

class _NumberedMarker extends StatelessWidget {
  final int number;
  final String label;
  const _NumberedMarker({required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
            border: Border.all(color: AppTheme.teal, width: 2),
          ),
          child: Text(
            number.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.teal),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)],
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
