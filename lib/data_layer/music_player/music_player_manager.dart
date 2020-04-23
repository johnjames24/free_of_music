part of k.data_layer;

class MusicPlayerManager extends PlaylistManager {
  MusicPlayerManager();

  Stream<PlaybackState> get playbackStream => AudioService.playbackStateStream;
  Stream<MediaItem> get currentMediaItemStream =>
      AudioService.currentMediaItemStream;
  get isPlaying => AudioService.running;

  Future<void> skipToPrevious() => AudioService.skipToPrevious();

  Future<void> skipToNext() => AudioService.skipToNext();

  Future<void> pause() => AudioService.pause();

  Future<void> play() => AudioService.play();

  Future<void> stop() => AudioService.stop();
}
