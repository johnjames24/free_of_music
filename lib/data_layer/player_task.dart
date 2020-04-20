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
  final MediaItem mediaItem;
  final PlaybackState playbackState;

  ScreenState(this.queue, this.mediaItem, this.playbackState);
}

///manages the audioplayer in the background isolate
class AudioPlayerTask extends BackgroundAudioTask {
  ///[MediaItem] queue array
  List<MediaItem> _queue = [];

  ///index of the queue
  int _queueIndex = -1;

  ///just_player [AudioPlayer]
  AudioPlayer _audioPlayer = new AudioPlayer();

  ///[Completer] to complete [AudioPlayerTask.onStart]
  Completer _completer = Completer();

  ///[AudioServiceBackground.setQueue] done completer
  Completer _init = Completer();

  ///[AudioPlayerTask.onStart] queue waiting completer
  Completer _onStart = Completer();

  BasicPlaybackState _skipState;
  bool _playing;

  bool get hasNext => _queueIndex + 1 < _queue.length;

  bool get hasPrevious => _queueIndex > 0;

  MediaItem get mediaItem => _queue[_queueIndex];

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

    //AudioServiceBackground.setQueue(_queue);
    _onStart.complete();
    print("waiting for queue");
    await _init.future;
    await onSkipToNext();
    await _completer.future;
    playerStateSubscription.cancel();
    eventSubscription.cancel();
  }

  void _handlePlaybackCompleted() {
    if (hasNext) {
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

  Future<void> _skip(int offset) async {
    final newPos = _queueIndex + offset;
    if (!(newPos >= 0 && newPos < _queue.length)) return;
    if (_playing == null) {
      // First time, we want to start playing
      _playing = true;
    } else if (_playing) {
      // Stop current item
      await _audioPlayer.stop();
    }
    // Load next item
    _queueIndex = newPos;
    _skipState = offset > 0
        ? BasicPlaybackState.skippingToNext
        : BasicPlaybackState.skippingToPrevious;

    var yt = (await getMusicUrl(mediaItem));

    AudioServiceBackground.setMediaItem(
        mediaItem.copyWith(duration: yt.duration.inMilliseconds));

    await _audioPlayer.setUrl(yt.id);

    _skipState = null;
    // Resume playback if we were playing
    if (_playing) {
      onPlay();
    } else {
      _setState(state: BasicPlaybackState.paused);
    }
  }

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
    _completer.complete();
  }

  @override
  void onAddQueueItem(MediaItem item) {
    _queue.add(item);
    AudioServiceBackground.setQueue(_queue);
  }

  @override
  void onAddQueueItemAt(MediaItem mediaItem, int index) {
    _queue.insert(index, mediaItem);
    AudioServiceBackground.setQueue(_queue);
  }

  @override
  void onRemoveQueueItem(MediaItem mediaItem) {
    var _ind = _findIndexFromId(mediaItem.id);

    _queue.removeAt(_ind);
    AudioServiceBackground.setQueue(_queue);
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
    var mediaItem = _queue.removeAt(oldIndex);
    _queue.insert(newIndex, mediaItem);
    AudioServiceBackground.setQueue(_queue);
  }

  ///inistantiates Queue
  _initQueue(List _map) async {
    await _onStart.future;
    var list = _map.map((e) => _decodeMediaItem(jsonDecode(e))).toList();

    _queue = list;
    await AudioServiceBackground.setQueue(list);
    _init.complete();
  }

  ///adds a list of [MediaItem] to [_queue]
  _addAll(List _map) {
    var list = _map.map((e) => _decodeMediaItem(jsonDecode(e))).toList();
    _queue.addAll(list);
    AudioServiceBackground.setQueue(_queue);
  }

  ///play a particular [index] in [_queue]
  _playIndex(int index) async {
    _queueIndex = index;
    var _mediaItem = _queue[index];

    if (_playing == null) {
      // First time, we want to start playing
      _playing = true;
    } else if (_playing) {
      // Stop current item
      await _audioPlayer.stop();
    }
    _skipState = BasicPlaybackState.skippingToQueueItem;

    var yt = (await getMusicUrl(_mediaItem));

    AudioServiceBackground.setMediaItem(
        _mediaItem.copyWith(duration: yt.duration.inMilliseconds));

    await _audioPlayer.setUrl(yt.id);

    _skipState = null;
    // Resume playback if we were playing
    if (_playing) {
      onPlay();
    } else {
      _setState(state: BasicPlaybackState.paused);
    }
  }

  ///shuffles the [_queue]
  _shuffle() async {
    _queue.shuffle();
    AudioServiceBackground.setQueue(_queue);
  }

  ///find the index of first [MediaItem] which has the give [id]
  int _findIndexFromId(String id) {
    var _ind = 0, i = 0;
    for (var x in _queue) {
      if (x.id == mediaItem.id) {
        _ind = i;
      }
      i++;
    }

    return _ind;
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
