class Song {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String? audioUrl;
  final String? imageUrl;
  final int? durationSeconds;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    this.audioUrl,
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
      imageUrl:
          _string(json['imageUrl']) ??
          _string(json['image_url']) ??
          _string(json['coverUrl']) ??
          _string(json['artwork']),
      durationSeconds: _int(json['durationSeconds']) ?? _int(json['duration']),
    );
  }

  bool get hasRemoteAudio => (audioUrl ?? '').trim().isNotEmpty;
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
