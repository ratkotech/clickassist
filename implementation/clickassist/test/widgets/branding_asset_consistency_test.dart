import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Flutter and Android overlay use the canonical app icon asset', () {
    final designLogo = File('../../design/clickassist-app-icon.png');
    final canonicalFlutterLogo = File(
      'assets/branding/clickassist-app-icon.png',
    );
    final androidOverlayLogo = File(
      'android/app/src/main/res/drawable/clickassist_overlay_logo.png',
    );

    expect(designLogo.existsSync(), isTrue);
    expect(canonicalFlutterLogo.existsSync(), isTrue);
    expect(
      canonicalFlutterLogo.readAsBytesSync(),
      designLogo.readAsBytesSync(),
    );
    expect(androidOverlayLogo.existsSync(), isTrue);
    expect(androidOverlayLogo.readAsBytesSync(), designLogo.readAsBytesSync());
  });

  test('BrandLogo and launcher icon config use the canonical asset path', () {
    final brandLogo = File('lib/widgets/brand_logo.dart').readAsStringSync();
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final readme = File('../../README.md').readAsStringSync();

    expect(brandLogo, contains('assets/branding/clickassist-app-icon.png'));
    expect(pubspec, contains('flutter_launcher_icons:'));
    expect(
      pubspec,
      contains('image_path: "assets/branding/clickassist-app-icon.png"'),
    );
    expect(
      pubspec,
      contains(
        'adaptive_icon_foreground: "assets/branding/clickassist-adaptive-foreground.png"',
      ),
    );
    expect(readme, contains('design/clickassist-app-icon.png'));
    expect(readme, isNot(contains('design/logo.png')));
  });

  test('native overlay uses the logo only for the compact overlay button', () {
    final layout = File(
      'android/app/src/main/res/layout/overlay_controls.xml',
    ).readAsStringSync();

    expect(layout, contains('@drawable/clickassist_overlay_logo'));
    expect(layout, contains('android:src="@drawable/ic_overlay_play"'));
    expect(layout, isNot(contains('overlayPlayButton"')));
    expect(layout, isNot(contains('overlayCompactStatus')));
  });

  test('native launch screen does not show the old splash logo', () {
    final launchBackground = File(
      'android/app/src/main/res/drawable/launch_background.xml',
    ).readAsStringSync();
    final launchBackgroundV21 = File(
      'android/app/src/main/res/drawable-v21/launch_background.xml',
    ).readAsStringSync();
    final stylesV31 = File(
      'android/app/src/main/res/values-v31/styles.xml',
    ).readAsStringSync();
    final stylesNightV31 = File(
      'android/app/src/main/res/values-night-v31/styles.xml',
    ).readAsStringSync();

    expect(launchBackground, isNot(contains('ic_splash_logo')));
    expect(launchBackgroundV21, isNot(contains('ic_splash_logo')));
    expect(stylesV31, isNot(contains('ic_splash_logo')));
    expect(stylesNightV31, isNot(contains('ic_splash_logo')));
    expect(stylesV31, contains('@drawable/ic_splash_transparent'));
    expect(stylesNightV31, contains('@drawable/ic_splash_transparent'));
  });

  test(
    'Android launcher icons are generated from the canonical icon config',
    () {
      final designLogo = File('../../design/clickassist-app-icon.png');
      final canonicalFlutterLogo = File(
        'assets/branding/clickassist-app-icon.png',
      );
      final adaptiveLauncherLogo = File(
        'android/app/src/main/res/drawable-nodpi/ic_launcher_full.png',
      );
      final launcherSizes = {
        'mipmap-mdpi': 48,
        'mipmap-hdpi': 72,
        'mipmap-xhdpi': 96,
        'mipmap-xxhdpi': 144,
        'mipmap-xxxhdpi': 192,
      };

      expect(designLogo.existsSync(), isTrue);
      expect(canonicalFlutterLogo.existsSync(), isTrue);
      expect(
        canonicalFlutterLogo.readAsBytesSync(),
        designLogo.readAsBytesSync(),
      );
      expect(adaptiveLauncherLogo.existsSync(), isTrue);
      expect(
        adaptiveLauncherLogo.readAsBytesSync(),
        designLogo.readAsBytesSync(),
        reason: 'Adaptive launcher icons should use the full approved logo.',
      );
      for (final density in launcherSizes.keys) {
        final launcher = File(
          'android/app/src/main/res/$density/ic_launcher.png',
        );
        final roundLauncher = File(
          'android/app/src/main/res/$density/ic_launcher_round.png',
        );

        expect(launcher.existsSync(), isTrue);
        expect(roundLauncher.existsSync(), isTrue);
        expect(launcher.lengthSync(), greaterThan(0));
        expect(roundLauncher.lengthSync(), greaterThan(0));
      }
    },
  );

  test(
    'adaptive launcher icons use the generated foreground and background',
    () {
      final adaptiveIcon = File(
        'android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml',
      ).readAsStringSync();
      final adaptiveRoundIcon = File(
        'android/app/src/main/res/mipmap-anydpi-v26/ic_launcher_round.xml',
      ).readAsStringSync();

      expect(adaptiveIcon, contains('@color/ic_launcher_background'));
      expect(adaptiveRoundIcon, contains('@color/ic_launcher_background'));
      expect(adaptiveIcon, contains('@drawable/ic_launcher_foreground'));
      expect(adaptiveRoundIcon, contains('@drawable/ic_launcher_foreground'));
      expect(adaptiveIcon, contains('android:inset="16%"'));
      expect(adaptiveRoundIcon, contains('android:inset="16%"'));
    },
  );

  test('native click dispatch asks the floating overlay to avoid targets', () {
    final accessibilityService = File(
      'android/app/src/main/kotlin/app/clickassist/android/AutoClickAccessibilityService.kt',
    ).readAsStringSync();
    final floatingOverlayService = File(
      'android/app/src/main/kotlin/app/clickassist/android/FloatingOverlayService.kt',
    ).readAsStringSync();

    expect(
      accessibilityService,
      contains('FloatingOverlayService.prepareForClickTarget'),
    );
    expect(floatingOverlayService, contains('fun prepareForClickTarget'));
  });
}
