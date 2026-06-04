import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// 5-band gain presets in dB at center frequencies
/// 60 Hz / 230 Hz / 910 Hz / 3.6 kHz / 14 kHz.
const Map<String, List<double>> _presetGains = {
  'Flat': [0, 0, 0, 0, 0],
  'Pop': [-1, 2, 4, 2, -1],
  'Rock': [4, 2, -1, 2, 4],
  'Hip-Hop': [5, 3, 0, 1, 2],
  'Classical': [3, 2, -1, 2, 3],
  'Jazz': [2, 1, 1, 2, 3],
  'Electronic': [4, 1, 0, 2, 4],
  'Vocal': [-2, -1, 3, 3, 0],
  'Bass Boost': [6, 4, 1, 0, 0],
};

const List<double> _flatGains = [0, 0, 0, 0, 0];

class EqualizerService {
  EqualizerService._() {
    if (!kIsWeb && Platform.isAndroid) {
      _android = AndroidEqualizer();
    }
  }

  static final EqualizerService instance = EqualizerService._();

  AndroidEqualizer? _android;

  String _currentPreset = 'Flat';
  bool _currentEnabled = false;

  String get currentPreset => _currentPreset;
  bool get currentEnabled => _currentEnabled;

  List<AndroidAudioEffect> get androidEffects =>
      _android != null ? <AndroidAudioEffect>[_android!] : const [];

  /// just_audio 0.9.x ships no iOS equalizer effect; no-op there.
  List<DarwinAudioEffect> get darwinEffects => const [];

  static List<String> get availablePresets => _presetGains.keys.toList();

  Future<void> apply({required bool enabled, required String preset}) async {
    _currentPreset = preset;
    _currentEnabled = enabled;
    try {
      await _android?.setEnabled(enabled);
    } catch (_) {}
    final gains = enabled ? (_presetGains[preset] ?? _flatGains) : _flatGains;
    await _applyGains(gains);
  }

  Future<void> _applyGains(List<double> gains) async {
    final eq = _android;
    if (eq == null) return;
    try {
      final params = await eq.parameters;
      final bands = params.bands;
      for (var i = 0; i < bands.length; i++) {
        final g = _gainForIndex(gains, i, bands.length);
        final clamped = g
            .clamp(params.minDecibels, params.maxDecibels)
            .toDouble();
        await bands[i].setGain(clamped);
      }
    } catch (_) {
      // Native EQ may be unavailable on some devices; swallow.
    }
  }

  /// Map a 5-band preset onto an arbitrary band count via linear interpolation.
  double _gainForIndex(List<double> gains, int i, int total) {
    if (total <= 1) return gains.first;
    final t = i / (total - 1) * (gains.length - 1);
    final lo = t.floor();
    final hi = (lo + 1).clamp(0, gains.length - 1);
    final frac = t - lo;
    return gains[lo] * (1 - frac) + gains[hi] * frac;
  }
}
