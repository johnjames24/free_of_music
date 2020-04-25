part of k.data_layer;

class LazyPages<T> {
  int _limit = 0;
  int _loadOffset = 5;

  List<spotify.Page<T>> _bufferedPages = [];
  spotify.Page<T> _root;
  Map<String, dynamic> Function(Map<String, dynamic>) _containerParser;

  bool get hasNext => !_bufferedPages.last.isLast;
  int get length => _root.metadata.total;
  int get orginalLength {
    if (_bufferedPages.length == 1) return _bufferedPages.first.items.length;

    return _limit * (_bufferedPages.length - 1) +
        _bufferedPages.last.items.length;
  }

  LazyPages(this._root, [this._containerParser]) {
    _bufferedPages.add(_root);
    _limit = _root.metadata.limit;
  }

  Future<void> addMore() async {
    if (hasNext) {
      print("loading $_limit more (loaded $orginalLength)");
      var jsonString = await _root.get(_bufferedPages.last.metadata.next);
      var paging = spotify.Paging<T>.fromJson(
          (_containerParser ?? (json) => json)(jsonDecode(jsonString)));
      _bufferedPages.add(new spotify.Page<T>(paging, _root.parser, _root.get));
    }
  }

  T operator [](int x) {
    if (x < 0 && x >= _root.metadata.total)
      throw RangeError.range(x, 0, _root.metadata.total - 1);

    if (((x + _loadOffset) / _limit).floor() >= _bufferedPages.length &&
        x >= _bufferedPages.last.items.length) return null;

    return _bufferedPages[(x / _limit).floor()].items.toList()[x % _limit];
  }
}
