part of k;

var spotifyApi = spotify.SpotifyApi.fromToken();

class SamplePlayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        home: AudioServiceRoot(
      child: new Scaffold(
        appBar: new AppBar(
          title: const Text('Audio Service Demo'),
        ),
        body: ScreenStateBuilder(
          builder: (context, screenState) {
            final queue = screenState?.queue;
            final mediaItem = screenState?.mediaItem;
            final state = screenState?.playbackState;
            final basicState = state?.basicState ?? BasicPlaybackState.none;

            return Column(
              children: <Widget>[
                Container(
                  height: 250,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      if (queue != null && queue.isNotEmpty)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(Icons.skip_previous),
                              iconSize: 30.0,
                              onPressed: mediaItem == queue.first
                                  ? null
                                  : AudioService.skipToPrevious,
                            ),
                            IconButton(
                              icon: Icon(Icons.skip_next),
                              iconSize: 30.0,
                              onPressed: mediaItem == queue.last
                                  ? null
                                  : AudioService.skipToNext,
                            ),
                          ],
                        ),
                      if (mediaItem?.title != null) Text(mediaItem.title),
                      if (basicState == BasicPlaybackState.none ||
                          basicState == BasicPlaybackState.stopped) ...[
                        audioPlayerButton(_album, "coldplay"),
                        audioPlayerButton(_playlist, "Deep Focus"),
                        audioPlayerButton(_single, "single"),
                      ] else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (basicState == BasicPlaybackState.playing)
                              pauseButton()
                            else if (basicState == BasicPlaybackState.paused)
                              playButton()
                            else if (basicState ==
                                    BasicPlaybackState.buffering ||
                                basicState ==
                                    BasicPlaybackState.skippingToNext ||
                                basicState ==
                                    BasicPlaybackState.skippingToPrevious)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SizedBox(
                                  width: 30.0,
                                  height: 30.0,
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            stopButton(),
                            shuffle(),
                            addMore(),
                          ],
                        ),
                      if (basicState != BasicPlaybackState.none &&
                          basicState != BasicPlaybackState.stopped) ...[
                        positionIndicator(),
                        Text("State: " +
                            "$basicState".replaceAll(RegExp(r'^.*\.'), '')),
                      ]
                    ],
                  ),
                ),
                if (queue != null)
                  Container(
                    height: 350,
                    child: ReorderableListView(
                      children: reorederableListItems(screenState),
                      onReorder: m.move,
                    ),
                  )
              ],
            );
          },
        ),
      ),
    ));
  }

  reorederableListItems(ScreenState state) {
    var i = -1;
    return state.queue.map((e) {
      i++;
      var x = i;
      return ListTile(
        leading: IconButton(
          icon:
              Icon(e == state?.mediaItem ? Icons.music_note : Icons.play_arrow),
          onPressed: () async {
            m.playIndexOf(x);
          },
        ),
        title: Text(e.title),
        key: UniqueKey(),
      );
    }).toList();
  }

  RaisedButton audioPlayerButton(Function _entry, String label) => startButton(
        label,
        () async {
          if (AudioService.running) await AudioService.stop();
          await _entry();
        },
      );

  RaisedButton startButton(String label, VoidCallback onPressed) =>
      RaisedButton(
        child: Text(label),
        onPressed: onPressed,
      );

  IconButton playButton() => IconButton(
        icon: Icon(Icons.play_arrow),
        iconSize: 30.0,
        onPressed: AudioService.play,
      );

  IconButton pauseButton() => IconButton(
        icon: Icon(Icons.pause),
        iconSize: 30.0,
        onPressed: AudioService.pause,
      );

  IconButton shuffle() => IconButton(
        icon: Icon(Icons.shuffle),
        iconSize: 30.0,
        onPressed: m.shuffle,
      );

  IconButton stopButton() => IconButton(
        icon: Icon(Icons.stop),
        iconSize: 30.0,
        onPressed: AudioService.stop,
      );

  IconButton addMore() => IconButton(
        icon: Icon(Icons.add),
        iconSize: 30.0,
        onPressed: () async {
          //4E7bV0pzG0LciBSWTszra6
          try {
            m.addTracks((await spotifyApi.artists
                    .getTopTracks("4gzpq5DPGxSnKTe4SA8HAU", "US"))
                .toList());
          } catch (e) {
            print(e);
          }
        },
      );

  Widget positionIndicator() {
    return PositionSliderBuilder(
      builder: (context, onChanged, onChangeEnd, value, duration,
              [screenState]) =>
          (Column(
        children: [
          if (duration != null)
            Slider(
              min: 0.0,
              max: duration,
              value: value,
              onChanged: onChanged,
              onChangeEnd: onChangeEnd,
            ),
          if (screenState?.playbackState?.currentPosition != null)
            Text(
                "${(screenState.playbackState.currentPosition / 1000).toStringAsFixed(3)}"),
        ],
      )),
    );
  }
}

PlaylistManager m = PlaylistManager();
void _playlist() async {
  m = PlaylistManager.fromPlaylist("37i9dQZF1DWZeKCadgRdKQ");
  await m.initAudioService();
}

void _album() async {
  m = PlaylistManager.fromAlbum("4E7bV0pzG0LciBSWTszra6");
  m.initAudioService();
}

void _single() async {
  m = PlaylistManager.onlyTrack(
      await spotifyApi.tracks.get("2zQIITgo6sc5ppOfPcH205"));
  m.initAudioService();
}
