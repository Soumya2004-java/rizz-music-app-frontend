import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HelpFaqItem {
  final String question;
  final String answer;

  const HelpFaqItem({required this.question, required this.answer});
}

class AppConfigData {
  final List<String> membershipPlans;
  final List<String> themes;
  final List<String> languages;
  final List<String> cacheLimits;
  final List<String> equalizerPresets;
  final List<String> dolbyAtmosOptions;
  final List<String> highResOptions;
  final List<String> reportProblemTypes;
  final List<HelpFaqItem> helpFaqs;
  final String aboutAppName;
  final String aboutVersion;
  final String aboutDescription;
  final String aboutDeveloperName;
  final String aboutDeveloperEmail;

  const AppConfigData({
    required this.membershipPlans,
    required this.themes,
    required this.languages,
    required this.cacheLimits,
    required this.equalizerPresets,
    required this.dolbyAtmosOptions,
    required this.highResOptions,
    required this.reportProblemTypes,
    required this.helpFaqs,
    required this.aboutAppName,
    required this.aboutVersion,
    required this.aboutDescription,
    required this.aboutDeveloperName,
    required this.aboutDeveloperEmail,
  });

  factory AppConfigData.defaults() {
    return const AppConfigData(
      membershipPlans: ['Free Member', 'Premium Member', 'Family Plan'],
      themes: ['Dark'],
      languages: ['English', 'Hindi', 'Spanish'],
      cacheLimits: ['1 GB', '2 GB', '5 GB', '10 GB'],
      equalizerPresets: [
        'Flat',
        'Pop',
        'Rock',
        'Hip-Hop',
        'Classical',
        'Jazz',
        'Electronic',
        'Vocal',
        'Bass Boost',
      ],
      dolbyAtmosOptions: ['Automatic', 'Always On', 'Off'],
      highResOptions: ['On', 'Off'],
      reportProblemTypes: ['Bug', 'Playback', 'Account', 'Other'],
      helpFaqs: [
        HelpFaqItem(
          question: 'How to download songs?',
          answer: 'Open any album/playlist and tap the download icon.',
        ),
        HelpFaqItem(
          question: 'How to change audio quality?',
          answer: 'Go to Settings > Audio & Downloads > Audio Quality.',
        ),
        HelpFaqItem(
          question: 'How to edit profile?',
          answer: 'Open Profile and tap Edit Profile.',
        ),
      ],
      aboutAppName: 'Rizz Music App',
      aboutVersion: '1.0.0',
      aboutDescription:
          'Rizz Music App is a complete music streaming application for discovering songs, '
          'exploring albums, managing favorites, and personalizing playback with audio '
          'preferences like equalizer presets and quality settings.',
      aboutDeveloperName: 'Rizz Music Team',
      aboutDeveloperEmail: 'support@rizzmusic.app',
    );
  }

  factory AppConfigData.fromMap(Map<String, dynamic> data) {
    final defaults = AppConfigData.defaults();

    List<String> readList(String key, List<String> fallback) {
      final raw = data[key];
      if (raw is! List) return fallback;
      final list = raw
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
      return list.isEmpty ? fallback : list;
    }

    List<HelpFaqItem> readFaqs() {
      final raw = data['helpFaqs'];
      if (raw is! List) return defaults.helpFaqs;

      final mapped = raw
          .whereType<Map>()
          .map((item) {
            final question = (item['question'] ?? '').toString().trim();
            final answer = (item['answer'] ?? '').toString().trim();
            if (question.isEmpty || answer.isEmpty) return null;
            return HelpFaqItem(question: question, answer: answer);
          })
          .whereType<HelpFaqItem>()
          .toList();

      return mapped.isEmpty ? defaults.helpFaqs : mapped;
    }

    String readText(String key, String fallback) {
      final value = data[key]?.toString().trim() ?? '';
      return value.isEmpty ? fallback : value;
    }

    return AppConfigData(
      membershipPlans: readList('membershipPlans', defaults.membershipPlans),
      themes: readList('themes', defaults.themes),
      languages: readList('languages', defaults.languages),
      cacheLimits: readList('cacheLimits', defaults.cacheLimits),
      equalizerPresets: readList('equalizerPresets', defaults.equalizerPresets),
      dolbyAtmosOptions: readList(
        'dolbyAtmosOptions',
        defaults.dolbyAtmosOptions,
      ),
      highResOptions: readList('highResOptions', defaults.highResOptions),
      reportProblemTypes: readList(
        'reportProblemTypes',
        defaults.reportProblemTypes,
      ),
      helpFaqs: readFaqs(),
      aboutAppName: readText('aboutAppName', defaults.aboutAppName),
      aboutVersion: readText('aboutVersion', defaults.aboutVersion),
      aboutDescription: readText('aboutDescription', defaults.aboutDescription),
      aboutDeveloperName: readText(
        'aboutDeveloperName',
        defaults.aboutDeveloperName,
      ),
      aboutDeveloperEmail: readText(
        'aboutDeveloperEmail',
        defaults.aboutDeveloperEmail,
      ),
    );
  }
}

