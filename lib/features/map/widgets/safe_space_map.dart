import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/models/incident.dart';
import '../../../core/models/safety_level.dart';
import '../../../core/theme/app_colors.dart';
import 'incident_marker_widget.dart';
import 'incident_preview_sheet.dart';

class SafeSpaceMap extends StatefulWidget {
  const SafeSpaceMap({
    super.key,
    this.latitude,
    this.longitude,
    this.level,
    this.incidents = const [],
  });

  final double? latitude;
  final double? longitude;
  final SafetyLevel? level;
  final List<Incident> incidents;

  @override
  State<SafeSpaceMap> createState() => _SafeSpaceMapState();
}

class _SafeSpaceMapState extends State<SafeSpaceMap> {
  final _mapController = MapController();
  bool _hasMovedToUser = false;

  static const _defaultLat = 37.7749;
  static const _defaultLng = -122.4194;
  static const _defaultZoom = 15.0;

  LatLng get _center => LatLng(
        widget.latitude ?? _defaultLat,
        widget.longitude ?? _defaultLng,
      );

  @override
  void didUpdateWidget(covariant SafeSpaceMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_hasMovedToUser &&
        widget.latitude != null &&
        widget.longitude != null) {
      _hasMovedToUser = true;
      _mapController.move(_center, _defaultZoom);
    }
  }

  Color _tintBase() => switch (widget.level) {
        SafetyLevel.elevated => AppColors.elevatedSafety,
        SafetyLevel.high => AppColors.highSafety,
        _ => AppColors.lowSafety,
      };

  List<CircleMarker> _zoneTintCircles() {
    final base = _tintBase();
    return [
      CircleMarker(
        point: _center,
        radius: 500,
        useRadiusInMeter: true,
        color: base.withValues(alpha: 0.04),
        borderColor: Colors.transparent,
        borderStrokeWidth: 0,
      ),
      CircleMarker(
        point: _center,
        radius: 350,
        useRadiusInMeter: true,
        color: base.withValues(alpha: 0.06),
        borderColor: Colors.transparent,
        borderStrokeWidth: 0,
      ),
      CircleMarker(
        point: _center,
        radius: 200,
        useRadiusInMeter: true,
        color: base.withValues(alpha: 0.08),
        borderColor: base.withValues(alpha: 0.2),
        borderStrokeWidth: 1,
      ),
      CircleMarker(
        point: _center,
        radius: 80,
        useRadiusInMeter: true,
        color: base.withValues(alpha: 0.10),
        borderColor: base.withValues(alpha: 0.25),
        borderStrokeWidth: 1.5,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final hasLocation = widget.latitude != null && widget.longitude != null;

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _center,
        initialZoom: _defaultZoom,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.safespace.app',
        ),
        if (hasLocation && widget.level != null)
          CircleLayer(circles: _zoneTintCircles()),
        if (hasLocation)
          MarkerLayer(
            markers: [
              Marker(
                point: _center,
                width: 20,
                height: 20,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.textPrimary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.surface,
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.textPrimary.withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        if (widget.incidents.isNotEmpty)
          MarkerLayer(
            markers: widget.incidents
                .map(
                  (incident) => Marker(
                    point: LatLng(
                      incident.location.latitude,
                      incident.location.longitude,
                    ),
                    width: 28,
                    height: 28,
                    child: GestureDetector(
                      onTap: () =>
                          IncidentPreviewSheet.show(context, incident),
                      child: IncidentMarkerWidget(
                        severity: incident.severity,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}
