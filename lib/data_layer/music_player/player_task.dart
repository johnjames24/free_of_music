part of k;

///play control button
MediaControl playControl = MediaControl(
  androidIcon: 'drawable/ic_action_play_arrow',
  label: 'Play',
  action: MediaAction.play,
);

///pause control button
MediaControl pauseControl = MediaControl(
  androidIcon: 'drawable/ic_action_pause',
  label: 'Pause',
  action: MediaAction.pause,
);

///skip_to_next control button
MediaControl skipToNextControl = MediaControl(
  androidIcon: 'drawable/ic_action_skip_next',
  label: 'Next',
  action: MediaAction.skipToNext,
);

///skip_to_previous control button
MediaControl skipToPreviousControl = MediaControl(
  androidIcon: 'drawable/ic_action_skip_previous',
  label: 'Previous',
  action: MediaAction.skipToPrevious,
);

///stop control button
MediaControl stopControl = MediaControl(
  androidIcon: 'drawable/ic_action_stop',
  label: 'Stop',
  action: MediaAction.stop,
);

///keeps tab of all states at once
class ScreenState {
  final List<MediaItem> queue;
  final List<MediaItem> history;
  final MediaItem mediaItem;
  final PlaybackState playbackState;

  ScreenState(
    this.queue,
    this.history,
    this.mediaItem,
    this.playbackState,
  );
}

///manages the audioplayer in the background isolate
class AudioPlayerTask extends BackgroundAudioTask {
  PlaylistArray<MediaItem> _queueManager = PlaylistArray();
  YoutubeDataManager ytDataManager = YoutubeDataManager();

  ///just_player [AudioPlayer]
  AudioPlayer _audioPlayer = new AudioPlayer();

  BasicPlaybackState _skipState;
  bool _playing;

  BasicPlaybackState _eventToBasicState(AudioPlaybackEvent event) {
    if (event.buffering) {
      return BasicPlaybackState.buffering;
    }
    switch (event.state) {
      case AudioPlaybackState.none:
        return BasicPlaybackState.none;
      case AudioPlaybackState.stopped:
        return BasicPlaybackState.stopped;
      case AudioPlaybackState.paused:
        return BasicPlaybackState.paused;
      case AudioPlaybackState.playing:
        return BasicPlaybackState.playing;
      case AudioPlaybackState.connecting:
        return _skipState ?? BasicPlaybackState.connecting;
      case AudioPlaybackState.completed:
        return BasicPlaybackState.stopped;
      default:
        throw Exception("Illegal state");
    }
  }

  @override
  Future<void> onStart() async {
    await BasicDataStorageManager.init();
    await ytDataManager.init();

    var playerStateSubscription = _audioPlayer.playbackStateStream
        .where((state) => state == AudioPlaybackState.completed)
        .listen((state) {
      _handlePlaybackCompleted();
    });
    var eventSubscription = _audioPlayer.playbackEventStream.listen((event) {
      final state = _eventToBasicState(event);
      if (state != BasicPlaybackState.stopped) {
        _setState(
          state: state,
          position: event.position.inMilliseconds,
        );
      }
    });

    var queue = _queueManager.mediaQueueStream.listen((event) {
      AudioServiceBackground.setQueue(event);
    });

    var lock = false;
    var current = _queueManager.currentStream.listen((event) async {
      if (!lock) {
        lock = true;
        if (_playing == null) {
          // First time, we want to start playing
          _playing = true;
        } else if (_playing &&
            _audioPlayer.playbackState != AudioPlaybackState.none) {
          // Stop current item
          await _audioPlayer.stop();
          _setState(state: BasicPlaybackState.buffering, position: 0);
        }

        _skipState = convertToBasicPlaybackState(event.eventChange);

        var yt = await ytDataManager.get(event.data);

        AudioServiceBackground.setMediaItem(
            event.data.copyWith(duration: yt.bridge.durationInMilliseconds));

        await _audioPlayer.setUrl(yt.audio.formats[0].url);

        _skipState = null;
        // Resume playback if we were playing
        if (_playing) {
          onPlay();
        } else {
          _setState(state: BasicPlaybackState.paused);
        }
        lock = false;
      }
    });

    //AudioServiceBackground.setQueue(_queue);
    await _queueManager.currentStream.last;
    await _queueManager.currentStream.last;
    queue.cancel();
    current.cancel();
    playerStateSubscription.cancel();
    eventSubscription.cancel();
    _queueManager.cleanUp();
  }

