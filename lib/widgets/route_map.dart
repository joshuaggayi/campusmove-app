import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../map_data.dart';
import '../models.dart';

/// Map of a route: numbered markers at each stage joined by a line.
/// Green = start, red = destination. Needs an internet connection for tiles.
class RouteMap extends StatelessWidget {
  final List<RouteStage> stages;
  final bool interactive;

  const RouteMap({super.key, required this.stages, this.interactive = false});

  @override
  Widget build(BuildContext context) {
    final stops = <_Stop>[];
    for (final s in stages) {
      final point = kStageCoords[s.name];
      if (point != null) stops.add(_Stop(s, point));
    }

    if (stops.isEmpty) {
      return const Center(child: Text('No map data for this route yet.'));
    }

    final points = stops.map((s) => s.point).toList();
    final color = Theme.of(context).colorScheme.primary;

    return FlutterMap(
      options: MapOptions(
        initialCenter: points.first,
        initialZoom: 13,
        // Fit all stages on screen. A single point falls back to the zoom above.
        initialCameraFit: points.length > 1
            ? CameraFit.bounds(
                bounds: LatLngBounds.fromPoints(points),
                padding: const EdgeInsets.all(40),
              )
            : null,
        interactionOptions: InteractionOptions(
          // The small map sits inside a scrolling page, so it only allows
          // zooming. The full screen map also allows dragging.
          flags: interactive
              ? InteractiveFlag.all & ~InteractiveFlag.rotate
              : InteractiveFlag.pinchZoom | InteractiveFlag.doubleTapZoom,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'ug.ac.mubs.campusmove',
        ),
        PolylineLayer(
          polylines: [
            Polyline(points: points, strokeWidth: 5, color: color),
          ],
        ),
        MarkerLayer(
          markers: [
            for (var i = 0; i < stops.length; i++)
              Marker(
                point: stops[i].point,
                width: 34,
                height: 34,
                child: _MarkerDot(
                  label: '${i + 1}',
                  color: i == 0
                      ? Colors.green.shade700
                      : (i == stops.length - 1 ? Colors.red.shade700 : color),
                ),
              ),
          ],
        ),
        const SimpleAttributionWidget(
          source: Text('OpenStreetMap contributors'),
        ),
      ],
    );
  }
}

class _Stop {
  final RouteStage stage;
  final LatLng point;
  const _Stop(this.stage, this.point);
}

class _MarkerDot extends StatelessWidget {
  final String label;
  final Color color;

  const _MarkerDot({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black38)],
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}

/// Full screen version with dragging and zooming.
class FullMapScreen extends StatelessWidget {
  final String title;
  final List<RouteStage> stages;

  const FullMapScreen({super.key, required this.title, required this.stages});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: RouteMap(stages: stages, interactive: true),
    );
  }
}
