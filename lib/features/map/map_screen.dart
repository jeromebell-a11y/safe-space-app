import 'package:flutter/material.dart';

import '../../core/models/safety_level.dart';
import '../../core/models/safety_state.dart';
import '../safety/safety_details_screen.dart';
import '../sharing/share_safety_screen.dart';
import 'widgets/map_placeholder.dart';
import 'widgets/safety_status_panel.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  static const _mockState = SafetyState(
    level: SafetyLevel.elevated,
    label: 'Elevated Activity',
    summary:
        'Recent incident activity suggests increased caution in this area.',
    bullets: [
      '3 incidents reported in the last 12 hours',
      'Activity tends to increase after dark',
      'Stay aware in low-visibility areas',
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: MapPlaceholder()),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafetyStatusPanel(
              state: _mockState,
              onViewDetails: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        SafetyDetailsScreen(state: _mockState),
                  ),
                );
              },
              onShareSafety: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        ShareSafetyScreen(state: _mockState),
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
