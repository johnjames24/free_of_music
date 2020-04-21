part of k;

///PLANNING
class MusicPlayerManager extends PlaylistManager {
  MusicPlayerManager();

  Future<void> skipToPrevious() => AudioService.skipToPrevious();

  Future<void> skipToNext() => AudioService.skipToNext();

  Future<void> pause() => AudioService.pause();

  Future<void> play() => AudioService.play();

  Future<void> stop() => AudioService.stop();
}
