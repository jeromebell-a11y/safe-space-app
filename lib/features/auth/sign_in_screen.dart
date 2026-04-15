import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/services/auth_service.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _authService = AuthService();
  bool _isSigningIn = false;

  Future<void> _signIn() async {
    setState(() => _isSigningIn = true);
    try {
      await _authService.signInAnonymously();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign-in failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSigningIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Icon(
                Icons.shield_outlined,
                size: 64,
                color: AppColors.textPrimary.withValues(alpha: 0.8),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text('Safe Space', style: AppTextStyles.title),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Geo-aware safety intelligence',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(flex: 3),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSigningIn ? null : _signIn,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.textPrimary,
                    foregroundColor: AppColors.surface,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSigningIn
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.surface,
                          ),
                        )
                      : const Text('Continue as Guest'),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'No account needed for now.',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
