part of k;

const default_url =
    "https://www.youtube.com/results?hl=en&gl=US&category=music&search_query=";

///parses search term to search_query term
parseQueryString(String str) {
  return str.replaceAll(" ", "+");
}

Future<YtMediaItem> ytSearch(String term) async {
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

Future<List<yt.MediaStreamInfo>> ytMusic(String id) async {
  return (await yt.YoutubeExplode().getVideoMediaStream(id)).audio;
}

Future<YtMediaItem> getMusicUrl(MediaItem mediaItem) async {
  var i = 0;
  while (i < 3) {
    try {
      var ytItem = await ytSearch(mediaItem.artist + " - " + mediaItem.title);
      var audio = await ytMusic(ytItem.id);
      return YtMediaItem()
        ..duration = ytItem.duration
        ..id = audio.first.url.toString();
    } catch (e) {
      i++;
      print("Youtube Search Parser #ERROR TRY $i");
    }
  }

  throw ErrorDescription("Youtube Search Error");
}
