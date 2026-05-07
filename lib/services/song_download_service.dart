import 'dart:io';
import 'dart:convert';

import 'package:path_provider/path_provider.dart';

import '../songs/songs.dart';

class SongDownloadService {
  const SongDownloadService._();

  static Future<DownloadResult> downloadSong(Song song) async {
    final audioUrl = (song.audioUrl ?? '').trim();
    if (audioUrl.isEmpty) {
      throw const SongDownloadException('No audio URL found for this song.');
    }

    final baseDir = await _downloadBaseDirectory();
    final songsDir = Directory('${baseDir.path}${Platform.pathSeparator}songs');
    await songsDir.create(recursive: true);

    final fileName = _fileNameForSong(song, audioUrl);
    final file = File('${songsDir.path}${Platform.pathSeparator}$fileName');

    if (await file.exists()) {
      final localCoverPath = await _downloadCoverIfAvailable(song, songsDir);
      await _writeSongMetadata(file, song, localCoverPath: localCoverPath);
      return DownloadResult(file: file, alreadyExists: true);
    }

    final uri = Uri.tryParse(audioUrl);
    if (uri == null) {
      throw const SongDownloadException('Invalid audio URL.');
    }

    final client = HttpClient();
    try {
      final request = await client.getUrl(uri);
      final response = await request.close();
      if (response.statusCode != HttpStatus.ok) {
        throw SongDownloadException(
          'Download failed (HTTP ${response.statusCode}).',
        );
      }
      await response.pipe(file.openWrite());
      final localCoverPath = await _downloadCoverIfAvailable(song, songsDir);
      await _writeSongMetadata(file, song, localCoverPath: localCoverPath);
      return DownloadResult(file: file, alreadyExists: false);
    } finally {
      client.close(force: true);
    }
  }

  static Future<Directory> _downloadBaseDirectory() async {
    if (Platform.isAndroid || Platform.isIOS) {
      return getApplicationDocumentsDirectory();
    }
    final downloadsDir = await getDownloadsDirectory();
    if (downloadsDir != null) {
      return downloadsDir;
    }
    return getApplicationDocumentsDirectory();
  }

  static String _fileNameForSong(Song song, String audioUrl) {
    final safeTitle = _safeFilePart(song.title);
    final safeArtist = _safeFilePart(song.artist);
    final ext = _extensionFromUrl(audioUrl);
    return '${safeTitle}_$safeArtist$ext';
  }

