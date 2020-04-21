part of k;

class SamplePlayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: AudioServiceRoot(
        child: new Scaffold(
          body: DefaultTabController(
            length: 2,
            child: SafeArea(
              child: ScreenStateBuilder(
                builder: (context, screenState) {
                  var m = InheritedMusicplayer.of(context);
                  final queue = screenState?.queue;
                  final mediaItem = screenState?.mediaItem;
                  final state = screenState?.playbackState;
                  final basicState =
                      state?.basicState ?? BasicPlaybackState.none;

                  return Container(
                    color: Colors.yellowAccent,
                    width: double.infinity,
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              if (queue != null && queue.isNotEmpty)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.skip_previous),
                                      iconSize: 20.0,
                                      onPressed:
                                          screenState?.history?.length == 0
                                              ? null
                                              : AudioService.skipToPrevious,
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.skip_next),
                                      iconSize: 20.0,
                                      onPressed: mediaItem == queue.last
                                          ? null
                                          : AudioService.skipToNext,
                                    ),
                                  ],
                                ),
                              if (mediaItem?.title != null)
                                Text(mediaItem.title),
                              if (basicState == BasicPlaybackState.none ||
                                  basicState == BasicPlaybackState.stopped) ...[
                                audioPlayerButton(
                                    () => m.initfromPlaylist(
                                        "37i9dQZF1DWWMOmoXKqHTD"),
                                    "top rates"),
                              ] else
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (basicState ==
                                        BasicPlaybackState.playing)
                                      pauseButton(m)
                                    else if (basicState ==
                                        BasicPlaybackState.paused)
                                      playButton(m)
                                    else if (basicState ==
                                            BasicPlaybackState.buffering ||
                                        basicState ==
                                            BasicPlaybackState.skippingToNext ||
                                        basicState ==
                                            BasicPlaybackState
                                                .skippingToPrevious)
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: SizedBox(
                                          width: 20.0,
                                          height: 20.0,
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                    stopButton(),
                                    shuffle(m),
                                    addMore(m),
                                  ],
                                ),
                              if (basicState != BasicPlaybackState.none &&
                                  basicState != BasicPlaybackState.stopped) ...[
                                positionIndicator(),
                                Text("State: " +
                                    "$basicState"
                                        .replaceAll(RegExp(r'^.*\.'), '')),
                              ],
                              if (queue != null && queue.isNotEmpty)
                                TabBar(tabs: [
                                  Tab(
                                    text: "queue",
                                  ),
                                  Tab(
                                    text: "history",
                                  )
                                ])
                            ],
                          ),
                        ),
                        if (queue != null && queue.isNotEmpty)
                          Expanded(
                            child: TabBarView(children: [
                              if (queue != null)
                                Container(
                                  height: 350,
                                  child: ReorderablePlaylist(
                                      builder: (build, onReorder, list) =>
                                          ReorderableListView(
                                            children:
                                                reorederableListItems(list, m),
                                            onReorder: onReorder,
                                          ),
                                      stream: m.playlist.queueStream),
                                )
                              else ...[Text("")],
                              if (queue != null)
                                Container(
                                  height: 350,
                                  child: ReorderablePlaylist(
                                      builder: (build, onReorder, list) =>
                                          ReorderableListView(
                                            children:
                                                reorederableListItems(list, m),
                                            onReorder: onReorder,
                                          ),
                                      stream: m.playlist.historyStream),
                                )
                              else ...[Text("")]
                            ]),
                          )
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  reorederableListItems(List<MediaItem> list, MusicPlayerManager m) {
    var i = 0;
    return list.map((e) {
      i++;
      var x = i;
      return ListTile(
        leading: IconButton(
          icon: Icon(Icons.music_note),
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

  IconButton playButton(MusicPlayerManager m) => IconButton(
        icon: Icon(Icons.play_arrow),
        iconSize: 20.0,
        onPressed: m.play,
      );

  IconButton pauseButton(MusicPlayerManager m) => IconButton(
        icon: Icon(Icons.pause),
        iconSize: 20.0,
        onPressed: m.pause,
      );

  IconButton shuffle(MusicPlayerManager m) => IconButton(
        icon: Icon(Icons.shuffle),
        iconSize: 20.0,
        onPressed: m.shuffle,
      );

  IconButton stopButton() => IconButton(
        icon: Icon(Icons.stop),
        iconSize: 20.0,
        onPressed: AudioService.stop,
      );

  IconButton addMore(MusicPlayerManager m) => IconButton(
        icon: Icon(Icons.add),
        iconSize: 20.0,
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
