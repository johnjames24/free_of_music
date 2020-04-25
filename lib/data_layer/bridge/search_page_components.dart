part of k.data_layer;

class LazyList<T> extends StatefulWidget {
  final LazyPages<T> lazyList;
  final Widget Function(BuildContext, T) builder;
  final Widget placeholder;
  final Axis scrollDirection;
  final int loadOffset;

  const LazyList({
    Key key,
    @required this.lazyList,
    @required this.builder,
    @required this.placeholder,
    this.scrollDirection = Axis.vertical,
    this.loadOffset = 500,
  }) : super(key: key);

  @override
  _LazyListState<T> createState() => _LazyListState<T>();
}

class _LazyListState<T> extends State<LazyList<T>> {
  ScrollController _controller;
  bool _mounted;

  @override
  initState() {
    super.initState();
    _mounted = true;

    _controller = ScrollController();

    var _isLoading = false;
    _controller.addListener(() async {
      if (!_isLoading && _controller.position.extentAfter < widget.loadOffset) {
        _isLoading = true;
        await widget.lazyList.addMore();

        if (_mounted) setState(() {});
        _isLoading = false;
      }
    });
  }

  @override
  dispose() {
    _mounted = false;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.lazyList != null
        ? ListView.builder(
            controller: _controller,
            scrollDirection: widget.scrollDirection,
            itemCount: widget.lazyList.orginalLength,
            physics: BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              T unit = widget.lazyList[index];
              return Container(
                key: UniqueKey(),
                child: unit != null || widget.lazyList != null
                    ? widget.builder(context, unit)
                    : widget.placeholder,
              );
            })
        : Container();
  }
}

class BestMatchCard extends StatelessWidget {
  final Object bestMatch;
  final Widget Function(BuildContext, spotify.Artist) artistBuilder;
  final Widget Function(BuildContext, spotify.PlaylistSimple) playlistBuilder;
  final Widget Function(BuildContext, spotify.AlbumSimple) albumBuilder;
  final Widget Function(BuildContext, spotify.Track) trackBuilder;

  BestMatchCard({
    @required this.bestMatch,
    @required this.artistBuilder,
    @required this.albumBuilder,
    @required this.playlistBuilder,
    @required this.trackBuilder,
  });

  _buildCard(BuildContext context) {
    if (bestMatch is spotify.AlbumSimple) {
      return albumBuilder(context, bestMatch);
    } else if (bestMatch is spotify.PlaylistSimple) {
      return playlistBuilder(context, bestMatch);
    } else if (bestMatch is spotify.Artist) {
      return artistBuilder(context, bestMatch);
    } else if (bestMatch is spotify.Track) {
      return trackBuilder(context, bestMatch);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildCard(context);
  }
}
