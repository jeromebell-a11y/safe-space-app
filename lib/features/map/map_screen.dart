import 'package:flutter/material.dart';

import '../../core/models/report.dart';
import '../../core/models/safety_level.dart';
import '../../core/models/safety_state.dart';
import '../../core/services/geohash_service.dart';
import '../../core/services/location_service.dart';
import '../../core/services/nearby_reports_repository.dart';
import '../../core/services/safety_scoring_service.dart';
import '../../core/theme/app_colors.dart';
import '../safety/nearby_activity_screen.dart';
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
  final _scoringService = SafetyScoringService();

  static const _geohashPrefixLength = 5;

  SafetyState _safetyState = const SafetyState(
    level: SafetyLevel.low,
    label: 'Low Activity',
    summary: 'No recent reports in your area.',
    bullets: ['All clear — no incidents reported nearby'],
  );

  List<Report> _nearbyReports = const [];
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
        _nearbyReports = reports;
        _safetyState = _scoringService.deriveFromReports(reports);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
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
                        NearbyActivityScreen(reports: _nearbyReports),
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
