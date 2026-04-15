import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_outlined, size: 48, color: AppColors.textSecondary),
            SizedBox(height: AppSpacing.lg),
            Text('Your Profile', style: AppTextStyles.title),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Manage your account and preferences',
              style: AppTextStyles.body,
            ),
          ],
        ),
      ),
    );
  }
}