  void _handlePlaybackCompleted() {
    if (_queueManager.hasNext) {
      onSkipToNext();
    } else {
      onStop();
    }
  }

  void playPause() {
    if (AudioServiceBackground.state.basicState == BasicPlaybackState.playing)
      onPause();
    else
      onPlay();
  }

  @override
  Future<void> onSkipToNext() => _skip(1);

  @override
  Future<void> onSkipToPrevious() => _skip(-1);

  @override
  Future<void> onRewind() async => onSeekTo(0);

  Future<void> _skip(int offset) async => _queueManager.skip(offset);

  @override
  void onPlay() {
    if (_skipState == null) {
      _playing = true;
      _audioPlayer.play();
    }
  }

  @override
  void onPause() {
    if (_skipState == null) {
      _playing = false;
      _audioPlayer.pause();
    }
  }

  @override
  void onSeekTo(int position) {
    _audioPlayer.seek(Duration(milliseconds: position));
  }

  @override
  void onClick(MediaButton button) {
    playPause();
  }

  @override
  void onStop() {
    _audioPlayer.stop();
    _setState(state: BasicPlaybackState.stopped);
    _queueManager.cleanUp();
    ytDataManager.cleanUp();
  }

  @override
  void onAddQueueItem(MediaItem item) {
    _queueManager.addAll([item]);
  }

  @override
  void onAddQueueItemAt(MediaItem mediaItem, int index) {
    _queueManager.insert(index, mediaItem);
  }

  @override
  void onRemoveQueueItem(MediaItem mediaItem) {
    var _ind = _queueManager.mediaQueue.indexOf(mediaItem);
    _queueManager.remove(_ind);
  }

  @override
  void onCustomAction(String name, dynamic arguments) async {
    switch (name) {
      case "initQueue":
        await _initQueue(arguments as List);
        break;
      case "addAll":
        await _addAll(arguments as List);
        break;
      case "move":
        var x = arguments as List;
        await _move(x[0] as int, x[1] as int);
        break;
      case "playIndex":
        await _playIndex(arguments as int);
        break;
      case "shuffle":
        await _shuffle();
        break;
      default:
        break;
    }
  }

  ///moves [oldIndex] item to [newIndex] in [_queue]
  _move(int oldIndex, int newIndex) {
    _queueManager.move(oldIndex, newIndex);
  }

  ///inistantiates Queue
  _initQueue(List _map) async {
    var list = _map.map((e) => _decodeMediaItem(jsonDecode(e))).toList();
    _queueManager.init(list);
  }

  ///adds a list of [MediaItem] to [_queue]
  _addAll(List _map) {
    var list = _map.map((e) => _decodeMediaItem(jsonDecode(e))).toList();
    _queueManager.addAll(list);
  }

  ///play a particular [index] in [_queue]
  _playIndex(int index) => _queueManager.skip(index);

  ///shuffles the [_queue]
  _shuffle() async {
    _queueManager.shuffle();
  }

  ///decodes MediaItem from Raw Map
  MediaItem _decodeMediaItem(Map e) {
    return MediaItem(
        id: e["id"] as String,
        title: e["title"] as String,
        album: e["album"] as String,
        artist: e["artist"] as String,
        artUri: e.containsKey("artUri") ? e["artUri"] as String : null,
        duration: e["duration"] as int,
        extras: e["extras"] as Map<String, dynamic>);
  }

  void _setState({@required BasicPlaybackState state, int position}) {
    if (position == null) {
      position = _audioPlayer.playbackEvent.position.inMilliseconds;
    }
    AudioServiceBackground.setState(
        controls: getControls(state),
        systemActions: [MediaAction.seekTo],
        basicState: state,
        position: position);
  }

  List<MediaControl> getControls(BasicPlaybackState state) {
    if (_playing) {
      return [
        skipToPreviousControl,
        pauseControl,
        skipToNextControl,
      ];
    } else {
      return [
        skipToPreviousControl,
        playControl,
        skipToNextControl,
      ];
    }
  }
}
