part of k;

///root of every AudioService
class AudioServiceRoot extends StatefulWidget {
  final child;

  AudioServiceRoot({
    @required this.child,
  });

  @override
  _AudioServiceRootState createState() => _AudioServiceRootState();
}

///root of all AudioService
class _AudioServiceRootState extends State<AudioServiceRoot>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    connect();
  }

  @override
  void dispose() {
    disconnect();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        connect();
        break;
      case AppLifecycleState.paused:
        disconnect();
        break;
      default:
        break;
    }
  }

  void connect() async {
    await AudioService.connect();
  }

  void disconnect() {
    AudioService.disconnect();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: widget.child,
        onWillPop: () {
          disconnect();
          return Future.value(true);
        });
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
    return StreamBuilder<ScreenState>(
      stream: Rx.combineLatest3<List<MediaItem>, MediaItem, PlaybackState,
              ScreenState>(
          AudioService.queueStream,
          AudioService.currentMediaItemStream,
          AudioService.playbackStateStream,
          (queue, mediaItem, playbackState) =>
              ScreenState(queue, mediaItem, playbackState)),
      builder: (context, snapshot) {
        return builder(context, snapshot.data);
      },
    );
  }
}
