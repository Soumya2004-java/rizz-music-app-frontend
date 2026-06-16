import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../background/gradient_mesh_background.dart';
import '../../../services/equalizer_service.dart';
import 'settings_store.dart';

class EqualizerPage extends StatefulWidget {
  const EqualizerPage({super.key});

  @override
  State<EqualizerPage> createState() => _EqualizerPageState();
}

class _EqualizerPageState extends State<EqualizerPage> {
  AppConfigData _config = AppConfigData.defaults();
  UserSettingsData _settings = UserSettingsData.defaults();
  bool _loading = true;
  bool _saving = false;
  final List<int?> _lastHapticSteps = List<int?>.filled(8, null);
  Timer? _saveDebounce;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final config = await SettingsStore.fetchAppConfig();
    final settings = await SettingsStore.fetchUserSettings();
    if (!mounted) return;
    setState(() {
      _config = config;
      _settings = settings;
      _loading = false;
    });
    _apply(settings);
  }

  Future<void> _update(UserSettingsData settings) async {
    setState(() {
      _settings = settings;
      _saving = true;
    });
    _apply(settings);
    await SettingsStore.saveUserSettings(settings);
    if (!mounted) return;
    setState(() => _saving = false);
  }

  void _updateLive(UserSettingsData settings) {
    setState(() {
      _settings = settings;
    });
    _apply(settings);
    _scheduleSave();
  }

  void _scheduleSave() {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 220), () async {
      await _saveNow();
    });
  }

  Future<void> _saveNow() async {
    if (!mounted) return;
    setState(() => _saving = true);
    try {
      await SettingsStore.saveUserSettings(_settings);
    } finally {}
    if (!mounted) return;
    setState(() => _saving = false);
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    super.dispose();
  }

  Future<void> _flushSaveNow() async {
    _saveDebounce?.cancel();
    await _saveNow();
  }

  void _apply(UserSettingsData settings) {
    EqualizerService.instance.apply(
      enabled: settings.equalizerEnabled,
      preset: settings.equalizerPreset,
      bandGains: settings.equalizerBands,
    );
  }

  void _setBand(int index, double value, {bool vibrate = false}) {
    final next = List<double>.from(_settings.equalizerBands);
    final clamped = value.clamp(-12.0, 12.0).toDouble();
    next[index] = clamped;

    if (vibrate) {
      final step = clamped.round();
      if (_lastHapticSteps[index] != step) {
        _lastHapticSteps[index] = step;
        HapticFeedback.selectionClick();
      }
    }

    _updateLive(
      _settings.copyWith(
        equalizerEnabled: true,
        equalizerPreset: 'Custom',
        equalizerBands: next,
      ),
    );
  }

  void _selectPreset(String preset, List<double> bandGains) {
    _update(
      _settings.copyWith(
        equalizerEnabled: true,
        equalizerPreset: preset,
        equalizerBands: List<double>.from(bandGains),
      ),
    );
  }

  Future<void> _deleteSavedPreset(String preset) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF10151D),
          title: const Text(
            'Delete preset?',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'This will remove "$preset" from your saved presets.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.78)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE05A5A),
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final updatedPresets = Map<String, List<double>>.from(
      _settings.customEqualizerPresets,
    )..remove(preset);

    final nextPreset = _settings.equalizerPreset == preset
        ? 'Custom'
        : _settings.equalizerPreset;

    await _update(
      _settings.copyWith(
        equalizerEnabled: true,
        equalizerPreset: nextPreset,
        customEqualizerPresets: updatedPresets,
      ),
    );
  }

  Future<void> _savePreset() async {
    final controller = TextEditingController(text: _settings.equalizerPreset);
    final name = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF10151D),
          title: const Text(
            'Save preset',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(hintText: 'Preset name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final value = controller.text.trim();
                Navigator.of(context).pop(value.isEmpty ? null : value);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    controller.dispose();

    final presetName = name?.trim() ?? '';
    if (presetName.isEmpty) {
      return;
    }

    final updatedPresets = Map<String, List<double>>.from(
      _settings.customEqualizerPresets,
    );
    updatedPresets[presetName] = List<double>.from(_settings.equalizerBands);

    await _update(
      _settings.copyWith(
        equalizerEnabled: true,
        equalizerPreset: presetName,
        customEqualizerPresets: updatedPresets,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final builtInPresetOptions = <String, List<double>>{
      for (final preset in EqualizerService.availablePresets)
        preset: EqualizerService.presetGainsFor(preset),
    };
    for (final preset in _config.equalizerPresets) {
      builtInPresetOptions.putIfAbsent(
        preset,
        () => EqualizerService.presetGainsFor(preset),
      );
    }
    final savedPresetOptions = _settings.customEqualizerPresets;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const GradientMeshBackground(),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.20),
                    Colors.black.withValues(alpha: 0.72),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxHeight < 760;
                      final headerPadding = EdgeInsets.fromLTRB(
                        8,
                        compact ? 4 : 6,
                        16,
                        0,
                      );
                      final bodyPadding = EdgeInsets.fromLTRB(
                        12,
                        compact ? 8 : 12,
                        12,
                        compact ? 8 : 12,
                      );
                      final titleSize = compact ? 24.0 : 26.0;
                      final sectionGap = compact ? 8.0 : 10.0;

                      return Padding(
                        padding: bodyPadding,
                        child: Column(
                          children: [
                            Padding(
                              padding: headerPadding,
                              child: Row(
                                children: [
                                  IconButton(
                                    visualDensity: VisualDensity.compact,
                                    constraints: const BoxConstraints(
                                      minWidth: 40,
                                      minHeight: 40,
                                    ),
                                    padding: EdgeInsets.zero,
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    icon: const Icon(
                                      Icons.arrow_back_rounded,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'Equalizer',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: titleSize,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  Switch.adaptive(
                                    value: _settings.equalizerEnabled,
                                    activeThumbColor: Colors.white,
                                    activeTrackColor: Colors.white.withValues(
                                      alpha: 0.46,
                                    ),
                                    onChanged: (value) {
                                      _update(
                                        _settings.copyWith(
                                          equalizerEnabled: value,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    _settings.equalizerEnabled ? 'On' : 'Off',
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.76,
                                      ),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const Spacer(),
                                  AnimatedOpacity(
                                    opacity: _saving ? 1 : 0,
                                    duration: const Duration(milliseconds: 160),
                                    child: Text(
                                      'Saving',
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.68,
                                        ),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: sectionGap),
                            Expanded(
                              flex: compact ? 6 : 5,
                              child: _glass(
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          _dbMarker('+12', width: 34),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: List.generate(8, (
                                                index,
                                              ) {
                                                return Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 2,
                                                        ),
                                                    child: _bandSlider(index),
                                                  ),
                                                );
                                              }),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: compact ? 4 : 8),
                                    Row(
                                      children: [
                                        _dbMarker('-12', width: 34),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Row(
                                            children: equalizerBandLabels
                                                .map(
                                                  (label) => Expanded(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 2,
                                                          ),
                                                      child: Text(
                                                        label,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          color: Colors.white
                                                              .withValues(
                                                                alpha: 0.76,
                                                              ),
                                                          fontSize: compact
                                                              ? 11
                                                              : 12,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: compact ? 8 : 12),
                                    SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton.icon(
                                        onPressed: _saving ? null : _savePreset,
                                        icon: const Icon(
                                          Icons.bookmark_add_outlined,
                                        ),
                                        label: const Text('Save preset'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          side: BorderSide(
                                            color: Colors.white.withValues(
                                              alpha: 0.22,
                                            ),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            vertical: compact ? 10 : 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: sectionGap),
                            Expanded(
                              flex: compact ? 4 : 3,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: _presetGlassCard(
                                      title: 'Presets',
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        physics: const BouncingScrollPhysics(),
                                        child: Row(
                                          children: builtInPresetOptions.entries
                                              .map((entry) {
                                                return _presetChip(
                                                  preset: entry.key,
                                                  selected:
                                                      _settings
                                                          .equalizerPreset ==
                                                      entry.key,
                                                  onSelected: () =>
                                                      _selectPreset(
                                                        entry.key,
                                                        entry.value,
                                                      ),
                                                );
                                              })
                                              .toList(),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: compact ? 6 : 8),
                                  Expanded(
                                    child: _presetGlassCard(
                                      title: 'Saved presets',
                                      child: savedPresetOptions.isEmpty
                                          ? Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                'No saved presets yet.',
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.62),
                                                  fontSize: 13,
                                                ),
                                              ),
                                            )
                                          : SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              physics:
                                                  const BouncingScrollPhysics(),
                                              child: Row(
                                                children: savedPresetOptions.entries.map((
                                                  entry,
                                                ) {
                                                  final preset = entry.key;
                                                  final selected =
                                                      _settings
                                                          .equalizerPreset ==
                                                      preset;
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          right: 8,
                                                        ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        ChoiceChip(
                                                          selected: selected,
                                                          label: Text(preset),
                                                          onSelected: (_) =>
                                                              _selectPreset(
                                                                preset,
                                                                entry.value,
                                                              ),
                                                          selectedColor:
                                                              Colors.white,
                                                          backgroundColor:
                                                              Colors.white
                                                                  .withValues(
                                                                    alpha:
                                                                        selected
                                                                        ? 1.0
                                                                        : 0.10,
                                                                  ),
                                                          side: BorderSide(
                                                            color: Colors.white
                                                                .withValues(
                                                                  alpha:
                                                                      selected
                                                                      ? 0.0
                                                                      : 0.20,
                                                                ),
                                                          ),
                                                          labelStyle: TextStyle(
                                                            color: selected
                                                                ? const Color(
                                                                    0xFF10151D,
                                                                  )
                                                                : Colors.white,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 28,
                                                          height: 28,
                                                          child: IconButton(
                                                            padding:
                                                                EdgeInsets.zero,
                                                            visualDensity:
                                                                VisualDensity
                                                                    .compact,
                                                            tooltip:
                                                                'Delete preset',
                                                            onPressed: () =>
                                                                _deleteSavedPreset(
                                                                  preset,
                                                                ),
                                                            icon: Icon(
                                                              Icons
                                                                  .delete_outline_rounded,
                                                              size: 16,
                                                              color: Colors
                                                                  .white
                                                                  .withValues(
                                                                    alpha: 0.78,
                                                                  ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _bandSlider(int index) {
    final value = _settings.equalizerBands[index].clamp(-12.0, 12.0).toDouble();
    return Column(
      children: [
        Text(
          value.toStringAsFixed(0),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.82),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: RotatedBox(
            quarterTurns: 3,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                activeTrackColor: Colors.white,
                inactiveTrackColor: Colors.white.withValues(alpha: 0.22),
                thumbColor: Colors.white,
                overlayColor: Colors.white.withValues(alpha: 0.16),
                valueIndicatorColor: Colors.white,
                valueIndicatorTextStyle: const TextStyle(
                  color: Color(0xFF10151D),
                  fontWeight: FontWeight.w800,
                ),
              ),
              child: Slider(
                value: value,
                min: -12,
                max: 12,
                divisions: 24,
                label: '${value.toStringAsFixed(0)} dB',
                onChangeStart: _settings.equalizerEnabled
                    ? (next) {
                        _lastHapticSteps[index] = next.round();
                        HapticFeedback.lightImpact();
                      }
                    : null,
                onChanged: _settings.equalizerEnabled
                    ? (next) => _setBand(index, next, vibrate: true)
                    : null,
                onChangeEnd: _settings.equalizerEnabled
                    ? (_) {
                        _lastHapticSteps[index] = null;
                        _flushSaveNow();
                      }
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _presetGlassCard({required String title, required Widget child}) {
    return _glass(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.84),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _presetChip({
    required String preset,
    required bool selected,
    required VoidCallback onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        selected: selected,
        label: Text(preset),
        onSelected: (_) => onSelected(),
        selectedColor: Colors.white,
        backgroundColor: Colors.white.withValues(alpha: 0.10),
        side: BorderSide(
          color: Colors.white.withValues(alpha: selected ? 0.0 : 0.20),
        ),
        labelStyle: TextStyle(
          color: selected ? const Color(0xFF10151D) : Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _dbMarker(String label, {required double width}) {
    return SizedBox(
      width: width,
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.62),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _glass({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          child: child,
        ),
      ),
    );
  }
}
