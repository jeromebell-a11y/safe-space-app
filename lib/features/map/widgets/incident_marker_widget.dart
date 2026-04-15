import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class IncidentMarkerWidget extends StatelessWidget {
  const IncidentMarkerWidget({
    super.key,
    required this.severity,
  });

  final int severity;

  Color get _color {
    if (severity >= 5) return AppColors.highSafety;
    if (severity >= 3) return AppColors.elevatedSafety;
    return AppColors.lowSafety;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(
          color: _color.withValues(alpha: 0.6),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: _color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _color.withValues(alpha: 0.4),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
