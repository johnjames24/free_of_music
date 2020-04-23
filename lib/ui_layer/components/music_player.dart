part of k.ui_layer;

calculatePositionPercentage(ScreenState screenState) {
  var position = screenState?.playbackState?.position ?? 0;
  var duration = screenState?.mediaItem?.duration ?? 1;
  return position / duration;
}

navigateToPlaylist(BuildContext context) {
  Navigator.of(context)
      .push(MaterialPageRoute(builder: (context) => PlaylistPage()));
}

navigateBack(BuildContext context) {
  Navigator.of(context).pop();
}

navigateToMusicPlayer(BuildContext context) {
  Navigator.of(context)
      .push(MaterialPageRoute(builder: (context) => MusicPlayer()));
}

playPauseButton(BasicPlaybackState basicState) {
  if (basicState == BasicPlaybackState.playing)
    return IconButton(
      iconSize: 50,
      icon: Icon(Icons.pause_circle_outline),
      onPressed: AudioService.pause,
    );
  else if (basicState == BasicPlaybackState.paused)
    return IconButton(
      iconSize: 50,
      icon: Icon(Icons.play_circle_outline),
      onPressed: AudioService.play,
    );
  else if (basicState == BasicPlaybackState.buffering ||
      basicState == BasicPlaybackState.skippingToNext ||
      basicState == BasicPlaybackState.skippingToPrevious)
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        width: 35,
        height: 35,
        child: CircularProgressIndicator(),
      ),
    );
  else
    return Container();
}

