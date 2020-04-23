part of k.data_layer;

///parses search term to search_query term
parseQueryString(String str) {
  return str.replaceAll(" ", "+");
}

Future<YtMediaItem> ytSearch(String term) async {
  const default_url =
      "https://www.youtube.com/results?hl=en&gl=US&category=music&search_query=";

  var response = await HttpClient()
      .getUrl(Uri.parse(default_url + parseQueryString(term)))
      .then((request) => request.close());

  var body = await response.transform(Utf8Decoder()).join();

  var document = parse(body);
  var sections = document.getElementsByClassName("yt-lockup");

  var vals = <YtMediaItem>[];
  sections.forEach((elem) {
    var title = elem.getElementsByClassName("yt-lockup-title").first;

    var a = title.getElementsByTagName("a");

    var val = a.first.attributes["href"];

    if (val.indexOf('/channel/') == -1 &&
        val.indexOf('/user/') == -1 &&
        val.indexOf('/playlist?') == -1 &&
        val.indexOf('/watch?') != -1 &&
        val.indexOf("&list=") == -1) {
      var span = title.getElementsByTagName("span");
      vals.add(YtMediaItem()
        ..id = val.substring(9)
        ..duration = parseDuration(span.first.innerHtml));
    }
  });

  return vals.first;
}

parseDuration(String timestampText) {
  var a = timestampText
      .split(" ")
      .last
      .replaceAll(".", "")
      .split(":")
      .map((x) => int.parse(x))
      .toList();

  if (a.length != 3) a.insert(0, 0);

  return Duration(hours: a[0], minutes: a[1], seconds: a[2]);
}

class YtMediaItem {
  Duration duration;

  String id;

  YtMediaItem();
}

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

convertToBasicPlaybackState(ChangeEvent event) {
  switch (event) {
    case ChangeEvent.initiatePlaylist:
      return BasicPlaybackState.skippingToNext;
    case ChangeEvent.skippingToPrevious:
      return BasicPlaybackState.skippingToPrevious;
    case ChangeEvent.skippingToQueueItem:
      return BasicPlaybackState.skippingToQueueItem;
    case ChangeEvent.skippingToNext:
      return BasicPlaybackState.skippingToNext;
    default:
      return BasicPlaybackState.none;
  }
}
