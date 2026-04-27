import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/services/app_preferences_service.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import 'clicker_page.dart';
import 'onboarding_page.dart';

class StartupShellPage extends StatefulWidget {
  const StartupShellPage({super.key});

  static bool _introAlreadyShown = false;

  @override
  State<StartupShellPage> createState() => _StartupShellPageState();
}

class _StartupShellPageState extends State<StartupShellPage>
    with SingleTickerProviderStateMixin {
  final AppPreferencesService _preferencesService = const AppPreferencesService();
  AnimationController? _controller;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _taglineOpacity;
  bool _showApp = true;
  bool? _onboardingCompleted;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final completed = await _preferencesService.isOnboardingCompleted();
      if (!mounted) {
        return;
      }
      setState(() {
        _onboardingCompleted = completed;
      });
    });

    if (StartupShellPage._introAlreadyShown) {
      _showApp = true;
      return;
    }

    _showApp = false;
    StartupShellPage._introAlreadyShown = true;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();

    _logoScale = Tween<double>(
      begin: 0.84,
      end: 1,
    ).animate(
      CurvedAnimation(parent: _controller!, curve: Curves.easeOutBack),
    );
    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller!, curve: const Interval(0, 0.6)),
    );
    _taglineOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller!, curve: const Interval(0.35, 1)),
    );

    Future<void>.delayed(const Duration(milliseconds: 1350), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _showApp = true;
      });
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appChild = _onboardingCompleted == null
        ? const Scaffold(
            body: ColoredBox(
              color: AppColors.background,
              child: Center(child: CircularProgressIndicator()),
            ),
          )
        : _onboardingCompleted!
        ? const ClickerPage()
        : OnboardingPage(
            onContinue: () async {
              await _preferencesService.setOnboardingCompleted(true);
              if (!mounted) {
                return;
              }
              setState(() {
                _onboardingCompleted = true;
              });
            },
          );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 420),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: _showApp ? appChild : const _StartupSplash(),
    );
  }
}

class _StartupSplash extends StatelessWidget {
  const _StartupSplash();

  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<_StartupShellPageState>()!;
    final controller = state._controller;
    if (controller == null) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF091226), AppColors.background],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: state._logoOpacity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScaleTransition(
                    scale: state._logoScale,
                    child: Container(
                      width: 124,
                      height: 124,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF1ECFFF), Color(0xFF12A7FF)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.34),
                            blurRadius: 36,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF091226),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.play_arrow_rounded,
                              size: 42,
                              color: AppColors.primaryBright,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Text(
                    'ClickAssist',
                    style: AppTextStyles.headlineLarge.copyWith(
                      color: AppColors.primaryBright,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  FadeTransition(
                    opacity: state._taglineOpacity,
                    child: Text(
                      'Precision tap automation',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
