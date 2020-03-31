part of k;

class MusicPlayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var imgUrl =
        "https://images.genius.com/9eaffc86180a5a1afa80243553b8dd5c.1000x1000x1.jpg";
    var imgUrl2 = "https://m.media-amazon.com/images/I/61gd8suO3+L._SS500_.jpg";

    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.keyboard_arrow_down),
            onPressed: () => print("close"),
          ),
          Container(
            height: 350,
            padding: EdgeInsets.symmetric(vertical: 40),
            width: double.infinity,
            child: PageView(
              children: <Widget>[
                ClipRect(
                  child: Container(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Card(
                        elevation: 10,
                        child: Image.network(imgUrl),
                      ),
                      heightFactor: 1,
                      widthFactor: 1,
                    ),
                  ),
                ),
                ClipRect(
                  child: Container(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Card(
                        elevation: 10,
                        child: Image.network(imgUrl2),
                      ),
                      heightFactor: 1,
                      widthFactor: 1,
                    ),
                  ),
                )
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Adventure of Lifetime",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Coldplay",
                        style: TextStyle(
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackShape: _$SliderWithoutSidePadding(),
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 5),
                  ),
                  child: Slider(
                    min: 0,
                    max: 100,
                    value: 50,
                    onChanged: (val) => print("new val - $val"),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("1:24",
                        style: TextStyle(
                          fontSize: 10,
                        )),
                    Text("5:54",
                        style: TextStyle(
                          fontSize: 10,
                        )),
                  ],
                )
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                iconSize: 20,
                icon: Icon(Icons.favorite_border),
                onPressed: () => print("close"),
              ),
              IconButton(
                iconSize: 30,
                icon: Icon(Icons.skip_previous),
                onPressed: () => print("close"),
              ),
              _$AnimatedPlayPause(
                onPress: (state) => print("is playing: $state"),
              ),
              IconButton(
                iconSize: 30,
                icon: Icon(Icons.skip_next),
                onPressed: () => print("close"),
              ),
              IconButton(
                iconSize: 20,
                icon: Icon(Icons.shuffle),
                onPressed: () => print("close"),
              )
            ],
          ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.playlist_play),
                onPressed: () => print("playlist"),
              ),
              IconButton(
                icon: Icon(Icons.more_vert),
                onPressed: () => print("playlist"),
              )
            ],
          )
        ],
      ),
    );
  }
}

class _$AnimatedPlayPause extends StatefulWidget {
  const _$AnimatedPlayPause({
    Key key,
    @required this.onPress,
    this.initState = false,
  }) : super(key: key);

  final onPress;
  final bool initState;

  @override
  __$AnimatedPlayPauseState createState() => __$AnimatedPlayPauseState();
}

class __$AnimatedPlayPauseState extends State<_$AnimatedPlayPause>
    with TickerProviderStateMixin {
  AnimationController _animationController;
  bool isPlaying;

  @override
  initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    isPlaying = widget.initState;
  }

  @override
  dispose() {
    super.dispose();
    _animationController.dispose();
  }

  pressHandler() {
    setState(() {
      isPlaying = !isPlaying;
      if (isPlaying)
        _animationController.forward();
      else
        _animationController.reverse();
    });

    widget.onPress(isPlaying);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(40.0)),
            border: Border.all(
              color: Colors.white,
              width: 3,
            )),
        child: IconButton(
          iconSize: 50,
          icon: AnimatedIcon(
            icon: AnimatedIcons.play_pause,
            progress: _animationController,
          ),
          onPressed: pressHandler,
        ),
      ),
    );
  }
}

class _$SliderWithoutSidePadding extends RoundedRectSliderTrackShape {
  Rect getPreferredRect({
    @required RenderBox parentBox,
    Offset offset = Offset.zero,
    @required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
