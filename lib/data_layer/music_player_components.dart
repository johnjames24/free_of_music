part of k;

///root of every AudioService
class AudioServiceRoot extends StatelessWidget {
  final Widget child;

  AudioServiceRoot({
    @required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AudioServiceWidget(
      child: InheritedMusicplayer(
        musicPlayer: MusicPlayerManager(),
        child: child,
      ),
    );
  }
}

class InheritedMusicplayer extends InheritedWidget {
  final MusicPlayerManager musicPlayer;

  InheritedMusicplayer({
    @required this.musicPlayer,
    Key key,
    Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    throw false;
  }

  static MusicPlayerManager of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<InheritedMusicplayer>()
        .musicPlayer;
  }
}

///buildes position slider from AudioService Stream
class PositionSliderBuilder extends StatefulWidget {
  final Widget Function(BuildContext context, void Function(double) onChanged,
      void Function(double) onChangedEnd, double value, double duration,
      [ScreenState screenState]) builder;

  PositionSliderBuilder({
    @required this.builder,
  });

  @override
  _PositionSliderBuilderState createState() => _PositionSliderBuilderState();
}

class _PositionSliderBuilderState extends State<PositionSliderBuilder> {
  final BehaviorSubject<double> _dragPositionSubject =
      BehaviorSubject.seeded(null);

  onChange(value) {
    _dragPositionSubject.add(value);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenStateBuilder(
      builder: (context, screenState) {
        return StreamBuilder<double>(
          stream: Rx.combineLatest2<double, double, double>(
              _dragPositionSubject.stream,
              Stream.periodic(Duration(milliseconds: 200)),
              (dragPosition, _) => dragPosition),
          builder: (context, snapshot) {
            return positionSlider(context, snapshot, screenState);
          },
        );
      },
    );
  }

  positionSlider(BuildContext context, AsyncSnapshot<double> snapshot,
      ScreenState screenState) {
    var seekPos;
    double position = snapshot.data ??
        screenState?.playbackState?.currentPosition?.toDouble() ??
        0;
    double duration = screenState?.mediaItem?.duration?.toDouble() ?? 0;
    double value = seekPos ?? max(0.0, min(position, duration));
    return widget.builder(
      context,
      onChange,
      (value) {
        AudioService.seekTo(value.toInt());
        // Due to a delay in platform channel communication, there is
        // a brief moment after releasing the Slider thumb before the
        // new position is broadcast from the platform side. This
        // hack is to hold onto seekPos until the next state update
        // comes through.
        seekPos = value;

        _dragPositionSubject.add(null);
      },
      value,
      duration,
      screenState,
    );
  }
}

///buildes Screen state from AudioService Stream
class ScreenStateBuilder extends StatelessWidget {
  final Widget Function(BuildContext, ScreenState) builder;

  ScreenStateBuilder({
    @required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    var musicPlayerManager = InheritedMusicplayer.of(context);
    return StreamBuilder<ScreenState>(
      stream: Rx.combineLatest4<List<MediaItem>, List<MediaItem>, MediaItem,
              PlaybackState, ScreenState>(
          musicPlayerManager.playlist.historyStream,
          musicPlayerManager.playlist.queueStream,
          AudioService.currentMediaItemStream,
          AudioService.playbackStateStream,
          (history, queue, mediaItem, playbackState) =>
              ScreenState(queue, history, mediaItem, playbackState)),
      builder: (context, snapshot) {
        return builder(context, snapshot.data);
      },
    );
  }
}

class ReorderablePlaylist extends StatefulWidget {
  final Widget Function(BuildContext, Function(int, int), List<MediaItem>)
      builder;
  final Stream<List<MediaItem>> stream;

  ReorderablePlaylist({
    @required this.builder,
    @required this.stream,
  });

  @override
  _ReorderablePlaylistState createState() => _ReorderablePlaylistState();
}

class _ReorderablePlaylistState extends State<ReorderablePlaylist> {
  var listener;

  List<MediaItem> list = [];

  @override
  initState() {
    super.initState();
    listener = widget.stream.listen((event) {
      setState(() {
        list = event;
      });
    });
  }

  @override
  dispose() {
    listener.cancel();
    super.dispose();
  }

  onChange(BuildContext context) {
    var musicPlayerManager = InheritedMusicplayer.of(context);
    return (int oldIndex, int newIndex) {
      if (oldIndex < list.length &&
          newIndex < list.length &&
          newIndex >= 0 &&
          oldIndex >= 0) {
        setState(() {
          var val = list.removeAt(oldIndex);
          list.insert(newIndex, val);
        });
        musicPlayerManager.move(oldIndex + 1, newIndex + 1);
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      onChange(context),
      list,
    );
  }
}
