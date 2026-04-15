import 'package:flutter/material.dart';

import '../../core/models/report.dart';
import '../../core/models/safety_level.dart';
import '../../core/models/safety_state.dart';
import '../../core/services/geohash_service.dart';
import '../../core/services/location_service.dart';
import '../../core/services/nearby_reports_repository.dart';
import '../../core/theme/app_colors.dart';
import '../safety/safety_details_screen.dart';
import '../sharing/share_safety_screen.dart';
import 'widgets/map_placeholder.dart';
import 'widgets/safety_status_panel.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _repository = NearbyReportsRepository();
  final _locationService = LocationService();
  final _geohashService = GeohashService();

  static const _geohashPrefixLength = 5;

  SafetyState _safetyState = const SafetyState(
    level: SafetyLevel.low,
    label: 'Low Activity',
    summary: 'No recent reports in your area.',
    bullets: ['All clear — no incidents reported nearby'],
  );

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNearbyReports();
  }

  Future<void> _loadNearbyReports() async {
    String? prefix;

    try {
      final position = await _locationService.getCurrentPosition();
      final geohash = _geohashService.encode(
        position.latitude,
        position.longitude,
      );
      prefix = geohash.substring(0, _geohashPrefixLength);
    } catch (_) {
      // Location unavailable — fall through to unfiltered query.
    }

    try {
      final reports = await _repository.fetchRecent(geohashPrefix: prefix);
      if (!mounted) return;
      setState(() {
        _safetyState = _deriveSafetyState(reports);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  SafetyState _deriveSafetyState(List<Report> reports) {
    if (reports.isEmpty) {
      return const SafetyState(
        level: SafetyLevel.low,
        label: 'Low Activity',
        summary: 'No recent reports in your area.',
        bullets: ['All clear — no incidents reported nearby'],
      );
    }

    final now = DateTime.now();
    final last24h =
        reports.where((r) => now.difference(r.createdAt).inHours < 24).length;

    final SafetyLevel level;
    final String label;
    final String summary;

    if (reports.length >= 3) {
      level = SafetyLevel.high;
      label = 'High Activity';
      summary = 'Multiple reports suggest caution in this area.';
    } else if (reports.isNotEmpty) {
      level = SafetyLevel.elevated;
      label = 'Elevated Activity';
      summary =
          'Recent incident activity suggests increased awareness in this area.';
    } else {
      level = SafetyLevel.low;
      label = 'Low Activity';
      summary = 'No recent reports in your area.';
    }

    final newest = reports.first;
    final age = now.difference(newest.createdAt);
    final recency = age.inMinutes < 60
        ? '${age.inMinutes}m ago'
        : '${age.inHours}h ago';

    final bullets = <String>[
      '${reports.length} report${reports.length == 1 ? '' : 's'} found nearby',
      '$last24h in the last 24 hours',
      'Most recent: ${newest.category.label}, $recency',
    ];

    return SafetyState(
      level: level,
      label: label,
      summary: summary,
      bullets: bullets,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: MapPlaceholder()),
          if (_isLoading)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafetyStatusPanel(
              state: _safetyState,
              onViewDetails: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        SafetyDetailsScreen(state: _safetyState),
                  ),
                );
              },
              onShareSafety: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        ShareSafetyScreen(state: _safetyState),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
