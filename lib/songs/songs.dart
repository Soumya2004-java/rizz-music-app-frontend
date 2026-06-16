class Song {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String? audioUrl;
  final String? highResAudioUrl;
  final String? dolbyAtmosAudioUrl;
  final String? imageUrl;
  final int? durationSeconds;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    this.audioUrl,
    this.highResAudioUrl,
    this.dolbyAtmosAudioUrl,
    this.imageUrl,
    this.durationSeconds,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: _string(json['id']) ?? _string(json['songId']) ?? '',
      title: _string(json['title']) ?? _string(json['name']) ?? 'Untitled',
      artist:
          _string(json['artist']) ?? _string(json['artistName']) ?? 'Unknown',
      album: _string(json['album']) ?? _string(json['albumName']) ?? 'Unknown',
      audioUrl:
          _string(json['audioUrl']) ??
          _string(json['audio_url']) ??
          _string(json['url']) ??
          _string(json['fileUrl']),
      highResAudioUrl:
          _string(json['highResAudioUrl']) ??
          _string(json['high_res_audio_url']) ??
          _string(json['hiResAudioUrl']) ??
          _string(json['losslessAudioUrl']),
      dolbyAtmosAudioUrl:
          _string(json['dolbyAtmosAudioUrl']) ??
          _string(json['dolby_atmos_audio_url']) ??
          _string(json['atmosAudioUrl']) ??
          _string(json['spatialAudioUrl']),
      imageUrl:
          _string(json['imageUrl']) ??
          _string(json['image_url']) ??
          _string(json['coverUrl']) ??
          _string(json['artwork']),
      durationSeconds: _int(json['durationSeconds']) ?? _int(json['duration']),
    );
  }

  bool get hasRemoteAudio =>
      (audioUrl ?? '').trim().isNotEmpty ||
      (highResAudioUrl ?? '').trim().isNotEmpty ||
      (dolbyAtmosAudioUrl ?? '').trim().isNotEmpty;

  String preferredAudioUrl({
    required String dolbyAtmos,
    required String highResMusic,
  }) {
    final atmos = (dolbyAtmosAudioUrl ?? '').trim();
    final highRes = (highResAudioUrl ?? '').trim();
    final standard = (audioUrl ?? '').trim();
    final dolbyPreference = dolbyAtmos.trim().toLowerCase();
    final highResPreference = highResMusic.trim().toLowerCase();

    if (dolbyPreference != 'off' && atmos.isNotEmpty) {
      return atmos;
    }
    if (highResPreference == 'on' && highRes.isNotEmpty) {
      return highRes;
    }
    if (standard.isNotEmpty) {
      return standard;
    }
    if (highRes.isNotEmpty) {
      return highRes;
    }
    return atmos;
  }
}

String? _string(dynamic value) {
  if (value == null) return null;
  final parsed = value.toString().trim();
  if (parsed.isEmpty) return null;
  return parsed;
}

int? _int(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}
