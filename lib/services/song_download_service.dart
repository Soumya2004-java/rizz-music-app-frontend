import 'dart:io';

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

  static String _extensionFromUrl(String audioUrl) {
    final uri = Uri.tryParse(audioUrl);
    if (uri == null) return '.mp3';
    final path = uri.path.toLowerCase();
    if (path.endsWith('.m4a')) return '.m4a';
    if (path.endsWith('.aac')) return '.aac';
    if (path.endsWith('.wav')) return '.wav';
    if (path.endsWith('.ogg')) return '.ogg';
    return '.mp3';
  }

  static Future<List<DownloadedSong>> listDownloadedSongs() async {
    final baseDir = await _downloadBaseDirectory();
    final songsDir = Directory('${baseDir.path}${Platform.pathSeparator}songs');
    if (!await songsDir.exists()) {
      return const [];
    }

    final entries = await songsDir.list().toList();
    final files =
        entries.whereType<File>().where((file) {
          final name = file.path.toLowerCase();
          return name.endsWith('.mp3') ||
              name.endsWith('.m4a') ||
              name.endsWith('.aac') ||
              name.endsWith('.wav') ||
              name.endsWith('.ogg');
        }).toList();

    files.sort(
      (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
    );

    return files.map(_toDownloadedSong).toList(growable: false);
  }

  static DownloadedSong _toDownloadedSong(File file) {
    final fileName = file.uri.pathSegments.isNotEmpty
        ? file.uri.pathSegments.last
        : file.path;
    final withoutExt = fileName.replaceFirst(RegExp(r'\.[^.]+$'), '');
    final splitIndex = withoutExt.lastIndexOf('_');
    final rawTitle = splitIndex > 0 ? withoutExt.substring(0, splitIndex) : withoutExt;
    final rawArtist = splitIndex > 0 ? withoutExt.substring(splitIndex + 1) : 'Unknown artist';
    final title = rawTitle.replaceAll('_', ' ').trim();
    final artist = rawArtist.replaceAll('_', ' ').trim();
    final bytes = file.lengthSync();
    return DownloadedSong(
      title: title.isEmpty ? 'Unknown title' : title,
      artist: artist.isEmpty ? 'Unknown artist' : artist,
      filePath: file.path,
      sizeLabel: _formatBytes(bytes),
    );
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
  });

  final String title;
  final String artist;
  final String filePath;
  final String sizeLabel;
}
