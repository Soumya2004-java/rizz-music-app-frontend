import 'dart:async';
import 'dart:math';

import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import '../../songs/songs.dart';

class LyricLine {
  final Duration at;
  final String text;

  const LyricLine({required this.at, required this.text});
}

enum RepeatMode { off, all, one }

class PlayerSession {
  PlayerSession._() {
    _positionSub = _audioPlayer.positionStream.listen((position) {
      if (_isSimulatedPlayback) return;
      _position = position;
      _emit();
    });

    _durationSub = _audioPlayer.durationStream.listen((duration) {
      if (_isSimulatedPlayback) return;
      if (duration != null) {
        _duration = duration;
        _emit();
      }
    });

    _stateSub = _audioPlayer.playerStateStream.listen((state) {
      if (_isSimulatedPlayback) return;
      _isPlaying = state.playing;
      if (state.processingState == ProcessingState.completed) {
        _position = _duration;
        _isPlaying = false;
        _handleTrackCompleted();
        return;
      }
      _emit();
    });
  }

  static final PlayerSession instance = PlayerSession._();

  final AudioPlayer _audioPlayer = AudioPlayer();
  final StreamController<PlayerSnapshot> _controller =
      StreamController<PlayerSnapshot>.broadcast();

  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<PlayerState>? _stateSub;

  Song? _currentSong;
  final List<Song> _queue = <Song>[];
  final Set<String> _likedSongIds = <String>{};
  final Random _random = Random();
  final List<String> _availableDevices = const [
    'This phone speaker',
    'Bluetooth Headphones',
    'Car Audio',
    'Smart TV',
  ];
  bool _isPlaying = false;
  bool _isMinimized = false;
  bool _isShuffleEnabled = false;
  RepeatMode _repeatMode = RepeatMode.off;
  String _activeDevice = 'This phone speaker';
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
  bool get isShuffleEnabled => _isShuffleEnabled;
  RepeatMode get repeatMode => _repeatMode;
  String get activeDevice => _activeDevice;
  List<String> get availableDevices => List.unmodifiable(_availableDevices);
  bool get isCurrentSongLiked {
    final id = _currentSong?.id;
    if (id == null) return false;
    return _likedSongIds.contains(id);
  }

  int get _currentQueueIndex {
    final id = _currentSong?.id;
    if (id == null) return -1;
    return _queue.indexWhere((song) => song.id == id);
  }

  bool get hasPreviousTrack {
    if (_queue.isEmpty) return false;
    if (_repeatMode == RepeatMode.one) return true;
    if (_isShuffleEnabled && _queue.length > 1) return true;
    final index = _currentQueueIndex;
    if (index < 0) return false;
    if (index > 0) return true;
    return _repeatMode == RepeatMode.all;
  }

  bool get hasNextTrack {
    if (_queue.isEmpty) return false;
    if (_repeatMode == RepeatMode.one) return true;
    if (_isShuffleEnabled && _queue.length > 1) return true;
    final index = _currentQueueIndex;
    if (index < 0) return false;
    if (index < _queue.length - 1) return true;
    return _repeatMode == RepeatMode.all;
  }

  bool get _isSimulatedPlayback => !(_currentSong?.hasRemoteAudio ?? false);

  Stream<PlayerSnapshot> get stream => _controller.stream;

  PlayerSnapshot get snapshot => PlayerSnapshot(
    currentSong: _currentSong,
    isPlaying: _isPlaying,
    isMinimized: _isMinimized,
    isShuffleEnabled: _isShuffleEnabled,
    repeatMode: _repeatMode,
    isCurrentSongLiked: isCurrentSongLiked,
    activeDevice: _activeDevice,
    hasNextTrack: hasNextTrack,
    hasPreviousTrack: hasPreviousTrack,
    position: _position,
    duration: _duration,
    bpm: _bpm,
  );