class UserSettingsData {
  final bool wifiOnlyDownloads;
  final bool normalizeAudio;
  final bool autoplay;
  final bool crossfade;
  final bool equalizerEnabled;
  final bool pushNewReleases;
  final bool pushRecommendations;
  final bool privateSession;
  final bool listeningActivityVisible;
  final bool biometricLock;
  final double crossfadeSeconds;
  final double bassLevel;
  final double midLevel;
  final double trebleLevel;
  final List<double> equalizerBands;
  final Map<String, List<double>> customEqualizerPresets;
  final String dolbyAtmos;
  final String highResMusic;
  final String equalizerPreset;
  final String theme;
  final String language;
  final String cacheLimit;

  const UserSettingsData({
    required this.wifiOnlyDownloads,
    required this.normalizeAudio,
    required this.autoplay,
    required this.crossfade,
    required this.equalizerEnabled,
    required this.pushNewReleases,
    required this.pushRecommendations,
    required this.privateSession,
    required this.listeningActivityVisible,
    required this.biometricLock,
    required this.crossfadeSeconds,
    required this.bassLevel,
    required this.midLevel,
    required this.trebleLevel,
    this.equalizerBands = const [0, 0, 0, 0, 0, 0, 0, 0],
    this.customEqualizerPresets = const {},
    required this.dolbyAtmos,
    required this.highResMusic,
    required this.equalizerPreset,
    required this.theme,
    required this.language,
    required this.cacheLimit,
  });

  factory UserSettingsData.defaults() {
    return const UserSettingsData(
      wifiOnlyDownloads: true,
      normalizeAudio: true,
      autoplay: true,
      crossfade: true,
      equalizerEnabled: true,
      pushNewReleases: true,
      pushRecommendations: true,
      privateSession: false,
      listeningActivityVisible: true,
      biometricLock: false,
      crossfadeSeconds: 6,
      bassLevel: 0,
      midLevel: 0,
      trebleLevel: 0,
      equalizerBands: [0, 0, 0, 0, 0, 0, 0, 0],
      customEqualizerPresets: {},
      dolbyAtmos: 'Automatic',
      highResMusic: 'On',
      equalizerPreset: 'Pop',
      theme: 'Dark',
      language: 'English',
      cacheLimit: '2 GB',
    );
  }

  factory UserSettingsData.fromMap(Map<String, dynamic> map) {
    final d = UserSettingsData.defaults();

    bool b(String key, bool fallback) =>
        map[key] is bool ? map[key] as bool : fallback;
    double n(String key, double fallback) {
      final value = map[key];
      if (value is int) return value.toDouble();
      if (value is double) return value;
      return fallback;
    }

    String s(String key, String fallback) {
      final value = map[key]?.toString().trim() ?? '';
      return value.isEmpty ? fallback : value;
    }

    List<double> bandList(String key, List<double> fallback) {
      final raw = map[key];
      if (raw is! List) return fallback;
      final values = raw
          .map((value) {
            if (value is int) return value.toDouble();
            if (value is double) return value;
            return double.tryParse(value.toString());
          })
          .whereType<double>()
          .map((value) => value.clamp(-12.0, 12.0).toDouble())
          .toList();
      if (values.length != 8) return fallback;
      return values;
    }

    Map<String, List<double>> readCustomPresets() {
      final raw = map['customEqualizerPresets'];
      if (raw is! Map) return const {};

      final presets = <String, List<double>>{};
      for (final entry in raw.entries) {
        final name = entry.key.toString().trim();
        final value = entry.value;
        if (name.isEmpty || value is! List) continue;
        final bands = value
            .map((band) {
              if (band is int) return band.toDouble();
              if (band is double) return band;
              return double.tryParse(band.toString());
            })
            .whereType<double>()
            .map((band) => band.clamp(-12.0, 12.0).toDouble())
            .toList();
        if (bands.length == 8) {
          presets[name] = bands;
        }
      }
      return presets;
    }

    return UserSettingsData(
      wifiOnlyDownloads: b('wifiOnlyDownloads', d.wifiOnlyDownloads),
      normalizeAudio: b('normalizeAudio', d.normalizeAudio),
      autoplay: b('autoplay', d.autoplay),
      crossfade: b('crossfade', d.crossfade),
      equalizerEnabled: b('equalizerEnabled', d.equalizerEnabled),
      pushNewReleases: b('pushNewReleases', d.pushNewReleases),
      pushRecommendations: b('pushRecommendations', d.pushRecommendations),
      privateSession: b('privateSession', d.privateSession),
      listeningActivityVisible: b(
        'listeningActivityVisible',
        d.listeningActivityVisible,
      ),
      biometricLock: b('biometricLock', d.biometricLock),
      crossfadeSeconds: n('crossfadeSeconds', d.crossfadeSeconds),
      bassLevel: n('bassLevel', d.bassLevel),
      midLevel: n('midLevel', d.midLevel),
      trebleLevel: n('trebleLevel', d.trebleLevel),
      equalizerBands: bandList('equalizerBands', d.equalizerBands),
      customEqualizerPresets: readCustomPresets(),
      dolbyAtmos: s('dolbyAtmos', d.dolbyAtmos),
      highResMusic: s('highResMusic', d.highResMusic),
      equalizerPreset: s('equalizerPreset', d.equalizerPreset),
      theme: s('theme', d.theme),
      language: s('language', d.language),
      cacheLimit: s('cacheLimit', d.cacheLimit),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'wifiOnlyDownloads': wifiOnlyDownloads,
      'normalizeAudio': normalizeAudio,
      'autoplay': autoplay,
      'crossfade': crossfade,
      'equalizerEnabled': equalizerEnabled,
      'pushNewReleases': pushNewReleases,
      'pushRecommendations': pushRecommendations,
      'privateSession': privateSession,
      'listeningActivityVisible': listeningActivityVisible,
      'biometricLock': biometricLock,
      'crossfadeSeconds': crossfadeSeconds,
      'bassLevel': bassLevel,
      'midLevel': midLevel,
      'trebleLevel': trebleLevel,
      'equalizerBands': equalizerBands,
      'customEqualizerPresets': customEqualizerPresets,
      'dolbyAtmos': dolbyAtmos,
      'highResMusic': highResMusic,
      'equalizerPreset': equalizerPreset,
      'theme': theme,
      'language': language,
      'cacheLimit': cacheLimit,
    };
  }

