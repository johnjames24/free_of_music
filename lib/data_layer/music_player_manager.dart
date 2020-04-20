part of k;

///PLANNING
class MusicPlayerManager {
  PlaylistManager _playlistManager;
  Completer _isPlaylistReady = Completer();

  get playlist async {
    await _isPlaylistReady.future;
    return _playlistManager;
  }

  set playlist(PlaylistManager playlist) {
    if (_playlistManager != null) {
      _playlistManager.clear().then((value) {
        _playlistManager = playlist;
        _isPlaylistReady.complete();
      });
    } else {
      _playlistManager = playlist;
      _isPlaylistReady.complete();
    }
  }

  MusicPlayerManager();
}