  static String _safeFilePart(String input) {
    final normalized = input.trim().replaceAll(RegExp(r'\s+'), '_');
    final safe = normalized.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '');
    return safe.isEmpty ? 'track' : safe;
  }

  static String _extensionFromUrl(
    String audioUrl, {
    String defaultExt = '.mp3',
  }) {
    final uri = Uri.tryParse(audioUrl);
    if (uri == null) return defaultExt;
    final path = uri.path.toLowerCase();
    if (path.endsWith('.png')) return '.png';
    if (path.endsWith('.jpg')) return '.jpg';
    if (path.endsWith('.jpeg')) return '.jpeg';
    if (path.endsWith('.webp')) return '.webp';
    if (path.endsWith('.m4a')) return '.m4a';
    if (path.endsWith('.aac')) return '.aac';
    if (path.endsWith('.wav')) return '.wav';
    if (path.endsWith('.ogg')) return '.ogg';
    return defaultExt;
  }

  static Future<List<DownloadedSong>> listDownloadedSongs() async {
    final baseDir = await _downloadBaseDirectory();
    final songsDir = Directory('${baseDir.path}${Platform.pathSeparator}songs');
    if (!await songsDir.exists()) {
      return const [];
    }

    final entries = await songsDir.list().toList();
    final files = entries.whereType<File>().where((file) {
      final name = file.path.toLowerCase();
      return name.endsWith('.mp3') ||
          name.endsWith('.m4a') ||
          name.endsWith('.aac') ||
          name.endsWith('.wav') ||
          name.endsWith('.ogg');
    }).toList();

    files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

    return files.map(_toDownloadedSong).toList(growable: false);
  }

  static Future<void> deleteDownloadedSong(DownloadedSong song) async {
    final audioFile = File(song.filePath);
    if (await audioFile.exists()) {
      await audioFile.delete();
    }

    final metadataFile = File(_metadataPathFor(song.filePath));
    if (await metadataFile.exists()) {
      await metadataFile.delete();
    }

    final localCoverPath = (song.localCoverPath ?? '').trim();
    if (localCoverPath.isNotEmpty && !localCoverPath.startsWith('assets/')) {
      final coverFile = File(localCoverPath);
      if (await coverFile.exists()) {
        await coverFile.delete();
      }
    }
  }

  static DownloadedSong _toDownloadedSong(File file) {
    final fileName = file.uri.pathSegments.isNotEmpty
        ? file.uri.pathSegments.last
        : file.path;
    final withoutExt = fileName.replaceFirst(RegExp(r'\.[^.]+$'), '');
    final splitIndex = withoutExt.lastIndexOf('_');
    final rawTitle = splitIndex > 0
        ? withoutExt.substring(0, splitIndex)
        : withoutExt;
    final rawArtist = splitIndex > 0
        ? withoutExt.substring(splitIndex + 1)
        : 'Unknown artist';
    final title = rawTitle.replaceAll('_', ' ').trim();
    final artist = rawArtist.replaceAll('_', ' ').trim();
    final bytes = file.lengthSync();
    final metadata = _readSongMetadata(file);
    return DownloadedSong(
      title: metadata?.title ?? (title.isEmpty ? 'Unknown title' : title),
      artist: metadata?.artist ?? (artist.isEmpty ? 'Unknown artist' : artist),
      filePath: file.path,
      sizeLabel: _formatBytes(bytes),
      coverUrl: metadata?.coverUrl,
      localCoverPath: metadata?.localCoverPath,
    );
  }

  static Future<void> _writeSongMetadata(
    File audioFile,
    Song song, {
    String? localCoverPath,
  }) async {
    try {
      final metadataFile = File(_metadataPathFor(audioFile.path));
      final payload = <String, String>{
        'title': song.title,
        'artist': song.artist,
        'coverUrl': song.imageUrl ?? '',
        'localCoverPath': localCoverPath ?? '',
      };
      await metadataFile.writeAsString(jsonEncode(payload), flush: true);
    } catch (_) {
      // Metadata write failures should not block audio download.
    }
  }

  static _SongMetadata? _readSongMetadata(File audioFile) {
    try {
      final metadataFile = File(_metadataPathFor(audioFile.path));
      if (!metadataFile.existsSync()) return null;
      final raw = metadataFile.readAsStringSync();
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      return _SongMetadata(
        title: _stringOrNull(decoded['title']),
        artist: _stringOrNull(decoded['artist']),
        coverUrl: _stringOrNull(decoded['coverUrl']),
        localCoverPath: _stringOrNull(decoded['localCoverPath']),
      );
    } catch (_) {
      return null;
    }
  }

  static Future<String?> _downloadCoverIfAvailable(
    Song song,
    Directory songsDir,
  ) async {
    final raw = (song.imageUrl ?? '').trim();
    if (raw.isEmpty) return null;

    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      final uri = Uri.tryParse(raw);
      if (uri == null) return null;
      final ext = _extensionFromUrl(raw, defaultExt: '.jpg');
      final coverFileName =
          '${_safeFilePart(song.title)}_${_safeFilePart(song.artist)}_cover$ext';
      final coverFile = File(
        '${songsDir.path}${Platform.pathSeparator}$coverFileName',
      );
      if (await coverFile.exists()) return coverFile.path;

      final client = HttpClient();
      try {
        final request = await client.getUrl(uri);
        final response = await request.close();
        if (response.statusCode != HttpStatus.ok) return null;
        await response.pipe(coverFile.openWrite());
        return coverFile.path;
      } catch (_) {
        return null;
      } finally {
        client.close(force: true);
      }
    }

    // Asset path already exists in app bundle.
    return raw;
  }

  static String _metadataPathFor(String audioFilePath) {
    return audioFilePath.replaceFirst(RegExp(r'\.[^.]+$'), '.json');
  }

  static String? _stringOrNull(dynamic value) {
    if (value is! String) return null;
    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    final kb = bytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
    final mb = kb / 1024;
    if (mb < 1024) return '${mb.toStringAsFixed(1)} MB';
    final gb = mb / 1024;
    return '${gb.toStringAsFixed(2)} GB';
  }
}

class DownloadResult {
  const DownloadResult({required this.file, required this.alreadyExists});

  final File file;
  final bool alreadyExists;
}

class SongDownloadException implements Exception {
  const SongDownloadException(this.message);

  final String message;

  @override
  String toString() => message;
}

class DownloadedSong {
  const DownloadedSong({
    required this.title,
    required this.artist,
    required this.filePath,
    required this.sizeLabel,
    this.coverUrl,
    this.localCoverPath,
  });

  final String title;
  final String artist;
  final String filePath;
  final String sizeLabel;
  final String? coverUrl;
  final String? localCoverPath;
}

class _SongMetadata {
  const _SongMetadata({
    this.title,
    this.artist,
    this.coverUrl,
    this.localCoverPath,
  });

  final String? title;
  final String? artist;
  final String? coverUrl;
  final String? localCoverPath;
}
