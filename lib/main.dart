library k;

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:html/parser.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:spotify/spotify_io.dart' as spotify;
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:hive/hive.dart';

part 'root.dart';
part 'data_layer/music_player/player.dart';
part 'data_layer/music_player/util.dart';
part 'data_layer/music_player/playlist_manager.dart';
part 'data_layer/music_player/player_task.dart';
part 'data_layer/music_player/music_player_components.dart';
part 'data_layer/music_player/music_player_manager.dart';
part 'data_layer/music_player/playlist_arry.dart';
part 'data_layer/data_storage/basic_data_manager.dart';
part 'data_layer/data_storage/example.dart';
part 'data_layer/data_storage/youtube_data_manager.dart';
part 'data_layer/data_storage/youtube_data_model.dart';
part 'main.g.dart';
