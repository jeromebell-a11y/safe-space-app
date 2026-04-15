import 'package:flutter/material.dart';

import '../../../core/models/safety_level.dart';
import '../../../core/models/safety_zone.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class MapPlaceholder extends StatelessWidget {
  const MapPlaceholder({
    super.key,
    this.level,
    this.zone,
  });

  final SafetyLevel? level;
  final SafetyZone? zone;

  Color _tintColor() => switch (level) {
        SafetyLevel.elevated => AppColors.elevatedSafety,
        SafetyLevel.high => AppColors.highSafety,
        _ => AppColors.lowSafety,
      };

  String _statusLabel() => switch (level) {
        SafetyLevel.elevated => 'Elevated activity detected',
        SafetyLevel.high => 'High activity detected',
        _ => 'Area intelligence active',
      };

  String _supportingLine() {
    if (zone == null) return 'Scanning area for zone data…';
    final age = DateTime.now().difference(zone!.lastUpdated);
    if (age.inMinutes < 60) {
      return 'Zone data updated ${age.inMinutes}m ago';
    }
    return 'Zone data updated ${age.inHours}h ago';
  }

  @override
  Widget build(BuildContext context) {
    final tint = _tintColor();
    final hasIntelligence = level != null;

    return Stack(
      children: [
        // Base background + grid.
        Container(
          color: AppColors.background,
          child: CustomPaint(
            painter: _GridPainter(
              lineColor: hasIntelligence
                  ? tint.withValues(alpha: 0.12)
                  : AppColors.border.withValues(alpha: 0.5),
            ),
            child: const SizedBox.expand(),
          ),
        ),

        // Radial ambient tint overlay.
        if (hasIntelligence)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.85,
                  colors: [
                    tint.withValues(alpha: 0.07),
                    tint.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

        // Centered content.
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: (hasIntelligence ? tint : AppColors.textSecondary)
                          .withValues(alpha: 0.10),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.map_outlined,
                  size: 36,
                  color: hasIntelligence
                      ? tint.withValues(alpha: 0.6)
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                hasIntelligence ? _statusLabel() : 'Map View',
                style: AppTextStyles.subtitle.copyWith(
                  color: hasIntelligence
                      ? tint.withValues(alpha: 0.8)
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                hasIntelligence
                    ? _supportingLine()
                    : 'Live safety map will appear here',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  _GridPainter({required this.lineColor});

  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 0.5;

    const spacing = 32.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) =>
      lineColor != oldDelegate.lineColor;
}
