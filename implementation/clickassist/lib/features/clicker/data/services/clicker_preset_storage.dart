import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../domain/entities/clicker_preset.dart';

final clickerPresetStorageProvider = Provider<ClickerPresetStorage>(
  (ref) => const ClickerPresetStorage(),
);

class ClickerPresetStorage {
  const ClickerPresetStorage();

  static const String _boxName = 'clickassist_presets';

  Future<Box<dynamic>> _openBox() => Hive.openBox<dynamic>(_boxName);

  Future<List<ClickerPreset>> loadPresets() async {
    final box = await _openBox();
    return box.values
        .map(
          (value) => ClickerPreset.fromMap(Map<dynamic, dynamic>.from(value)),
        )
        .toList()
      ..sort((a, b) => b.createdAtIso.compareTo(a.createdAtIso));
  }

  Future<void> savePreset(ClickerPreset preset) async {
    final box = await _openBox();
    await box.put(preset.id, preset.toMap());
  }

  Future<void> deletePreset(String id) async {
    final box = await _openBox();
    await box.delete(id);
  }

  Future<void> clearPresets() async {
    final box = await _openBox();
    await box.clear();
  }
}
