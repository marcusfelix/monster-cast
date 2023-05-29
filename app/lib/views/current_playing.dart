import 'dart:io';

import 'package:app/components/download_episode.dart';
import 'package:app/controllers/app_controller.dart';
import 'package:app/controllers/player_controller.dart';
import 'package:app/models/episode.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';

class CurrentPlaying extends StatelessWidget {
  const CurrentPlaying({
    Key? key
  }) : super(key: key);

  void previous(AppController controller, PlayerController player){

    // Get last played episode
    final last = controller.local.get("last-played");

    if(last == null) return;

    final index = controller.episodes.value.indexWhere((e) => e.id == last);
    if(index > 0){
      player.play(controller.episodes.value[index - 1], autoPlay: true);
    }
  }

  void next(AppController controller, PlayerController player){

    // Get last played episode
    final last = controller.local.get("last-played");

    if(last == null) return;

    final index = controller.episodes.value.indexWhere((e) => e.id == last);
    if(index > controller.episodes.value.length - 1){
      player.play(controller.episodes.value[index + 1], autoPlay: true);
    }
  }

  @override
  Widget build(BuildContext context) {

    final controller = AppContext.of(context).controller;
    final player = AppContext.of(context).player;
    
    return Material(
      color: Theme.of(context).canvasColor,
      child: ValueListenableBuilder(
        valueListenable: player.episode,
        builder: (BuildContext context, Episode? episode, _) {
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                floating: true,
                leading: null,
                automaticallyImplyLeading: false,
                title: Text(controller.configs.value["current_playing_string"]),
                expandedHeight: 400,
                backgroundColor: Theme.of(context).colorScheme.primary,
                flexibleSpace: FlexibleSpaceBar(
                  background: Padding(
                    padding: EdgeInsets.only(top: (58 + 42) + MediaQuery.of(context).viewPadding.top),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Column(
                            children: [
                              Expanded(
                                child: Container(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  color: Theme.of(context).canvasColor,
                                ),
                              )
                            ],
                          ),
                        ),
                        Positioned(
                          child: Center(
                            child: AspectRatio(
                              aspectRatio: 1 / 1,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.secondaryContainer,
                                  image: episode?.cover != null ? DecorationImage(
                                    image: NetworkImage(episode!.cover!),
                                    fit: BoxFit.cover,
                                  ) : null
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        episode != null ? DateFormat.yMMMd().format(episode.date) : "",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5)),
                      ),
                      Container(height: 16),
                      Text(
                        episode?.title ?? "",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20, 
                          fontWeight: FontWeight.w600
                        ),
                      ),
                      Container(height: 42),
                      StreamBuilder<Duration?>(
                        stream: player.player.positionStream,
                        builder: (BuildContext context, AsyncSnapshot<Duration?> playback) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(2),
                                  child: Container(
                                    color: episode != null ? Theme.of(context).colorScheme.secondary.withOpacity(0.3) : Theme.of(context).colorScheme.onBackground.withOpacity(0.1),
                                    child: LinearProgressIndicator(
                                      value: episode != null ? (((playback.data ?? const Duration(milliseconds: 1)).inMilliseconds) * 1.0) / (episode.duration.inMilliseconds) : 0, 
                                      minHeight: 4, 
                                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary), 
                                      backgroundColor: Colors.transparent
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      episode != null ? playback.data != null ? "${playback.data!.inMinutes.toString().padLeft(2, "0")}:${((playback.data!.inMinutes * 60) - playback.data!.inSeconds).abs().toString().padLeft(2, "0")}" : "- -" : "",
                                      style: const TextStyle(
                                        fontSize: 12,
                                      )
                                    ),
                                    Text(episode != null ? "${(player.player.duration ?? const Duration(seconds: 1)).inMinutes.toString().padLeft(2, "0")}:${(((player.player.duration ?? const Duration(seconds: 1)).inMinutes * 60) - (player.player.duration ?? const Duration(seconds: 1)).inSeconds).abs().toString().padLeft(2, "0")}" : "",
                                      style: const TextStyle(
                                        fontSize: 12,
                                      )
                                    )
                                  ],
                                )
                              ],
                            ),
                          );
                        }
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 32, bottom: 68),
                        child: Opacity(
                          opacity: episode != null ? 1 : 0.3,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              EpisodeDownload(
                                episode: kIsWeb ? null : episode,
                              ),
                              IconButton(
                                onPressed: () => previous(controller, player), 
                                icon: Icon(
                                  PhosphorIcons.regular.skipBack, 
                                  color: Theme.of(context).colorScheme.secondary
                                )
                              ),
                              StreamBuilder<bool>(
                                initialData: false,
                                stream: player.player.playingStream,
                                builder: (BuildContext context, AsyncSnapshot<bool> playing) {
                                  return Material(
                                    shape: const CircleBorder(),
                                    color: Theme.of(context).colorScheme.secondary,
                                    child: InkWell(
                                      customBorder: const CircleBorder(),
                                      onTap: () {
                                        if (playing.data ?? false) {
                                          player.player.pause();
                                        } else {
                                          player.player.play();
                                        }
                                      },
                                      onLongPress: () {
                                        player.player.stop();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(16), 
                                        child: Icon((playing.data ?? false) ? PhosphorIcons.fill.pause : PhosphorIcons.fill.play, 
                                        color: Theme.of(context).colorScheme.background
                                      )),
                                    ),
                                  );
                                }
                              ),
                              IconButton(
                                onPressed: () => next(controller, player), 
                                icon: Icon(
                                  PhosphorIcons.regular.skipForward, 
                                  color: Theme.of(context).colorScheme.secondary
                                )
                              ),
                              IconButton(
                                onPressed: () => episode != null ? launchUrlString(episode.url) : null, 
                                icon: Icon(
                                  PhosphorIcons.regular.globeSimple, 
                                  color: Theme.of(context).colorScheme.secondary
                                )
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          );
        }
      ),
    );
  }
}