  void setQueue(List<Song> songs, {Song? currentSong}) {
    _queue
      ..clear()
      ..addAll(songs);

    if (_queue.isEmpty) {
      _emit();
      return;
    }

    final selected = currentSong ?? _currentSong;
    if (selected == null) {
      _emit();
      return;
    }

    final index = _queue.indexWhere((song) => song.id == selected.id);
    if (index < 0) {
      _queue.insert(0, selected);
    }
    _emit();
  }

  void playSong(Song song, {bool autoPlay = true}) {
    final isNewSong = _currentSong?.id != song.id;

    _currentSong = song;
    if (_queue.indexWhere((item) => item.id == song.id) < 0) {
      _queue.add(song);
    }
    _duration = _durationForSong(song);
    _bpm = _bpmForSong(song);
    if (isNewSong) {
      _position = Duration.zero;
    }

    _isMinimized = false;

    if (song.hasRemoteAudio) {
      _stopTicker();
      _playRemoteSong(song, autoPlay: autoPlay, resetPosition: isNewSong);
      return;
    }

    _audioPlayer.stop();
    _isPlaying = autoPlay;
    if (_isPlaying) {
      _startTicker();
    } else {
      _stopTicker();
    }
    _emit();
  }

  Future<void> _playRemoteSong(
    Song song, {
    required bool autoPlay,
    required bool resetPosition,
  }) async {
    try {
      final uri = Uri.parse(song.audioUrl!);
      if (resetPosition) {
        await _audioPlayer.setAudioSource(
          AudioSource.uri(uri, tag: _mediaItemForSong(song)),
        );
      }
      if (!resetPosition && _audioPlayer.audioSource == null) {
        await _audioPlayer.setAudioSource(
          AudioSource.uri(uri, tag: _mediaItemForSong(song)),
        );
      }

      final loadedDuration = _audioPlayer.duration;
      if (loadedDuration != null) {
        _duration = loadedDuration;
      }

      if (autoPlay) {
        await _audioPlayer.play();
        _isPlaying = true;
      } else {
        await _audioPlayer.pause();
        _isPlaying = false;
      }

      _emit();
    } catch (_) {
      // Fallback to simulated progress if remote source cannot load.
      _isPlaying = autoPlay;
      if (_isPlaying) {
        _startTicker();
      }
      _emit();
    }
  }

  void togglePlayPause() {
    if (_currentSong == null) return;

    if (_currentSong!.hasRemoteAudio) {
      if (_isPlaying) {
        _audioPlayer.pause();
        _isPlaying = false;
      } else {
        _audioPlayer.play();
        _isPlaying = true;
      }
      _emit();
      return;
    }

    _isPlaying = !_isPlaying;
    if (_isPlaying) {
      _startTicker();
    } else {
      _stopTicker();
    }
    _emit();
  }

  void toggleShuffle() {
    _isShuffleEnabled = !_isShuffleEnabled;
    _emit();
  }

  void cycleRepeatMode() {
    switch (_repeatMode) {
      case RepeatMode.off:
        _repeatMode = RepeatMode.all;
        break;
      case RepeatMode.all:
        _repeatMode = RepeatMode.one;
        break;
      case RepeatMode.one:
        _repeatMode = RepeatMode.off;
        break;
    }
    _emit();
  }

  void toggleLikeCurrentSong() {
    final id = _currentSong?.id;
    if (id == null) return;
    if (_likedSongIds.contains(id)) {
      _likedSongIds.remove(id);
    } else {
      _likedSongIds.add(id);
    }
    _emit();
  }

  void setActiveDevice(String device) {
    if (!_availableDevices.contains(device)) return;
    _activeDevice = device;
    _emit();
  }

  void playNext() {
    _playAdjacent(direction: 1);
  }

  void playPrevious() {
    if (_position > const Duration(seconds: 3)) {
      seek(Duration.zero);
      return;
    }
    _playAdjacent(direction: -1);
  }

