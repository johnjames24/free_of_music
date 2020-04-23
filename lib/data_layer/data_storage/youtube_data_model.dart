part of k.data_layer;

@HiveType()
class YtSpotiyBridge {
  @HiveField(0)
  String spotifyId;

  @HiveField(1)
  String youtubeId;

  @HiveField(3)
  Date onTime;

  @HiveField(4)
  int durationInMilliseconds;

  YtSpotiyBridge();

  YtSpotiyBridge.fromValue(
      {this.spotifyId,
      this.youtubeId,
      this.durationInMilliseconds,
      this.onTime});
}

@HiveType()
class YtMedia {
  @HiveField(1)
  String youtubeId;

  @HiveField(2)
  List<Format> formats;

  @HiveField(3)
  Date onTime;

  YtMedia();

  YtMedia.fromValue({
    this.youtubeId,
    this.formats,
    this.onTime,
  });
}

@HiveType()
class Format {
  /// Content length (bytes) of the associated stream.
  @HiveField(0)
  int size;

  /// Container of the associated stream.
  @HiveField(1)
  MediaContainer container;

  /// Bitrate (bits/s) of the associated stream.
  @HiveField(2)
  int bitrate;

  /// Audio encoding of the associated stream.
  @HiveField(3)
  AudioEncoding audioEncoding;

  ///url of the format
  @HiveField(4)
  String url;

  Format();

  Format.fromValues({
    this.url,
    this.audioEncoding,
    this.container,
    this.size,
    this.bitrate,
  });
}

@HiveType()
class Date {
  @HiveField(0)
  int microsecondsSinceEpoch;

  Date();

  Date.now()
      : this.microsecondsSinceEpoch = DateTime.now().microsecondsSinceEpoch;

  Date.fromDateTime(DateTime date)
      : this.microsecondsSinceEpoch = date.microsecondsSinceEpoch;

  get dateTime =>
      new DateTime.fromMicrosecondsSinceEpoch(microsecondsSinceEpoch);
}

@HiveType()
enum MediaContainer {
  /// MPEG-4 Part 14 (.mp4).
  @HiveField(0)
  mp4,

  /// Web Media (.webm).
  @HiveField(1)
  webM,

  /// 3rd Generation Partnership Project (.3gpp).
  @HiveField(2)
  tgpp
}

/// AudioEncoding
@HiveType()
enum AudioEncoding {
  /// MPEG-4 Part 3, Advanced Audio Coding (AAC).
  @HiveField(0)
  aac,

  /// Vorbis.
  @HiveField(1)
  vorbis,

  /// Opus.
  @HiveField(2)
  opus
}

_convertEnumsContainer(yt.Container container) {
  switch (container.index) {
    case 0:
      return MediaContainer.mp4;
    case 1:
      return MediaContainer.webM;
    case 2:
      return MediaContainer.tgpp;
    default:
      return null;
  }
}

_convertEnumEncoding(yt.AudioEncoding encoding) {
  switch (encoding.index) {
    case 0:
      return AudioEncoding.aac;
    case 1:
      return AudioEncoding.vorbis;
    case 2:
      return AudioEncoding.opus;
    default:
      return null;
  }
}
