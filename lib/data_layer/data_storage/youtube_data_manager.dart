part of k.data_layer;

///time taken to expire a youtube url
const YOUTUBE_EXPIRE_TIME = Duration(hours: 4);

///extract youtube audio with [YoutubeExplode]. Also caches the result
class YoutubeDataManager {
  Box<YtSpotiyBridge> _ytSpotifyBridgeBox;
  Box<YtMedia> _ytMediaCache;

  Completer _initiated = Completer();

  ///connects the boxes
  init() async {
    Hive.registerAdapter(YtSpotiyBridgeAdapter(), 10);
    Hive.registerAdapter(YtMediaAdapter(), 11);
    Hive.registerAdapter(FormatAdapter(), 12);
    Hive.registerAdapter(DateAdapter(), 13);
    Hive.registerAdapter(MediaContainerAdapter(), 14);
    Hive.registerAdapter(AudioEncodingAdapter(), 15);

    _ytSpotifyBridgeBox = await Hive.openBox("ytSpotifyBridgeBox");
    _ytMediaCache = await Hive.openBox("ytMediaCache");
    _initiated.complete();
  }

  ///returns the youtube audio urls as [YoutubeDataManagerResponse]
  Future<YoutubeDataManagerResponse> get(MediaItem mediaItem) async {
    await _initiated.future;
    var spotifyId = mediaItem?.extras["spotify_id"] as String ?? "";
    YtSpotiyBridge current;
    if (_ytSpotifyBridgeBox.containsKey(spotifyId)) {
      current = _ytSpotifyBridgeBox.get(spotifyId);
    } else {
      var ytMedia = await _extractSearchPg(mediaItem);
      current = new YtSpotiyBridge.fromValue(
        durationInMilliseconds: ytMedia.duration.inMilliseconds,
        onTime: Date.now(),
        spotifyId: spotifyId,
        youtubeId: ytMedia.id,
      );
      _ytSpotifyBridgeBox.put(spotifyId, current);
    }

    var ytId = current.youtubeId;
    if (_ytMediaCache.containsKey(ytId)) {
      var ytVideos = _ytMediaCache.get(ytId);
      if (ytVideos.onTime.microsecondsSinceEpoch <
          DateTime.now().microsecondsSinceEpoch +
              YOUTUBE_EXPIRE_TIME.inMicroseconds) {
        return YoutubeDataManagerResponse(current, ytVideos);
      }
      await _ytMediaCache.delete(ytId);
    }

    var formats = await _ytMusic(ytId);
    var ytVideos = YtMedia.fromValue(
      formats: formats,
      onTime: Date.now(),
      youtubeId: ytId,
    );
    await _ytMediaCache.put(ytId, ytVideos);
    return YoutubeDataManagerResponse(current, ytVideos);
  }

  Future<List<Format>> _ytMusic(String id) async {
    return (await yt.YoutubeExplode().getVideoMediaStream(id))
        .audio
        .map((e) => Format.fromValues(
              size: e.size,
              bitrate: e.bitrate,
              url: e.url.toString(),
              container: _convertEnumsContainer(e.container),
              audioEncoding: _convertEnumEncoding(e.audioEncoding),
            ))
        .toList();
  }

  Future<YtMediaItem> _extractSearchPg(MediaItem mediaItem) async {
    var i = 0;
    while (i < 3) {
      try {
        return await ytSearch(mediaItem.artist + " - " + mediaItem.title);
      } catch (e) {
        i++;
        print("Youtube Search Parser #ERROR TRY $i");
      }
    }

    throw ErrorDescription("Youtube Search Error");
  }

  ///clears expired data from cache
  clearExpired() async {
    var keys = _ytMediaCache.keys.toList();

    keys.forEach((element) {
      var ytMedia = _ytMediaCache.get(element);

      if (ytMedia.onTime.microsecondsSinceEpoch >
          DateTime.now().microsecondsSinceEpoch +
              YOUTUBE_EXPIRE_TIME.inMicroseconds) {
        _ytMediaCache.delete(element);
      }
    });
  }

  ///clear every cached youtube URL
  dropCache() async {
    await _ytMediaCache.deleteFromDisk();
  }

  ///disconnects the boxes
  cleanUp() async {
    await _initiated.future;
    await _ytSpotifyBridgeBox.close();
    await _ytMediaCache.close();
  }
}

///represents respondes from [YoutubeDataManager.get]
class YoutubeDataManagerResponse {
  ///bridge data of the request
  YtSpotiyBridge bridge;

  ///audio urls of the requested media
  YtMedia audio;

  YoutubeDataManagerResponse(this.bridge, this.audio);
}
