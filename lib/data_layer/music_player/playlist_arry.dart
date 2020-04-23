part of k.data_layer;

enum ChangeEvent {
  skippingToNext,
  skippingToPrevious,
  skippingToQueueItem,
  initiatePlaylist,
}

class PlaylistArray<T> {
  List<T> _queue = [];
  List<T> _history = [];
  T _current;

  BehaviorSubject<IndexChangeEvent<T>> _valueSubject = BehaviorSubject();
  BehaviorSubject<List<T>> _queueSubject = BehaviorSubject<List<T>>();
  BehaviorSubject<List<T>> _historySubject = BehaviorSubject<List<T>>();

  get hasNext => _queue.length != 0;
  get isFirst => _history.length == 0;

  ValueStream<IndexChangeEvent<T>> get currentStream => _valueSubject.stream;
  ValueStream<List<T>> get queueStream => _queueSubject.stream;
  ValueStream<List<T>> get historyStream => _historySubject.stream;

  get current => _current;
  get queue => _queue;
  get history => _history;

  List<T> get mediaQueue {
    return [
      ...(_history.reversed),
      _current,
      ..._queue,
    ];
  }

  PlaylistArray() {
    _queueUpdate();
    _historyUpdate();
  }

  init(List<T> list) {
    _history = [];
    _current = list.removeAt(0);
    _queue = list;

    _queueUpdate();
    _historyUpdate();
    _updateCurrent(ChangeEvent.initiatePlaylist);
  }

  PlaylistArray.fromList(List<T> list) {
    _current = list.removeAt(0);

    _history = List<T>.of([], growable: true);
    _queue = List<T>.of([...list], growable: true);

    _queueUpdate();
    _historyUpdate();
    _updateCurrent(ChangeEvent.initiatePlaylist);
  }

  initWithStream({
    ValueStream<List<T>> historyStream,
    ValueStream<List<T>> queueStream,
  }) async {
    var queue = queueStream.listen(_queueSubject.add);
    var history = historyStream.listen(_historySubject.add);

    await queueStream.last;
    await historyStream.last;
    history.cancel();
    queue.cancel();
  }

  next() {
    skip(1, false);
    _updateCurrent(ChangeEvent.skippingToNext);
  }

  back() {
    skip(-1, false);
    _updateCurrent(ChangeEvent.skippingToPrevious);
  }

  move(int oldOffset, int newOffset) {
    if (isValidOffset(oldOffset) && isValidOffset(newOffset) && newOffset > 0) {
      if (oldOffset > 0) {
        var val = _queue.removeAt(oldOffset - 1);
        _queue.insert(newOffset - 1, val);
      } else {
        var val = _history.removeAt(-oldOffset - 1);
        _queue.insert(newOffset - 1, val);
      }
      _queueUpdate();
      _historyUpdate();
    }
  }

  remove(int offset) {
    if (isValidOffset(offset)) {
      if (offset > 0) {
        _queue.removeAt(offset - 1);
        _queueUpdate();
      } else {
        _history.removeAt(-offset - 1);
        _historyUpdate();
      }
    }
  }

  shuffle() {
    _queue.shuffle();
    _queueUpdate();
  }

  insert(int offset, T item) {
    _queue[offset - 1] = item;
    _queueUpdate();
  }

  addAll(List<T> list) {
    _queue.addAll(list);
    _queueUpdate();
  }

  skip(int offset, [bool update = true]) {
    if (isValidOffset(offset)) {
      if (offset > 0) {
        var index = offset - 1;
        _history.insert(0, _current);
        if (hasNext) _current = _queue.removeAt(index);
      } else {
        var index = -offset - 1;
        _queue.insert(0, _current);
        if (!isFirst) _current = _history.removeAt(index);
      }

      _queueUpdate();
      _historyUpdate();
      if (update) {
        _updateCurrent(ChangeEvent.skippingToQueueItem);
      }
    }
  }

  isValidOffset(int x) {
    return (x > 0 && x <= _queue.length) || (x < 0 && -x <= _history.length);
  }

  _queueUpdate() {
    _queueSubject.add(_queue);
  }

  _historyUpdate() {
    _historySubject.add(_history);
  }

  _updateCurrent(ChangeEvent event) {
    _valueSubject.add(IndexChangeEvent(data: _current, eventChange: event));
  }

  cleanUp() {
    _valueSubject.close();
    _historySubject.close();
    _queueSubject.close();
  }
}

class IndexChangeEvent<T> {
  T data;

  ChangeEvent eventChange;

  IndexChangeEvent({
    this.data,
    this.eventChange,
  });
}