  UserSettingsData copyWith({
    bool? wifiOnlyDownloads,
    bool? normalizeAudio,
    bool? autoplay,
    bool? crossfade,
    bool? equalizerEnabled,
    bool? pushNewReleases,
    bool? pushRecommendations,
    bool? privateSession,
    bool? listeningActivityVisible,
    bool? biometricLock,
    double? crossfadeSeconds,
    double? bassLevel,
    double? midLevel,
    double? trebleLevel,
    List<double>? equalizerBands,
    Map<String, List<double>>? customEqualizerPresets,
    String? dolbyAtmos,
    String? highResMusic,
    String? equalizerPreset,
    String? theme,
    String? language,
    String? cacheLimit,
  }) {
    return UserSettingsData(
      wifiOnlyDownloads: wifiOnlyDownloads ?? this.wifiOnlyDownloads,
      normalizeAudio: normalizeAudio ?? this.normalizeAudio,
      autoplay: autoplay ?? this.autoplay,
      crossfade: crossfade ?? this.crossfade,
      equalizerEnabled: equalizerEnabled ?? this.equalizerEnabled,
      pushNewReleases: pushNewReleases ?? this.pushNewReleases,
      pushRecommendations: pushRecommendations ?? this.pushRecommendations,
      privateSession: privateSession ?? this.privateSession,
      listeningActivityVisible:
          listeningActivityVisible ?? this.listeningActivityVisible,
      biometricLock: biometricLock ?? this.biometricLock,
      crossfadeSeconds: crossfadeSeconds ?? this.crossfadeSeconds,
      bassLevel: bassLevel ?? this.bassLevel,
      midLevel: midLevel ?? this.midLevel,
      trebleLevel: trebleLevel ?? this.trebleLevel,
      equalizerBands: equalizerBands ?? this.equalizerBands,
      customEqualizerPresets:
          customEqualizerPresets ?? this.customEqualizerPresets,
      dolbyAtmos: dolbyAtmos ?? this.dolbyAtmos,
      highResMusic: highResMusic ?? this.highResMusic,
      equalizerPreset: equalizerPreset ?? this.equalizerPreset,
      theme: theme ?? this.theme,
      language: language ?? this.language,
      cacheLimit: cacheLimit ?? this.cacheLimit,
    );
  }
}

class SettingsStore {
  SettingsStore._();

  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  static Future<AppConfigData> fetchAppConfig() async {
    try {
      final snapshot = await _db.collection('app_config').doc('mobile').get();
      final data = snapshot.data();
      if (data == null) return AppConfigData.defaults();
      return AppConfigData.fromMap(data);
    } catch (_) {
      return AppConfigData.defaults();
    }
  }

  static Future<UserSettingsData> fetchUserSettings() async {
    final uid = _uid;
    if (uid == null) return UserSettingsData.defaults();

    try {
      final snapshot = await _db.collection('users').doc(uid).get();
      final data = snapshot.data() ?? <String, dynamic>{};
      final raw = data['appSettings'];
      if (raw is! Map<String, dynamic>) return UserSettingsData.defaults();
      return UserSettingsData.fromMap(raw);
    } catch (_) {
      return UserSettingsData.defaults();
    }
  }

  static Future<void> saveUserSettings(UserSettingsData settings) async {
    final uid = _uid;
    if (uid == null) return;

    await _db.collection('users').doc(uid).set({
      'appSettings': settings.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<void> submitProblem({
    required String type,
    required String message,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('You must be signed in.');

    await _db.collection('support_reports').add({
      'uid': user.uid,
      'email': user.email,
      'type': type,
      'message': message,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'open',
    });
  }
}
