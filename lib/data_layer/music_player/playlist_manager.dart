part of k;

var spotifyApi = spotify.SpotifyApi.fromToken();

void instantiateAudioService() async {
  AudioServiceBackground.run(() => AudioPlayerTask());
}

Future<List<spotify.Track>> _convertTrackSimple(
    List<spotify.TrackSimple> tracks) async {
  var ids = tracks.map<String>((e) => e.id).toList();

  //splits ids into groups of 50
  var chunks = <List<String>>[];
  for (var i = 0; i < ids.length; i += 50) {
    if ((i + 50) < ids.length)
      chunks.add(ids.sublist(i, i + 50));
    else
      chunks.add(ids.sublist(i));
  }

  var ret = <spotify.Track>[];
  for (var _ids in chunks) {
    ret.addAll(await spotifyApi.tracks.list(_ids));
  }

  return ret;
}

List<String> _convertToMediaItemMAP(List<spotify.Track> tracks) {
  var uuid = Uuid();
  return tracks
      .map<String>((e) => jsonEncode({
            "id": uuid.v4(),
            "title": e.name,
            "album": e?.album?.name,
            "artist": e?.artists?.map((e) => e.name)?.join(", "),
            "artUri": e?.album?.images == null
                ? ""
                : _selectMediaItemImage(e.album.images),
            "duration": e.durationMs,
            "extras": _extractExtras(e),
          }))
      .toList();
}

String _selectMediaItemImage(List<spotify.Image> images) {
  if (images.length == 0)
    return null;
  else if (images.length == 1)
    return images.first.url;
  else {
    //find the smallest image
    var url = "";
    var lurl = "";
    var w = 1000000, h = 1000000;
    images.forEach((element) {
      if (element.width < w && element.height < h) {
        w = element.width;
        h = element.height;
        lurl = url;
        url = element.url;
      }
    });

    if (lurl != "") return lurl;

    return url;
  }
}

Map<String, dynamic> _extractExtras(spotify.Track track) {
  return {
    "spotify_id": track.id,
    "discNumber": track.discNumber,
    "spotifyDurationMs": track.durationMs,
    "explicit": track.explicit,
    "popularity": track.popularity,
    "album": {
      "id": track.album.id,
      "images": track.album.images
          .map((e) => {
                "width": e.width,
                "height": e.height,
                "url": e.url,
              })
          .toList()
    },
    "artist": track.artists
        .map((e) => {
              "id": e.id,
              "name": e.name,
            })
        .toList()
  };
}

mediaItemsFromTrack(spotify.Track e) {
  return MediaItem(
      id: e.id,
      title: e.name,
      album: e?.album?.name,
      artist: e?.artists?.map((e) => e.name)?.join(", "),
      artUri:
          e?.album?.images == null ? "" : _selectMediaItemImage(e.album.images),
      duration: e.durationMs,
      extras: _extractExtras(e));
}

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
