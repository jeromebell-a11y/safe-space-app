import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/models/incident.dart';
import '../../../core/models/safety_level.dart';
import '../../../core/theme/app_colors.dart';
import 'incident_marker_widget.dart';
import 'incident_preview_sheet.dart';

class SafeSpaceMap extends StatelessWidget {
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

  static const _defaultLat = 37.7749;
  static const _defaultLng = -122.4194;
  static const _defaultZoom = 15.0;
  static const _areaRadius = 300.0;

  LatLng get _center => LatLng(
        latitude ?? _defaultLat,
        longitude ?? _defaultLng,
      );

  Color _areaColor() => switch (level) {
        SafetyLevel.elevated =>
          AppColors.elevatedSafety.withValues(alpha: 0.12),
        SafetyLevel.high =>
          AppColors.highSafety.withValues(alpha: 0.12),
        _ => AppColors.lowSafety.withValues(alpha: 0.10),
      };

  Color _areaBorderColor() => switch (level) {
        SafetyLevel.elevated =>
          AppColors.elevatedSafety.withValues(alpha: 0.3),
        SafetyLevel.high =>
          AppColors.highSafety.withValues(alpha: 0.3),
        _ => AppColors.lowSafety.withValues(alpha: 0.25),
      };

  @override
  Widget build(BuildContext context) {
    final hasLocation = latitude != null && longitude != null;

    return FlutterMap(
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
        if (hasLocation)
          CircleLayer(
            circles: [
              CircleMarker(
                point: _center,
                radius: _areaRadius,
                useRadiusInMeter: true,
                color: _areaColor(),
                borderColor: _areaBorderColor(),
                borderStrokeWidth: 1.5,
              ),
            ],
          ),
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
        if (incidents.isNotEmpty)
          MarkerLayer(
            markers: incidents
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
