import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/services/app_preferences_service.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../widgets/brand_logo.dart';
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
  final AppPreferencesService _preferencesService =
      const AppPreferencesService();
  AnimationController? _controller;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
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
    ).animate(CurvedAnimation(parent: _controller!, curve: Curves.easeOutBack));
    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller!, curve: const Interval(0, 0.6)),
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
              child: ScaleTransition(
                scale: state._logoScale,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                  child: BrandLogo.full(maxWidth: 300),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