class MiniMusicPlayer extends StatelessWidget {
  playPauseButton(BasicPlaybackState basicState) {
    if (basicState == BasicPlaybackState.playing)
      return IconButton(
        iconSize: 35,
        icon: Icon(Icons.pause_circle_outline),
        onPressed: AudioService.pause,
      );
    else if (basicState == BasicPlaybackState.paused)
      return IconButton(
        iconSize: 35,
        icon: Icon(Icons.play_circle_outline),
        onPressed: AudioService.play,
      );
    else if (basicState == BasicPlaybackState.buffering ||
        basicState == BasicPlaybackState.skippingToNext ||
        basicState == BasicPlaybackState.skippingToPrevious)
      return Container(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(),
      );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenStateBuilder(builder: (context, screenState) {
      return InheritedMusicplayer.of(context).isPlaying
          ? GestureDetector(
              onVerticalDragEnd: (detail) {
                var primaryVelocity = detail.primaryVelocity;
                if (primaryVelocity < -10) navigateToMusicPlayer(context);
                if (primaryVelocity > 200) AudioService.stop();
              },
              onDoubleTap: () => navigateToMusicPlayer(context),
              child: Card(
                elevation: 15,
                margin: EdgeInsets.all(0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SimpleSlider(
                      builder: (context, pos, dur) => Container(
                        color: Theme.of(context).accentColor,
                        height: 3,
                        width: MediaQuery.of(context).size.width *
                            (dur != 0 ? pos / dur : 0),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          height: 60,
                          width: MediaQuery.of(context).size.width * 0.13,
                          child: IconButton(
                            icon: Icon(Icons.favorite),
                            onPressed: () => print("liked"),
                          ),
                        ),
                        Container(
                          height: 60,
                          width: MediaQuery.of(context).size.width * 0.70,
                          child: PageViewPlaylist(
                            builder: (context, mediaItem) => Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text("${mediaItem?.title}"),
                                Text("${mediaItem?.artist}"),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          height: 60,
                          width: MediaQuery.of(context).size.width * 0.13,
                          child: Center(
                            child: Container(
                              child: playPauseButton(
                                  screenState?.playbackState?.basicState),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            )
          : Container();
    });
  }
}

class MusicPlayer extends StatefulWidget {
  @override
  _MusicPlayerState createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> {
  var isCalm = false;
  var sliderSelect = false;

  PaletteGenerator palette;

  loadImageProvider(ImageProvider provider) {
    PaletteGenerator.fromImageProvider(provider).then((value) {
      setState(() {
        palette = value;
      });
    });

    return provider;
  }

  String parseTimeString(Duration duration) {
    addStringZeros(int val) {
      return val > 9 ? "$val" : "0$val";
    }

    var min = duration.inMinutes;
    var sec = duration.inSeconds %
        (duration.inMinutes != 0 ? duration.inMinutes * 60 : 60);

    return "${addStringZeros(min)}:${addStringZeros(sec)}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onVerticalDragEnd: (detail) {
          var primaryVelocity = detail.primaryVelocity;
          if (primaryVelocity > 10) navigateBack(context);
          if (primaryVelocity < -10) navigateToPlaylist(context);
        },
        onDoubleTap: () => setState(() {
          isCalm = !isCalm;
        }),
        child: ScreenStateBuilder(
          builder: (context, screenState) => Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: AlignmentDirectional.bottomCenter,
                    stops: [
                  0.0,
                  0.5
                ],
                    colors: [
                  palette?.dominantColor?.color ?? Theme.of(context).cardColor,
                  Theme.of(context).cardColor
                ])),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  child: SafeArea(
                    child: Hidden(
                      show: !isCalm,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          RotatedBox(
                            quarterTurns: 1,
                            child: IconButton(
                              iconSize: 30,
                              icon: Icon(Icons.navigate_next),
                              onPressed: () => navigateBack(context),
                            ),
                          ),
                          IconButton(
                            iconSize: 30,
                            icon: Icon(Icons.more_vert),
                            onPressed: () => print("down"),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.height * 0.05),
                  child: GestureDetector(
                    onDoubleTap: () {},
                    child: Container(
                      height: MediaQuery.of(context).size.height * .37,
                      child: PageViewPlaylist(
                        builder: (context, mediaItem) => Image(
                          image:
                              loadImageProvider(NetworkImage(mediaItem.artUri)),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: <Widget>[
                        Hidden(
                          show: !isCalm,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text("${screenState?.mediaItem?.title}"),
                                  Text("${screenState?.mediaItem?.artist}"),
                                ],
                              ),
                              IconButton(
                                icon: Icon(Icons.favorite),
                                onPressed: () => print("clicked"),
                              )
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Hidden(
                              show: !isCalm,
                              child: SimpleSlider(
                                builder: (context, pos, dur) => Text(
                                    parseTimeString(
                                        Duration(milliseconds: pos ?? 0))),
                              ),
                            ),
                            Expanded(
                              child: SliderTheme(
                                data: Theme.of(context).sliderTheme.copyWith(
                                      thumbShape: RoundSliderThumbShape(
                                        enabledThumbRadius:
                                            sliderSelect ? 5 : 0,
                                      ),
                                      //round indicator
                                      thumbColor: palette?.colors?.first,

                                      //around sound indicator
                                      overlayColor:
                                          palette?.colors?.first?.withAlpha(80),

                                      //min to thumb
                                      activeTrackColor: palette?.colors?.first,

                                      //thimb to max
                                      inactiveTrackColor: Theme.of(context)
                                          .iconTheme
                                          .color
                                          .withAlpha(100),
                                    ),
                                child: PositionSliderBuilder(
                                  builder: (context, onChanged, onChangeEnd,
                                          value, duration,
                                          [screenState]) =>
                                      Slider(
                                    min: 0.0,
                                    max: duration ?? 0,
                                    value: value ?? 0,
                                    onChanged: onChanged,
                                    onChangeEnd: (value) {
                                      onChangeEnd(value);
                                      setState(() {
                                        sliderSelect = false;
                                      });
                                    },
                                    onChangeStart: (value) => setState(() {
                                      sliderSelect = true;
                                    }),
                                  ),
                                ),
                              ),
                            ),
                            Hidden(
                              show: !isCalm,
                              child: Text(
                                parseTimeString(
                                  Duration(
                                      milliseconds:
                                          screenState?.mediaItem?.duration ??
                                              0),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            IconButton(
                              icon: Icon(Icons.skip_previous),
                              onPressed: AudioService.skipToPrevious,
                            ),
                            playPauseButton(
                                screenState?.playbackState?.basicState),
                            IconButton(
                              onPressed: AudioService.skipToNext,
                              icon: Icon(Icons.skip_next),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                Hidden(
                  show: !isCalm,
                  child: Container(
                      child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      IconButton(
                        iconSize: 30,
                        icon: Icon(Icons.playlist_play),
                        onPressed: () => navigateToPlaylist(context),
                      ),
                      IconButton(
                        iconSize: 30,
                        icon: Icon(Icons.shuffle),
                        color: InheritedMusicplayer.of(context).isShuffled
                            ? Theme.of(context).accentColor
                            : Theme.of(context).iconTheme.color,
                        onPressed: InheritedMusicplayer.of(context).shuffle,
                      )
                    ],
                  )),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PlaylistPage extends StatelessWidget {
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

  historyList(List<MediaItem> list, MusicPlayerManager m) {
    var i = 0;
    return list.map((e) {
      i++;
      var x = i;
      return ListTile(
        leading: IconButton(
          icon: Icon(Icons.music_note),
          onPressed: () async {
            m.playIndexOf(-x);
          },
        ),
        title: Text(e.title),
        key: UniqueKey(),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenStateBuilder(
        builder: (context, screenState) => Column(
          children: <Widget>[
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(0)),
              ),
              margin: EdgeInsets.all(0),
              child: Container(
                height: MediaQuery.of(context).size.height * .3 - 3,
                width: MediaQuery.of(context).size.width,
                child: SafeArea(
                    child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        IconButton(
                          iconSize: 30,
                          icon: Icon(Icons.arrow_back),
                          onPressed: () => navigateBack(context),
                        ),
                        IconButton(
                          iconSize: 30,
                          icon: Icon(Icons.more_vert),
                          onPressed: () => print("down"),
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: <Widget>[
                              if (screenState?.mediaItem != null)
                                Image.network(
                                  screenState?.mediaItem?.artUri,
                                  width: 80,
                                ),
                              Padding(
                                padding: const EdgeInsets.only(left: 30),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      "Now Playing",
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6
                                          .copyWith(
                                            fontWeight: FontWeight.w100,
                                          ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Text(
                                        "${screenState?.mediaItem?.title}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle1
                                            .copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                    Text(
                                      "${screenState?.mediaItem?.artist}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle2
                                          .copyWith(
                                            fontWeight: FontWeight.w100,
                                          ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                )),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * .6,
              child: DefaultTabController(
                length: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: 50,
                      width: 200,
                      child: TabBar(
                        indicatorColor: Colors.blueGrey,
                        indicatorWeight: 5,
                        indicatorSize: TabBarIndicatorSize.label,
                        indicatorPadding: EdgeInsets.symmetric(horizontal: 10),
                        tabs: <Widget>[
                          Tab(
                            child: Text(
                              "Queue",
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .color),
                            ),
                          ),
                          Tab(
                            child: Text(
                              "History",
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .color),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * .6 - 50,
                      child: TabBarView(
                        children: <Widget>[
                          ReorderablePlaylist(
                              builder: (build, onReorder, list) =>
                                  ReorderableListView(
                                    children: reorederableListItems(list,
                                            InheritedMusicplayer.of(context)) ??
                                        [],
                                    onReorder: onReorder,
                                  ),
                              stream: InheritedMusicplayer.of(context)
                                  .playlist
                                  .queueStream),
                          StreamBuilder<List<MediaItem>>(
                            stream: InheritedMusicplayer.of(context)
                                .playlist
                                .historyStream,
                            builder: (context, snapshot) =>
                                snapshot?.data == null
                                    ? Container()
                                    : ListView(
                                        children: historyList(snapshot.data,
                                            InheritedMusicplayer.of(context)),
                                      ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(0)),
              ),
              margin: EdgeInsets.all(0),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * .1 + 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SimpleSlider(
                      builder: (context, pos, dur) => Container(
                        color: Theme.of(context).accentColor,
                        height: 3,
                        width: MediaQuery.of(context).size.width *
                            (dur != 0 ? pos / dur : 0),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        IconButton(
                          iconSize: 18,
                          icon: Icon(Icons.favorite),
                          onPressed: () => print("down"),
                        ),
                        IconButton(
                          icon: Icon(Icons.skip_previous),
                          onPressed: () => AudioService.skipToNext(),
                        ),
                        playPauseButton(screenState?.playbackState?.basicState),
                        IconButton(
                          onPressed: () => AudioService.skipToNext(),
                          icon: Icon(Icons.skip_next),
                        ),
                        IconButton(
                          iconSize: 18,
                          icon: Icon(Icons.shuffle),
                          color: InheritedMusicplayer.of(context).isShuffled
                              ? Theme.of(context).accentColor
                              : Theme.of(context).iconTheme.color,
                          onPressed: InheritedMusicplayer.of(context).shuffle,
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Hidden extends StatefulWidget {
  final bool show;
  final Widget child;

  Hidden({
    @required this.child,
    this.show = true,
  });

  @override
  _HiddenState createState() => _HiddenState();
}

class _HiddenState extends State<Hidden> with TickerProviderStateMixin {
  AnimationController controller;
  Animation<double> animation;

  var value = 1.0;
  var _showOld;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    animation = Tween<double>(begin: 1, end: 0).animate(controller);

    animation.addListener(() {
      setState(() {
        value = animation.value;
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  shouldUpdate() => _showOld != widget.show;

  animate() {
    if (shouldUpdate()) {
      _showOld = widget.show;
      if (!widget.show && value == 1)
        controller.forward();
      else if (value == 0) {
        controller.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    animate();
    return Visibility(
      maintainAnimation: true,
      maintainState: true,
      maintainSize: true,
      maintainInteractivity: false,
      visible: value != 0,
      child: Opacity(
        opacity: animation.value,
        child: widget.child,
      ),
    );
  }
}
