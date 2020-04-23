part of k.data_layer;

class PlaylistManager {
  PlaylistArray<MediaItem> playlist = PlaylistArray();

  Future<void> initfromTrack(spotify.Track track) async {
    if (AudioService.running) await clear();

    var _tracks = [track];
    _tracks.addAll(await fromTrack(track));
    await initAudioService(_tracks);
  }

  Future<void> initfromPlaylist(String id) async {
    if (AudioService.running) await clear();

    await initAudioService(await fromPlaylist(id));
  }

  Future<void> initfromAlbum(String id) async {
    if (AudioService.running) await clear();

    var _tracks = <spotify.Track>[];
    var t = await spotifyApi.albums.getTracks(id).all();
    var _t = await _convertTrackSimple(t.toList());
    _tracks.addAll(_t);
    await initAudioService(_tracks);
  }

  Future<void> initartistTopTrack(String id) async {
    if (AudioService.running) await clear();

    var t = await artistTopTrack(id);
    await initAudioService(t.toList());
  }

  Future<void> initonlyTrack(spotify.Track track) async {
    if (AudioService.running) await clear();

    var _tracks = [track];
    await initAudioService(_tracks);
  }

  Future<List<spotify.Track>> fromTrack(spotify.Track track) async {
    var t = await spotifyApi.recommendation.get([track.id]);
    return _convertTrackSimple(t.toList());
  }

  Future<List<spotify.Track>> fromPlaylist(String id) async {
    return (await spotifyApi.playlists.getTracksByPlaylistId(id).all())
        .toList();
  }

  Future<List<spotify.Track>> fromAlbum(String id) async {
    var t = await spotifyApi.albums.getTracks(id).all();
    return _convertTrackSimple(t.toList());
  }

  Future<List<spotify.Track>> artistTopTrack(String id) async {
    return (await spotifyApi.artists.getTopTracks(id, "US")).toList();
  }

  Future<void> initQueue(List<spotify.Track> tracks) async {
    var map = _convertToMediaItemMAP(tracks);
    await AudioService.customAction("initQueue", map);
  }

  Future<void> initAudioService(List<spotify.Track> tracks) async {
    await AudioService.start(
      backgroundTaskEntrypoint: instantiateAudioService,
      androidNotificationChannelName: 'Audio Service Demo',
      notificationColor: 0xFF2196f3,
      androidNotificationIcon: 'mipmap/ic_launcher',
      enableQueue: true,
    );
    _initPlaylistStream();
    await initQueue(tracks);
  }

  _initPlaylistStream() {
    var _historySubject = BehaviorSubject<List<MediaItem>>();
    var _queueSubject = BehaviorSubject<List<MediaItem>>();

    AudioService.queueStream.listen((event) {
      var _history = <MediaItem>[];
      var _queue = <MediaItem>[];
      event?.forEach((element) {
        var index = element.extras["_index"] as int;

        if (index > 0)
          _queue.add(element);
        else if (index < 0) _history.add(element);
      });

      _historySubject.add(_history.reversed.toList());
      _queueSubject.add(_queue.toList());
    });

    playlist.initWithStream(
        historyStream: _historySubject.stream,
        queueStream: _queueSubject.stream);

    AudioService.queueStream.last.then((value) {
      _historySubject.close();
      _queueSubject.close();
    });
  }

  playIndexOf(int index) async {
    if (AudioService.running)
      await AudioService.customAction("playIndex", index);
  }

  addTracks(List<spotify.Track> tracks) {
    if (AudioService.running) {
      var jsonMediaItems = _convertToMediaItemMAP(tracks);
      AudioService.customAction("addAll", jsonMediaItems);
    }
  }

  move(int oldIndex, int newIndex) {
    if (AudioService.running)
      AudioService.customAction("move", <num>[oldIndex, newIndex]);
  }

  addTrackAt(int index, MediaItem track) {
    if (AudioService.running) AudioService.addQueueItemAt(track, index);
  }

  Future<void> removeTrack(String id) async {
    if (AudioService.running)
      await AudioService.removeQueueItem(
          MediaItem(id: id, title: "", album: ""));
  }

  Future<void> shuffle() async {
    if (AudioService.running) await AudioService.customAction("shuffle");
  }

  Future<void> clear() async {
    if (AudioService.running) {
      await AudioService.stop();
    }
  }

  close() async {
    playlist.cleanUp();
  }
}
