part of k;

const YOUTUBE_EXPIRE_TIME = Duration(hours: 5);

class YoutubeDataManager {
  Box<YtSpotiyBridge> ytSpotifyBridgeBox;
  Box<YtMedia> ytMediaCache;

  Completer _initiated = Completer();

  init() async {
    Hive.registerAdapter(YtSpotiyBridgeAdapter(), 10);
    Hive.registerAdapter(YtMediaAdapter(), 11);
    Hive.registerAdapter(FormatAdapter(), 12);
    Hive.registerAdapter(DateAdapter(), 13);
    Hive.registerAdapter(MediaContainerAdapter(), 14);
    Hive.registerAdapter(AudioEncodingAdapter(), 15);

    ytSpotifyBridgeBox = await Hive.openBox("ytSpotifyBridgeBox");
    ytMediaCache = await Hive.openBox("ytMediaCache");
    _initiated.complete();
  }

  Future<YoutubeDataManagerResponse> get(MediaItem mediaItem) async {
    await _initiated.future;
    var spotifyId = mediaItem?.extras["spotify_id"] as String ?? "";
    YtSpotiyBridge current;
    if (ytSpotifyBridgeBox.containsKey(spotifyId)) {
      current = ytSpotifyBridgeBox.get(spotifyId);
    } else {
      var ytMedia = await _extractSearchPg(mediaItem);
      current = new YtSpotiyBridge.fromValue(
        durationInMilliseconds: ytMedia.duration.inMilliseconds,
        onTime: Date.now(),
        spotifyId: spotifyId,
        youtubeId: ytMedia.id,
      );
      ytSpotifyBridgeBox.put(spotifyId, current);
    }

    var ytId = current.youtubeId;
    if (ytMediaCache.containsKey(ytId)) {
      var ytVideos = ytMediaCache.get(ytId);
      if (ytVideos.onTime.microsecondsSinceEpoch <
          DateTime.now().microsecondsSinceEpoch +
              YOUTUBE_EXPIRE_TIME.inMicroseconds) {
        return YoutubeDataManagerResponse(current, ytVideos);
      }
      await ytMediaCache.delete(ytId);
    }

    var formats = await _ytMusic(ytId);
    var ytVideos = YtMedia.fromValue(
      formats: formats,
      onTime: Date.now(),
      youtubeId: ytId,
    );
    await ytMediaCache.put(ytId, ytVideos);
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

  clearExpired() async {
    var keys = ytMediaCache.keys.toList();

    keys.forEach((element) {
      var ytMedia = ytMediaCache.get(element);

      if (ytMedia.onTime.microsecondsSinceEpoch >
          DateTime.now().microsecondsSinceEpoch +
              YOUTUBE_EXPIRE_TIME.inMicroseconds) {
        ytMediaCache.delete(element);
      }
    });
  }

  cleanUp() async {
    await _initiated.future;
    await ytSpotifyBridgeBox.close();
    await ytMediaCache.close();
  }
}

class YoutubeDataManagerResponse {
  YtSpotiyBridge bridge;
  YtMedia audio;

  YoutubeDataManagerResponse(this.bridge, this.audio);
}
