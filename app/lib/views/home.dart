
import 'package:app/controllers/app_controller.dart';
import 'package:app/models/user.dart';
import 'package:app/views/threads.dart';
import 'package:app/views/current_playing.dart';
import 'package:app/views/library.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class Home extends StatefulWidget {
  const Home({
    super.key,
    this.user,
  });

  final User? user;


  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  late TabController controller;

  @override
  void initState() {
    controller = TabController(vsync: this, length: 3);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final player = AppContext.of(context).player;

    return Scaffold(
      key: player.scaffold,
      body: TabBarView(
        controller: controller, 
        children: [
          const Library(
            key: ValueKey("library"),
          ),
          const CurrentPlaying(
            key: ValueKey("current-playing"),
          ),
          Threads(
            key: const ValueKey("threads"),
            service: AppContext.of(context).controller.client.collection("threads")
          ),
        ]
      ),
      bottomNavigationBar: Container(
        color: Theme.of(context).colorScheme.onBackground,
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewPadding.bottom), 
        child: TabBar(
          controller: controller,
          indicator: const BoxDecoration(
            color: Colors.transparent
          ), 
          labelColor: Theme.of(context).colorScheme.background, 
          unselectedLabelColor: Theme.of(context).colorScheme.background.withOpacity(0.3), 
          tabs: [
            Tab(
              icon: Icon(PhosphorIcons.regular.list),
            ),
            Tab(
              icon: Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 18),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer, 
                  borderRadius: const BorderRadius.all(Radius.circular(20)
                )),
                child: Icon(
                  PhosphorIcons.fill.play,
                  color: Theme.of(context).colorScheme.onBackground,
                  size: 20,
                ),
              )
            ),
            Tab(
              icon: Icon(PhosphorIcons.regular.chatCentered),
            )
          ]
        ),
      ),
    );
  }
}