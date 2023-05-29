import 'dart:io';

import 'package:app/app.dart';
import 'package:app/controllers/app_controller.dart';
import 'package:app/controllers/player_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pocketbase/pocketbase.dart';

// Env variables
const String env = String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');
const String url = String.fromEnvironment('SERVER_URL', defaultValue: 'http://localhost:8090');

// Pocketbase client
final PocketBase client = PocketBase(url);

void main() async {

  // Initializing controller
  WidgetsFlutterBinding.ensureInitialized();

  // Initializing direcotry
  Directory? directory = !kIsWeb ? Directory("${(Platform.isAndroid) ? (await getExternalStorageDirectory())?.path : (await getApplicationDocumentsDirectory()).path}/deploid") : null;

  // Local Storage
  await Hive.initFlutter();
  Box<String> box = await Hive.openBox<String>('localstorage');

  // Initializing player
  final player = PlayerController(directory);

  // Initializing controller
  final controller = AppController(client, box, directory, player);

  runApp(AppContext(
    controller: controller,
    player: player,
    child: const App()
  ));
}