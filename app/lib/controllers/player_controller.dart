import 'dart:io';

import 'package:app/components/mini_player.dart';
import 'package:app/models/episode.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

class PlayerController {

  // App directory
  Directory? directory;

  // Audio Player
  final AudioPlayer player = AudioPlayer();

  // Current Episode
  final ValueNotifier<Episode?> episode = ValueNotifier<Episode?>(null);

  // Persistent Bottom Sheet
  PersistentBottomSheetController? sheet;

  // Global Scaffold Key
  final GlobalKey<ScaffoldState> scaffold = GlobalKey<ScaffoldState>();

  PlayerController(Directory? dir){
    directory = dir;
    initialize();
  }

  initialize(){
    backgroundAudioService();
  }
  
  // Play episode
  Future play(Episode toPlay, { bool autoPlay = true }) async {

    if(episode.value?.id != toPlay.id && autoPlay){
      showBanner();
    }
    
    Uri? uri = toPlay.audio;

    // Check if url exists
    if(uri == null) return;

    // Check if file exists locally
    if (!kIsWeb && toPlay.local != null && toPlay.local!.existsSync()) {
      uri = Uri.file(toPlay.local!.path);
    }
    
    AudioSource source = AudioSource.uri(
      uri,
      tag: MediaItem(
        id: toPlay.id.toString(),
        title: toPlay.title,
        artUri: toPlay.cover != null ? Uri.parse(toPlay.cover!) : null,
      ),
    );

    episode.value = toPlay;

    player.setAudioSource(source);

    if(autoPlay){
      player.play();
    }

    return;
  }

  Future stop() async {
    await player.stop();
    episode.value = null;
  }

  void showBanner() async {
    if(sheet == null){
      sheet = scaffold.currentState!.showBottomSheet((context) => MiniPlayer(
        key: Key(episode.value?.id ?? ""),
      ));
      await sheet!.closed;
      sheet = null;
    }
  }
  
  Future backgroundAudioService() async {
    
    // Initializing background audio service
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
    );
  }
}