  void seek(Duration next) {
    if (_currentSong == null) return;
    final bounded = next < Duration.zero
        ? Duration.zero
        : (next > _duration ? _duration : next);

    if (_currentSong!.hasRemoteAudio) {
      _audioPlayer.seek(bounded);
    }

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
        LyricLine(
          at: Duration(seconds: 0),
          text: 'Raat ki dhadkan dheere chale',
        ),
        LyricLine(at: Duration(seconds: 12), text: 'Teri awaaz se roshni mile'),
        LyricLine(
          at: Duration(seconds: 24),
          text: 'Saanson mein tera hi zikr rahe',
        ),
        LyricLine(
          at: Duration(seconds: 36),
          text: 'Dil ki har taan tujhe hi kahe',
        ),
        LyricLine(
          at: Duration(seconds: 50),
          text: 'Tu paas aaye to waqt ruk jaaye',
        ),
        LyricLine(
          at: Duration(minutes: 1, seconds: 4),
          text: 'Har dhun mein tera rang samaye',
        ),
        LyricLine(
          at: Duration(minutes: 1, seconds: 20),
          text: 'Naad chale to nazar jhuk jaaye',
        ),
        LyricLine(
          at: Duration(minutes: 1, seconds: 36),
          text: 'Naam tera hi lab pe aaye',
        ),
        LyricLine(
          at: Duration(minutes: 1, seconds: 52),
          text: 'Beats mein hum dono kho jaaye',
        ),
        LyricLine(
          at: Duration(minutes: 2, seconds: 10),
          text: 'Dil bole phir se sunaye',
        ),
        LyricLine(
          at: Duration(minutes: 2, seconds: 30),
          text: 'Aakhri drop pe ishq barse',
        ),
        LyricLine(
          at: Duration(minutes: 2, seconds: 50),
          text: 'Tere bina yeh raag na tarse',
        ),
      ];
    }

    if (song?.id == '2') {
      return const [
        LyricLine(
          at: Duration(seconds: 0),
          text: 'Chand ne likhi ek nayi kahani',
        ),
        LyricLine(
          at: Duration(seconds: 14),
          text: 'Teri hansi se mehki jawani',
        ),
        LyricLine(
          at: Duration(seconds: 30),
          text: 'Pal pal tera intezaar rahe',
        ),
        LyricLine(
          at: Duration(seconds: 46),
          text: 'Har sur pe tera ikraar rahe',
        ),
        LyricLine(
          at: Duration(minutes: 1, seconds: 3),
          text: 'Tu jo mile to raaste badle',
        ),
        LyricLine(
          at: Duration(minutes: 1, seconds: 18),
          text: 'Bikhre lamhe saare jud gaye',
        ),
        LyricLine(
          at: Duration(minutes: 1, seconds: 34),
          text: 'Aankhon mein rangon ka dariya',
        ),
        LyricLine(
          at: Duration(minutes: 1, seconds: 51),
          text: 'Dhadkan bole bas tera naam',
        ),
        LyricLine(
          at: Duration(minutes: 2, seconds: 10),
          text: 'Hook mein khud ko bhool gaye',
        ),
        LyricLine(
          at: Duration(minutes: 2, seconds: 30),
          text: 'Drop pe saare gham dhul gaye',
        ),
        LyricLine(
          at: Duration(minutes: 2, seconds: 53),
          text: 'Raat yahi par tham si jaaye',
        ),
        LyricLine(
          at: Duration(minutes: 3, seconds: 16),
          text: 'Tu saath ho to geet ban jaaye',
        ),
      ];
    }

    return [
      const LyricLine(
        at: Duration(seconds: 0),
        text: 'Late night lights and city skies',
      ),
      const LyricLine(
        at: Duration(seconds: 13),
        text: 'You and I in stereo tides',
      ),
      const LyricLine(
        at: Duration(seconds: 28),
        text: "Hold this beat, don't let it fade",
      ),
      const LyricLine(
        at: Duration(seconds: 42),
        text: 'Hearts in rhythm, unafraid',
      ),
      const LyricLine(
        at: Duration(seconds: 58),
        text: 'Every drop turns into flame',
      ),
      const LyricLine(
        at: Duration(minutes: 1, seconds: 14),
        text: 'Calling softly, say my name',
      ),
      LyricLine(
        at: const Duration(minutes: 1, seconds: 30),
        text: '$title keeps us moving on',
      ),
      const LyricLine(
        at: Duration(minutes: 1, seconds: 48),
        text: 'We rise, we fall, we glow',
      ),
      const LyricLine(
        at: Duration(minutes: 2, seconds: 6),
        text: 'Through every note we know',
      ),
      LyricLine(
        at: const Duration(minutes: 2, seconds: 24),
        text: '$artist forever in my ear',
      ),
      const LyricLine(
        at: Duration(minutes: 2, seconds: 44),
        text: 'No silence when you are near',
      ),
      const LyricLine(
        at: Duration(minutes: 3, seconds: 4),
        text: 'One more chorus, crystal clear',
      ),
    ];
  }

  int activeLyricIndex(List<LyricLine> lyrics, Duration position) {
    if (lyrics.isEmpty) return 0;
    for (int i = lyrics.length - 1; i >= 0; i--) {
      if (position >= lyrics[i].at) return i;
    }
    return 0;
  }

  void _playAdjacent({required int direction}) {
    if (_queue.isEmpty) return;

    final currentIndex = _currentQueueIndex;
    if (currentIndex < 0) {
      if (_currentSong != null) {
        playSong(_currentSong!);
      }
      return;
    }

    int nextIndex = currentIndex;

    if (_isShuffleEnabled && _queue.length > 1) {
      do {
        nextIndex = _random.nextInt(_queue.length);
      } while (nextIndex == currentIndex);
      playSong(_queue[nextIndex]);
      return;
    }

    nextIndex = currentIndex + direction;
    if (nextIndex >= _queue.length) {
      if (_repeatMode == RepeatMode.all) {
        nextIndex = 0;
      } else {
        return;
      }
    } else if (nextIndex < 0) {
      if (_repeatMode == RepeatMode.all) {
        nextIndex = _queue.length - 1;
      } else {
        return;
      }
    }

    playSong(_queue[nextIndex]);
  }

  void _handleTrackCompleted() {
    if (_repeatMode == RepeatMode.one && _currentSong != null) {
      seek(Duration.zero);
      if (_currentSong!.hasRemoteAudio) {
        _audioPlayer.play();
      } else {
        _isPlaying = true;
        _startTicker();
      }
      _emit();
      return;
    }

    final previousId = _currentSong?.id;
    playNext();
    if (_currentSong?.id == previousId) {
      _isPlaying = false;
      _position = _duration;
      _stopTicker();
      _emit();
    }
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
        _handleTrackCompleted();
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

  MediaItem _mediaItemForSong(Song song) {
    final image = song.imageUrl?.trim() ?? '';
    final artUri = image.startsWith('http://') || image.startsWith('https://')
        ? Uri.parse(image)
        : null;
    return MediaItem(
      id: song.id,
      title: song.title,
      artist: song.artist,
      album: song.album,
      duration: _durationForSong(song),
      artUri: artUri,
    );
  }

  Duration _durationForSong(Song? song) {
    final remoteDuration = song?.durationSeconds;
    if (remoteDuration != null && remoteDuration > 0) {
      return Duration(seconds: remoteDuration);
    }

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

  Future<void> dispose() async {
    _stopTicker();
    await _positionSub?.cancel();
    await _durationSub?.cancel();
    await _stateSub?.cancel();
    await _audioPlayer.dispose();
    await _controller.close();
  }
}

class PlayerSnapshot {
  final Song? currentSong;
  final bool isPlaying;
  final bool isMinimized;
  final bool isShuffleEnabled;
  final RepeatMode repeatMode;
  final bool isCurrentSongLiked;
  final String activeDevice;
  final bool hasNextTrack;
  final bool hasPreviousTrack;
  final Duration position;
  final Duration duration;
  final double bpm;

  const PlayerSnapshot({
    required this.currentSong,
    required this.isPlaying,
    required this.isMinimized,
    required this.isShuffleEnabled,
    required this.repeatMode,
    required this.isCurrentSongLiked,
    required this.activeDevice,
    required this.hasNextTrack,
    required this.hasPreviousTrack,
    required this.position,
    required this.duration,
    required this.bpm,
  });
}
