part of k.data_layer;

class SearchApi {
  spotify.SearchBundle _bundle;
  Completer _init = Completer();

  LazyPages<spotify.Artist> _artistPage;
  LazyPages<spotify.PlaylistSimple> _playlistPage;
  LazyPages<spotify.AlbumSimple> _albumPage;
  LazyPages<spotify.Track> _trackPage;

  Future<LazyPages<spotify.Artist>> get artistPage =>
      _init.future.then((val) => _artistPage);

  Future<LazyPages<spotify.PlaylistSimple>> get playlistPage =>
      _init.future.then((val) => _playlistPage);

  Future<LazyPages<spotify.AlbumSimple>> get albumPage =>
      _init.future.then((val) => _albumPage);

  Future<LazyPages<spotify.Track>> get trackPage =>
      _init.future.then((val) => _trackPage);

  Future<Object> get bestMatch =>
      _init.future.then((val) => _bundle.best_match.first);

  SearchApi(String query) {
    _bundle = spotifyApi.search.getWithBestMatch(query);
    _getPages();
  }

  Future<void> _getPages() async {
    var pages = await _bundle.first(spotify.defaultLimit);

    for (var page in pages) {
      var item = page.items.first;
      if (item is spotify.PlaylistSimple) {
        _playlistPage = _lazyLoaderPlaylist(page);
      } else if (item is spotify.Artist) {
        _artistPage = _lazyLoaderArtist(page);
      } else if (item is spotify.AlbumSimple) {
        _albumPage = _lazyLoaderAlbum(page);
      } else if (item is spotify.Track) {
        _trackPage = _lazyLoaderTrack(page);
      }
    }

    _init.complete();
  }

  LazyPages<spotify.Artist> _lazyLoaderArtist(spotify.Page<Object> x) {
    var paging = spotify.Paging<spotify.Artist>()
      ..href = x.metadata.href
      ..itemsNative = x.metadata.itemsNative
      ..limit = x.metadata.limit
      ..next = x.metadata.next
      ..offset = x.metadata.offset
      ..previous = x.metadata.previous
      ..total = x.metadata.total;

    return LazyPages<spotify.Artist>(
        spotify.Page<spotify.Artist>(
            paging, (json) => x.parser(json) as spotify.Artist, x.get),
        (json) => json["artists"]);
  }

  LazyPages<spotify.PlaylistSimple> _lazyLoaderPlaylist(
      spotify.Page<Object> x) {
    var paging = spotify.Paging<spotify.PlaylistSimple>()
      ..href = x.metadata.href
      ..itemsNative = x.metadata.itemsNative
      ..limit = x.metadata.limit
      ..next = x.metadata.next
      ..offset = x.metadata.offset
      ..previous = x.metadata.previous
      ..total = x.metadata.total;

    return LazyPages<spotify.PlaylistSimple>(
        spotify.Page<spotify.PlaylistSimple>(
            paging, (json) => x.parser(json) as spotify.PlaylistSimple, x.get),
        (json) => json["playlists"]);
  }

  LazyPages<spotify.AlbumSimple> _lazyLoaderAlbum(spotify.Page<Object> x) {
    var paging = spotify.Paging<spotify.AlbumSimple>()
      ..href = x.metadata.href
      ..itemsNative = x.metadata.itemsNative
      ..limit = x.metadata.limit
      ..next = x.metadata.next
      ..offset = x.metadata.offset
      ..previous = x.metadata.previous
      ..total = x.metadata.total;

    return LazyPages<spotify.AlbumSimple>(
        spotify.Page<spotify.AlbumSimple>(
            paging, (json) => x.parser(json) as spotify.AlbumSimple, x.get),
        (json) => json["albums"]);
  }

  LazyPages<spotify.Track> _lazyLoaderTrack(spotify.Page<Object> x) {
    var paging = spotify.Paging<spotify.Track>()
      ..href = x.metadata.href
      ..itemsNative = x.metadata.itemsNative
      ..limit = x.metadata.limit
      ..next = x.metadata.next
      ..offset = x.metadata.offset
      ..previous = x.metadata.previous
      ..total = x.metadata.total;

    return LazyPages<spotify.Track>(
        spotify.Page<spotify.Track>(
            paging, (json) => x.parser(json) as spotify.Track, x.get),
        (json) => json["albums"]);
  }
}
