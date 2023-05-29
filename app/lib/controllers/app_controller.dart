import 'dart:convert';
import 'dart:io';

import 'package:app/controllers/config_controller.dart' if (dart.library.html) 'package:app/controllers/config_controller_web.dart';
import 'package:app/controllers/player_controller.dart';
import 'package:app/includes/default.dart';
import 'package:app/models/episode.dart';
import 'package:app/models/user.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:webfeed/webfeed.dart';

class AppContext extends InheritedWidget {
  const AppContext({
    Key? key, 
    required this.controller,
    required this.player,
    required Widget child,
  }) : super(key: key, child: child);

  final AppController controller;
  final PlayerController player;

  static AppContext of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType()!;
  }

  @override
  bool updateShouldNotify(AppContext oldWidget) {
    return oldWidget.controller != controller;
  }
}

class AppController {

  // Appwrite server
  late final PocketBase client;

  // Local Storage
  late final Box<String> local;

  // Configs
  final ValueListenable<Map<String, dynamic>> configs = ConfigController(defaultConfigs);

  // Authenticated user
  final ValueNotifier<User?> user = ValueNotifier(null);

  // App directory
  late final Directory? directory;

  // Dio interface
  final Dio dio = Dio();

  // Library data
  final ValueNotifier<List<Episode>> episodes = ValueNotifier([]);

  // Player instance
  late final PlayerController player;

  AppController(PocketBase cli, Box<String> box, Directory? dir, PlayerController pla){
    client = cli;
    local = box;
    directory = dir;
    player = pla;
    initialize();
  }

  initialize() async {

    // Load feed
    load();

    // Listen for auth changes
    listen();

    // Check for local auth info
    if(local.get("token") != null && local.get("model") != null){
      Map<String, dynamic> data = jsonDecode(local.get("model")!) as Map<String, dynamic>;
      check(local.get("token")!, RecordModel.fromJson(data));
    }
  }

  void check(String token, RecordModel model) async {
    try {
      client.authStore.save(token, model);
    } catch(e){
      print("Not logged in");
    }
  }

  void listen(){
    client.authStore.onChange.listen((event) async {
      if(event.model != null) {
        await local.put("model", jsonEncode(event.model));
        await local.put("token", event.token);
        user.value = User.fromModel(event.model);
        user.notifyListeners();
      } else {
        await local.delete("model");
        await local.delete("token");
        user.value = null;
        user.notifyListeners();
      }
    });
  }

  void load(){
    // Load from local storage
    final episodes = local.get("episodes");

    // Parse from local storage
    if(episodes != null) {
      parse(episodes);
    }

    // Fetch from remote
    fetch();
  }

  Future fetch() async {
    // Load from remote
    final response = await dio.get(configs.value['podcast_rss_feed_string']);
    if(response.statusCode == 200) {
      parse(response.data);

      // Save last fetch time
      local.put("last-fetch", DateTime.now().toIso8601String());
    }
  }

  void parse(String body) async {
    RssFeed feed = RssFeed.parse(body);
    (feed.items ?? []).forEach((feed) {
      episodes.value.add(Episode.fromFeed(feed, directory?.path));
    });

    // Notify listeners
    episodes.notifyListeners();

    // Save feed to local storage
    await local.put("episodes", body);

    // Recover last played episode
    final last = local.get("last-played");
    
    // Play last played episode
    if(last != null && player.episode.value == null){
      final toPlay = episodes.value.firstWhere((element) => element.id == last);
      player.play(toPlay, autoPlay: false);
    }
  }

  
}