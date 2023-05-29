import 'package:app/controllers/app_controller.dart';
import 'package:app/models/episode.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class EpisodeTile extends StatelessWidget {
  EpisodeTile({
    Key? key,
    required this.episode,
  }) : super(key: key);

  Episode episode;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        child: Container(
          height: 132,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background,
                  image: episode.cover != null ? DecorationImage(
                    image: NetworkImage(episode.cover!),
                    fit: BoxFit.cover,
                  ) : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat.yMMMd().format(episode.date),
                            style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onBackground.withOpacity(0.3)),
                          ),
                          episode.local != null && episode.local!.existsSync() ? Icon(PhosphorIcons.regular.arrowLineDown, size: 14) : Container()
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          episode.title,
                          maxLines: 3,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        onTap: () async {
          AppContext.of(context).player.play(episode).then((value) => AppContext.of(context).controller.local.put("last-played", episode.id));
        },
      ),
    );
  }
}
