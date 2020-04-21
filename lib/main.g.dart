// GENERATED CODE - DO NOT MODIFY BY HAND

part of k;

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MediaContainerAdapter extends TypeAdapter<MediaContainer> {
  @override
  MediaContainer read(BinaryReader reader) {
    switch (reader.readByte()) {
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

  @override
  void write(BinaryWriter writer, MediaContainer obj) {
    switch (obj) {
      case MediaContainer.mp4:
        writer.writeByte(0);
        break;
      case MediaContainer.webM:
        writer.writeByte(1);
        break;
      case MediaContainer.tgpp:
        writer.writeByte(2);
        break;
    }
  }
}

class AudioEncodingAdapter extends TypeAdapter<AudioEncoding> {
  @override
  AudioEncoding read(BinaryReader reader) {
    switch (reader.readByte()) {
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

  @override
  void write(BinaryWriter writer, AudioEncoding obj) {
    switch (obj) {
      case AudioEncoding.aac:
        writer.writeByte(0);
        break;
      case AudioEncoding.vorbis:
        writer.writeByte(1);
        break;
      case AudioEncoding.opus:
        writer.writeByte(2);
        break;
    }
  }
}

class YtSpotiyBridgeAdapter extends TypeAdapter<YtSpotiyBridge> {
  @override
  YtSpotiyBridge read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return YtSpotiyBridge()
      ..spotifyId = fields[0] as String
      ..youtubeId = fields[1] as String
      ..onTime = fields[3] as Date
      ..durationInMilliseconds = fields[4] as int;
  }

  @override
  void write(BinaryWriter writer, YtSpotiyBridge obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.spotifyId)
      ..writeByte(1)
      ..write(obj.youtubeId)
      ..writeByte(3)
      ..write(obj.onTime)
      ..writeByte(4)
      ..write(obj.durationInMilliseconds);
  }
}

class YtMediaAdapter extends TypeAdapter<YtMedia> {
  @override
  YtMedia read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return YtMedia()
      ..youtubeId = fields[1] as String
      ..formats = (fields[2] as List)?.cast<Format>()
      ..onTime = fields[3] as Date;
  }

  @override
  void write(BinaryWriter writer, YtMedia obj) {
    writer
      ..writeByte(3)
      ..writeByte(1)
      ..write(obj.youtubeId)
      ..writeByte(2)
      ..write(obj.formats)
      ..writeByte(3)
      ..write(obj.onTime);
  }
}

class FormatAdapter extends TypeAdapter<Format> {
  @override
  Format read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Format()
      ..size = fields[0] as int
      ..container = fields[1] as MediaContainer
      ..bitrate = fields[2] as int
      ..audioEncoding = fields[3] as AudioEncoding
      ..url = fields[4] as String;
  }

  @override
  void write(BinaryWriter writer, Format obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.size)
      ..writeByte(1)
      ..write(obj.container)
      ..writeByte(2)
      ..write(obj.bitrate)
      ..writeByte(3)
      ..write(obj.audioEncoding)
      ..writeByte(4)
      ..write(obj.url);
  }
}

class DateAdapter extends TypeAdapter<Date> {
  @override
  Date read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Date()..microsecondsSinceEpoch = fields[0] as int;
  }

  @override
  void write(BinaryWriter writer, Date obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.microsecondsSinceEpoch);
  }
}
