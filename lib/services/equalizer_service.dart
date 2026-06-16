import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

const List<String> equalizerBandLabels = [
  '32',
  '64',
  '125',
  '250',
  '500',
  '1K',
  '4K',
  '16K',
];

/// 8-band gain presets in dB mapped across
/// 32 Hz / 64 Hz / 125 Hz / 250 Hz / 500 Hz / 1 kHz / 4 kHz / 16 kHz.
const Map<String, List<double>> _presetGains = {
  'Flat': [0, 0, 0, 0, 0, 0, 0, 0],
  'Pop': [-1, 1, 2, 3, 2, 1, 2, -1],
  'Rock': [4, 3, 2, 0, -1, 1, 3, 4],
  'Hip-Hop': [6, 5, 3, 1, 0, 1, 2, 2],
  'Classical': [2, 2, 1, 0, -1, 1, 3, 4],
  'Jazz': [3, 2, 1, 1, 0, 2, 3, 3],
  'Electronic': [5, 4, 2, 0, 0, 2, 4, 5],
  'Vocal': [-2, -1, 0, 2, 4, 4, 2, 0],
  'Bass Boost': [7, 6, 4, 2, 0, 0, 0, -1],
};

const List<double> _flatGains = [0, 0, 0, 0, 0, 0, 0, 0];

class EqualizerService {
  EqualizerService._() {
    if (!kIsWeb && Platform.isAndroid) {
      _android = AndroidEqualizer();
    }
  }

  static final EqualizerService instance = EqualizerService._();

  AndroidEqualizer? _android;
  Future<void> _applyQueue = Future<void>.value();

  String _currentPreset = 'Flat';
  bool _currentEnabled = false;

  String get currentPreset => _currentPreset;
  bool get currentEnabled => _currentEnabled;

  List<AndroidAudioEffect> get androidEffects =>
      _android != null ? <AndroidAudioEffect>[_android!] : const [];

  /// just_audio 0.9.x ships no iOS equalizer effect; no-op there.
  List<DarwinAudioEffect> get darwinEffects => const [];

  static List<String> get availablePresets => _presetGains.keys.toList();

  static List<double> presetGainsFor(String preset) {
    return List<double>.from(_presetGains[preset] ?? _flatGains);
  }

  Future<void> apply({
    required bool enabled,
    required String preset,
    List<double>? bandGains,
  }) async {
    _currentPreset = preset;
    _currentEnabled = enabled;
    final gains = enabled
        ? (bandGains?.length == 8 ? bandGains! : presetGainsFor(preset))
        : _flatGains;
    _applyQueue = _applyQueue
        .then((_) async {
          final eq = _android;
          if (eq == null) return;
          try {
            await eq.setEnabled(enabled);
            await _applyGains(gains);
          } catch (_) {
            // Native EQ may be unavailable on some devices; swallow.
          }
        })
        .catchError((_) {});
    await _applyQueue;
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
