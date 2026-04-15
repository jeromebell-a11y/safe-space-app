import 'package:flutter/material.dart';

import '../../core/models/incident.dart';
import '../../core/models/report.dart';
import '../../core/models/safety_level.dart';
import '../../core/models/safety_state.dart';
import '../../core/models/safety_zone.dart';
import '../../core/services/geohash_service.dart';
import '../../core/services/location_service.dart';
import '../../core/services/nearby_incidents_repository.dart';
import '../../core/services/nearby_reports_repository.dart';
import '../../core/services/safety_scoring_service.dart';
import '../../core/services/safety_zone_service.dart';
import '../../core/services/safety_zones_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../safety/nearby_activity_screen.dart';
import '../sharing/share_safety_screen.dart';
import 'widgets/map_placeholder.dart';
import 'widgets/safety_status_panel.dart';
import 'widgets/zone_summary_chip.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _reportsRepository = NearbyReportsRepository();
  final _incidentsRepository = NearbyIncidentsRepository();
  final _locationService = LocationService();
  final _geohashService = GeohashService();
  final _scoringService = SafetyScoringService();
  final _zoneService = SafetyZoneService();
  final _zonesRepository = SafetyZonesRepository();

  static const _geohashPrefixLength = 5;

  SafetyState _safetyState = const SafetyState(
    level: SafetyLevel.low,
    label: 'Low Activity',
    summary: 'No recent reports in your area.',
    bullets: ['All clear — no incidents reported nearby'],
  );

  List<Report> _nearbyReports = const [];
  List<Incident> _nearbyIncidents = const [];
  SafetyZone? _currentZone;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSafetyData();
  }

  Future<void> _loadSafetyData() async {
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

    // Try cached zone first for immediate display.
    bool hasCachedZone = false;
    if (prefix != null) {
      try {
        final cachedZone =
            await _zonesRepository.fetchSafetyZone(prefix);
        if (cachedZone != null && mounted) {
          hasCachedZone = true;
          setState(() {
            _currentZone = cachedZone;
            _safetyState = _safetyStateFromZone(cachedZone);
            _isLoading = false;
          });
        }
      } catch (_) {
        // Cache read failed — continue.
      }
    }

    // Load incidents first as primary intelligence source.
    try {
      final incidents = await _incidentsRepository.fetchRecent(
        geohashPrefix: prefix,
      );
      if (!mounted) return;

      if (incidents.isNotEmpty) {
        final incidentState =
            _scoringService.deriveFromIncidents(incidents);
        setState(() {
          _nearbyIncidents = incidents;
          _safetyState = incidentState;
          _isLoading = false;
        });
      }
    } catch (_) {
      // Incident read failed — continue to reports.
    }

    // Always load reports for transparency + fallback scoring.
    try {
      final reports = await _reportsRepository.fetchRecent(
        geohashPrefix: prefix,
      );
      if (!mounted) return;

      setState(() {
        _nearbyReports = reports;
      });

      // Only derive scoring from reports if no incidents provided it.
      if (_nearbyIncidents.isEmpty) {
        final reportState = _scoringService.deriveFromReports(reports);
        final derivedZone = _zoneService.deriveFromReports(
          reports,
          prefix ?? 'unknown',
        );

        setState(() {
          _safetyState = reportState;
          _currentZone = derivedZone;
          _isLoading = false;
        });

        _zonesRepository
            .upsertSafetyZone(derivedZone)
            .catchError((_) {});
      } else {
        // Still persist zone derived from reports for caching.
        final derivedZone = _zoneService.deriveFromReports(
          reports,
          prefix ?? 'unknown',
        );
        setState(() {
          _currentZone = derivedZone;
        });
        _zonesRepository
            .upsertSafetyZone(derivedZone)
            .catchError((_) {});
      }
    } catch (_) {
      if (!mounted) return;
      if (!hasCachedZone && _nearbyIncidents.isEmpty) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  SafetyState _safetyStateFromZone(SafetyZone zone) {
    final level = zone.riskScore >= 8.0
        ? SafetyLevel.high
        : zone.riskScore >= 3.0
            ? SafetyLevel.elevated
            : SafetyLevel.low;

    final label = switch (level) {
      SafetyLevel.low => 'Low Activity',
      SafetyLevel.elevated => 'Elevated Activity',
      SafetyLevel.high => 'High Activity',
    };

    final summary = switch (level) {
      SafetyLevel.low => 'Minimal recent activity in your area.',
      SafetyLevel.elevated =>
        'Recent incident activity suggests increased awareness in this area.',
      SafetyLevel.high =>
        'Multiple significant reports suggest caution in this area.',
    };

    final age = DateTime.now().difference(zone.lastUpdated);
    final recency = age.inMinutes < 60
        ? '${age.inMinutes}m ago'
        : '${age.inHours}h ago';

    return SafetyState(
      level: level,
      label: label,
      summary: summary,
      bullets: [
        '${zone.incidentCount} report${zone.incidentCount == 1 ? '' : 's'}'
            ' nearby (risk score: ${zone.riskScore.toStringAsFixed(1)})',
        'Last updated: $recency',
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: MapPlaceholder(
              level: _isLoading ? null : _safetyState.level,
              zone: _currentZone,
            ),
          ),
          if (!_isLoading && _currentZone != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.md),
                    child: ZoneSummaryChip(zone: _currentZone!),
                  ),
                ),
              ),
            ),
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
                    builder: (_) => NearbyActivityScreen(
                      incidents: _nearbyIncidents,
                      reports: _nearbyReports,
                    ),
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
