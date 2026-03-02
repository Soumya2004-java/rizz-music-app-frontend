import 'dart:async';

import '../../songs/songs.dart';

class LyricLine {
  final Duration at;
  final String text;

  const LyricLine({required this.at, required this.text});
}

class PlayerSession {
  PlayerSession._();

  static final PlayerSession instance = PlayerSession._();

  final StreamController<PlayerSnapshot> _controller =
      StreamController<PlayerSnapshot>.broadcast();

  Song? _currentSong;
  bool _isPlaying = false;
  bool _isMinimized = false;
  Duration _position = Duration.zero;
  Duration _duration = const Duration(minutes: 3, seconds: 42);
  double _bpm = 108;
  Timer? _ticker;

  Song? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;
  bool get isMinimized => _isMinimized;
  Duration get position => _position;
  Duration get duration => _duration;
  double get bpm => _bpm;
  bool get hasTrack => _currentSong != null;

  Stream<PlayerSnapshot> get stream => _controller.stream;

  PlayerSnapshot get snapshot => PlayerSnapshot(
        currentSong: _currentSong,
        isPlaying: _isPlaying,
        isMinimized: _isMinimized,
        position: _position,
        duration: _duration,
        bpm: _bpm,
      );

  void playSong(Song song, {bool autoPlay = true}) {
    final isNewSong = _currentSong?.id != song.id;

    if (isNewSong) {
      _currentSong = song;
      _duration = _durationForSong(song);
      _bpm = _bpmForSong(song);
      _position = Duration.zero;
    }

    _isMinimized = false;
    _isPlaying = autoPlay;

    if (_isPlaying) {
      _startTicker();
    } else {
      _stopTicker();
    }

    _emit();
  }

  void togglePlayPause() {
    if (_currentSong == null) return;
    _isPlaying = !_isPlaying;
    if (_isPlaying) {
      _startTicker();
    } else {
      _stopTicker();
    }
    _emit();
  }

  void seek(Duration next) {
    if (_currentSong == null) return;
    final bounded = next < Duration.zero
        ? Duration.zero
        : (next > _duration ? _duration : next);
    _position = bounded;
    _emit();
  }

  void minimize() {
    if (_currentSong == null) return;
    _isMinimized = true;
    _emit();
  }

  void expand() {
    if (_currentSong == null) return;
    _isMinimized = false;
    _emit();
  }

