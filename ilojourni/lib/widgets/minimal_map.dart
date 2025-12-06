import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MinimalMap extends StatelessWidget {
  final LatLng center;
  final double zoom;
  final List<Marker> markers;
  final bool enableRotate;

  const MinimalMap({
    super.key,
    required this.center,
    this.zoom = 13,
    this.markers = const [],
    this.enableRotate = false,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        center: center,
        zoom: zoom,
        interactionOptions: InteractionOptions(
          flags: (InteractiveFlag.pinchZoom | InteractiveFlag.drag) |
              (enableRotate ? InteractiveFlag.rotate : 0),
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.ilojourni',
          keepBuffer: 2,
          panBuffer: 1,
          maxNativeZoom: 19,
          maxZoom: 19,
          tileBuilder: (context, widget, tile) => ColorFiltered(
            colorFilter: const ColorFilter.matrix(<double>[
              0.2126, 0.7152, 0.0722, 0, 0,
              0.2126, 0.7152, 0.0722, 0, 0,
              0.2126, 0.7152, 0.0722, 0, 0,
              0,      0,      0,      1, 0,
            ]),
            child: widget,
          ),
        ),
        if (markers.isNotEmpty)
          MarkerLayer(
            markers: markers,
          ),
      ],
    );
  }
}