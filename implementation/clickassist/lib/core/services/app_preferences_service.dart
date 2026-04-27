import 'package:hive/hive.dart';

class AppPreferencesService {
  const AppPreferencesService();

  static const String boxName = 'clickassist_app';
  static const String _keyOnboardingCompleted = 'onboarding_completed';

  Future<Box<dynamic>> _openBox() => Hive.openBox<dynamic>(boxName);

  Future<bool> isOnboardingCompleted() async {
    final box = await _openBox();
    return box.get(_keyOnboardingCompleted, defaultValue: false) as bool;
  }

  Future<void> setOnboardingCompleted(bool value) async {
    final box = await _openBox();
    await box.put(_keyOnboardingCompleted, value);
  }

  Future<void> clearAll() async {
    final box = await _openBox();
    await box.clear();
  }
}