  List<LyricLine> lyricsForCurrentSong() {
    final song = _currentSong;
    final title = song?.title ?? 'Unknown Song';
    final artist = song?.artist ?? 'Unknown Artist';

    if (song?.id == '1') {
      return const [
        LyricLine(at: Duration(seconds: 0), text: 'Raat ki dhadkan dheere chale'),
        LyricLine(at: Duration(seconds: 12), text: 'Teri awaaz se roshni mile'),
        LyricLine(at: Duration(seconds: 24), text: 'Saanson mein tera hi zikr rahe'),
        LyricLine(at: Duration(seconds: 36), text: 'Dil ki har taan tujhe hi kahe'),
        LyricLine(at: Duration(seconds: 50), text: 'Tu paas aaye to waqt ruk jaaye'),
        LyricLine(at: Duration(minutes: 1, seconds: 4), text: 'Har dhun mein tera rang samaye'),
        LyricLine(at: Duration(minutes: 1, seconds: 20), text: 'Naad chale to nazar jhuk jaaye'),
        LyricLine(at: Duration(minutes: 1, seconds: 36), text: 'Naam tera hi lab pe aaye'),
        LyricLine(at: Duration(minutes: 1, seconds: 52), text: 'Beats mein hum dono kho jaaye'),
        LyricLine(at: Duration(minutes: 2, seconds: 10), text: 'Dil bole phir se sunaye'),
        LyricLine(at: Duration(minutes: 2, seconds: 30), text: 'Aakhri drop pe ishq barse'),
        LyricLine(at: Duration(minutes: 2, seconds: 50), text: 'Tere bina yeh raag na tarse'),
      ];
    }

    if (song?.id == '2') {
      return const [
        LyricLine(at: Duration(seconds: 0), text: 'Chand ne likhi ek nayi kahani'),
        LyricLine(at: Duration(seconds: 14), text: 'Teri hansi se mehki jawani'),
        LyricLine(at: Duration(seconds: 30), text: 'Pal pal tera intezaar rahe'),
        LyricLine(at: Duration(seconds: 46), text: 'Har sur pe tera ikraar rahe'),
        LyricLine(at: Duration(minutes: 1, seconds: 3), text: 'Tu jo mile to raaste badle'),
        LyricLine(at: Duration(minutes: 1, seconds: 18), text: 'Bikhre lamhe saare jud gaye'),
        LyricLine(at: Duration(minutes: 1, seconds: 34), text: 'Aankhon mein rangon ka dariya'),
        LyricLine(at: Duration(minutes: 1, seconds: 51), text: 'Dhadkan bole bas tera naam'),
        LyricLine(at: Duration(minutes: 2, seconds: 10), text: 'Hook mein khud ko bhool gaye'),
        LyricLine(at: Duration(minutes: 2, seconds: 30), text: 'Drop pe saare gham dhul gaye'),
        LyricLine(at: Duration(minutes: 2, seconds: 53), text: 'Raat yahi par tham si jaaye'),
        LyricLine(at: Duration(minutes: 3, seconds: 16), text: 'Tu saath ho to geet ban jaaye'),
      ];
    }

    return [
      const LyricLine(at: Duration(seconds: 0), text: 'Late night lights and city skies'),
      const LyricLine(at: Duration(seconds: 13), text: 'You and I in stereo tides'),
      const LyricLine(at: Duration(seconds: 28), text: "Hold this beat, don't let it fade"),
      const LyricLine(at: Duration(seconds: 42), text: 'Hearts in rhythm, unafraid'),
      const LyricLine(at: Duration(seconds: 58), text: 'Every drop turns into flame'),
      const LyricLine(at: Duration(minutes: 1, seconds: 14), text: 'Calling softly, say my name'),
      LyricLine(at: const Duration(minutes: 1, seconds: 30), text: '$title keeps us moving on'),
      const LyricLine(at: Duration(minutes: 1, seconds: 48), text: 'We rise, we fall, we glow'),
      const LyricLine(at: Duration(minutes: 2, seconds: 6), text: 'Through every note we know'),
      LyricLine(at: const Duration(minutes: 2, seconds: 24), text: '$artist forever in my ear'),
      const LyricLine(at: Duration(minutes: 2, seconds: 44), text: 'No silence when you are near'),
      const LyricLine(at: Duration(minutes: 3, seconds: 4), text: 'One more chorus, crystal clear'),
    ];
  }

  int activeLyricIndex(List<LyricLine> lyrics, Duration position) {
    if (lyrics.isEmpty) return 0;
    for (int i = lyrics.length - 1; i >= 0; i--) {
      if (position >= lyrics[i].at) return i;
    }
    return 0;
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (!_isPlaying || _currentSong == null) return;
      final next = _position + const Duration(milliseconds: 250);
      if (next >= _duration) {
        _position = _duration;
        _isPlaying = false;
        _stopTicker();
        _emit();
        return;
      }
      _position = next;
      _emit();
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  void _emit() {
    if (_controller.isClosed) return;
    _controller.add(snapshot);
  }

  Duration _durationForSong(Song? song) {
    switch (song?.id) {
      case '1':
        return const Duration(minutes: 3, seconds: 18);
      case '2':
        return const Duration(minutes: 4, seconds: 1);
      case '3':
        return const Duration(minutes: 3, seconds: 46);
      case '4':
        return const Duration(minutes: 2, seconds: 59);
      default:
        return const Duration(minutes: 3, seconds: 42);
    }
  }

  double _bpmForSong(Song? song) {
    switch (song?.id) {
      case '1':
        return 98;
      case '2':
        return 122;
      case '3':
        return 86;
      case '4':
        return 132;
      default:
        return 108;
    }
  }
}

class PlayerSnapshot {
  final Song? currentSong;
  final bool isPlaying;
  final bool isMinimized;
  final Duration position;
  final Duration duration;
  final double bpm;

  const PlayerSnapshot({
    required this.currentSong,
    required this.isPlaying,
    required this.isMinimized,
    required this.position,
    required this.duration,
    required this.bpm,
  });
}
