library k.data_layer;

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:html/parser.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';
import 'package:spotify/spotify_io.dart' as spotify;
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;
import 'package:path_provider/path_provider.dart' as path_provider;

//music player
part 'music_player/util.dart';
part 'music_player/playlist_manager.dart';
part 'music_player/player_task.dart';
part 'music_player/music_player_manager.dart';
part 'music_player/playlist_arry.dart';

//data storage and caching
part 'data_storage/basic_data_manager.dart';
part 'data_storage/youtube_data_manager.dart';
part 'data_storage/youtube_data_model.dart';

//tests and samples
part 'test/player.dart';
part 'test/example.dart';

//bridges
part 'bridge/music_player_components.dart';
part 'bridge/search_page_components.dart';

//utilities
part 'util/lazy_page.dart';

//api
part 'api_manager/search.dart';

//auto generated
part 'data_layer.g.dart';
