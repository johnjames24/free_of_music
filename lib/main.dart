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
import 'package:spotify/spotify_io.dart' as spotify;
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

part 'root.dart';
part 'components/music_player/music_player.dart';
part 'components/music_player/playlist_display.dart';
part 'data_layer/player.dart';
part 'data_layer/util.dart';
part 'data_layer/playlist_manager.dart';
