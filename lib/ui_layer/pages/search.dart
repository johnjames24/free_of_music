part of k.ui_layer;

var display = createDisplay(length: 4);

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

class SearchPg extends StatefulWidget {
  @override
  _SearchPgState createState() => _SearchPgState();
}

class _SearchPgState extends State<SearchPg> {
  SearchApi _search;
  TextEditingController _controller;
  bool _mounted;

  Map<String, SearchApi> _cache = {};

  @override
  initState() {
    super.initState();
    _controller = TextEditingController(text: "");
    _mounted = true;

    _controller.addListener(() {
      if (_mounted)
        setState(() {
          var text = _controller.text;
          if (text != "") {
            if (_cache.containsKey(text)) {
              _search = _cache[text];
              print("loading from cache");
            } else {
              _search = SearchApi(text);
              _cache.putIfAbsent(text, () => _search);
            }
          } else {
            _search = null;
          }
        });
    });
  }

  @override
  dispose() {
    _mounted = false;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            title: TextField(
              controller: _controller,
            ),
            pinned: true,
          ),
          if (_controller.text != "")
            SliverList(
              delegate: SliverChildListDelegate([
                Text("Results for ${_controller.text}"),
                FutureBuilder(
                  future: _search?.bestMatch,
                  builder: (context, snapshot) {
                    if (snapshot.data == null) return Container();

                    return Padding(
                      padding: const EdgeInsets.all(20),
                      child: Card(
                        child: Container(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text("Best Match"),
                              Center(
                                child: Container(
                                  height: 300,
                                  child: BestMatchCard(
                                    bestMatch: snapshot.data,
                                    albumBuilder: (context, album) => Container(
                                      child: SquareItemDisplay(
                                        imageUrl:
                                            _selectMediaItemImage(album.images),
                                        placeholder: Container(
                                          color: Colors.black,
                                        ),
                                        title: album.name,
                                        subtitle: album.artists
                                            .map((e) => e.name)
                                            .join(", "),
                                      ),
                                    ),
                                    artistBuilder: (context, artist) =>
                                        Container(
                                      child: CircularItemDisplay(
                                        imageUrl: _selectMediaItemImage(
                                            artist.images),
                                        subtitle:
                                            display(artist.followers.total),
                                        title: artist.name,
                                      ),
                                    ),
                                    playlistBuilder: (context, playlist) =>
                                        Container(
                                      child: SquareItemDisplay(
                                          imageUrl: _selectMediaItemImage(
                                              playlist?.images),
                                          title: playlist.name,
                                          placeholder: Container(
                                            color: Colors.black,
                                          )),
                                    ),
                                    trackBuilder: (context, track) => Container(
                                      child: SquareItemDisplay(
                                          imageUrl: _selectMediaItemImage(
                                              track?.album?.images),
                                          title: track.name,
                                          subtitle: track.artists
                                              .map((e) => e.name)
                                              .join(", "),
                                          placeholder: Container(
                                            color: Colors.black,
                                          )),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Text("Artist"),
                Container(
                  height: 300,
                  color: Colors.green,
                  child: FutureBuilder<LazyPages<spotify.Artist>>(
                      future: _search?.artistPage,
                      builder: (context, snapshot) {
                        return snapshot.data != null &&
                                snapshot?.data?.length != 0
                            ? (LazyList<spotify.Artist>(
                                lazyList: snapshot.data,
                                scrollDirection: Axis.horizontal,
                                loadOffset: 300 * 5,
                                placeholder: Container(
                                  width: 300,
                                  color: Colors.yellowAccent,
                                ),
                                builder: (BuildContext context,
                                        spotify.Artist artist) =>
                                    CircularItemDisplay(
                                  imageUrl:
                                      _selectMediaItemImage(artist.images),
                                  subtitle: display(artist.followers.total),
                                  title: artist.name,
                                ),
                              ))
                            : Container();
                      }),
                ),
                Text("tracks"),
                Container(
                  height: 280,
                  color: Colors.green,
                  child: FutureBuilder<LazyPages<spotify.Track>>(
                      future: _search?.trackPage,
                      builder: (context, snapshot) {
                        return snapshot.data != null &&
                                snapshot?.data?.length != 0
                            ? (LazyList<spotify.Track>(
                                lazyList: snapshot.data,
                                scrollDirection: Axis.horizontal,
                                loadOffset: 300 * 5,
                                placeholder: Container(
                                  width: 300,
                                  color: Colors.yellowAccent,
                                ),
                                builder: (BuildContext context,
                                        spotify.Track track) =>
                                    Container(
                                  width: 220,
                                  padding: EdgeInsets.all(5),
                                  child: SquareItemDisplay(
                                      imageUrl: _selectMediaItemImage(
                                          track?.album?.images),
                                      title: track.name,
                                      subtitle: track.artists
                                          .map((e) => e.name)
                                          .join(", "),
                                      placeholder: Container(
                                        color: Colors.black,
                                      )),
                                ),
                              ))
                            : Container();
                      }),
                ),
                Text("Playlists"),
                Container(
                  height: 280,
                  color: Colors.green,
                  child: FutureBuilder<LazyPages<spotify.PlaylistSimple>>(
                      future: _search?.playlistPage,
                      builder: (context, snapshot) {
                        return snapshot.data != null &&
                                snapshot?.data?.length != 0
                            ? (LazyList<spotify.PlaylistSimple>(
                                lazyList: snapshot.data,
                                scrollDirection: Axis.horizontal,
                                loadOffset: 300 * 5,
                                placeholder: Container(
                                  width: 300,
                                  color: Colors.yellowAccent,
                                ),
                                builder: (BuildContext context,
                                        spotify.PlaylistSimple playlist) =>
                                    Container(
                                        width: 220,
                                        padding: EdgeInsets.all(10),
                                        child: SquareItemDisplay(
                                            imageUrl: _selectMediaItemImage(
                                                playlist?.images),
                                            title: playlist.name,
                                            placeholder: Container(
                                              color: Colors.black,
                                            ))),
                              ))
                            : Container();
                      }),
                ),
                Text("albums"),
                Container(
                  height: 300,
                  color: Colors.green,
                  child: FutureBuilder<LazyPages<spotify.AlbumSimple>>(
                      future: _search?.albumPage,
                      builder: (context, snapshot) {
                        return snapshot.data != null &&
                                snapshot?.data?.length != 0
                            ? (LazyList<spotify.AlbumSimple>(
                                lazyList: snapshot.data,
                                scrollDirection: Axis.horizontal,
                                loadOffset: 300 * 5,
                                placeholder: Container(
                                  width: 220,
                                  color: Colors.yellowAccent,
                                ),
                                builder: (BuildContext context,
                                        spotify.AlbumSimple album) =>
                                    SquareItemDisplay(
                                  imageUrl: _selectMediaItemImage(album.images),
                                  placeholder: Container(
                                    color: Colors.black,
                                  ),
                                  title: album.name,
                                  subtitle: album.artists
                                      .map((e) => e.name)
                                      .join(", "),
                                ),
                              ))
                            : Container();
                      }),
                )
              ]),
            )
        ],
      ),
    );
  }
}

class CircularItemDisplay extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;

  const CircularItemDisplay({
    Key key,
    @required this.imageUrl,
    @required this.subtitle,
    @required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 280,
        padding: EdgeInsets.all(5),
        child: Column(
          children: <Widget>[
            if (imageUrl != null) ...[
              CircleAvatar(
                radius: 110,
                backgroundImage: NetworkImage(imageUrl),
              )
            ] else ...[
              CircleAvatar(
                radius: 110,
                backgroundColor: Colors.black,
              )
            ],
            Flexible(
              fit: FlexFit.tight,
              child: Column(
                children: <Widget>[
                  Text(
                    "$title",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  Text(
                    "$subtitle followers",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.subtitle2,
                  )
                ],
              ),
            )
          ],
        ));
  }
}

class SquareItemDisplay extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;

  final Widget placeholder;

  const SquareItemDisplay({
    Key key,
    @required this.imageUrl,
    @required this.title,
    @required this.placeholder,
    this.subtitle = "",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      child: Column(
        children: <Widget>[
          Container(
            width: 200,
            padding: EdgeInsets.all(5),
            child: imageUrl != null ? Image.network(imageUrl) : placeholder,
          ),
          Flexible(
            fit: FlexFit.tight,
            child: Column(
              children: <Widget>[
                Text(
                  "$title",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                Text(
                  "$subtitle",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.subtitle2,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
