import 'package:app/components/episode_tile.dart';
import 'package:app/controllers/app_controller.dart';
import 'package:app/models/episode.dart';
import 'package:app/views/auth.dart';
import 'package:app/views/settings.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class Library extends StatefulWidget {
  const Library({Key? key}) : super(key: key);

  @override
  State<Library> createState() => _LibraryState();
}

class _LibraryState extends State<Library> with AutomaticKeepAliveClientMixin<Library> {
  String _search = "";  

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final controller = AppContext.of(context).controller;
    return Scaffold(
      appBar: AppBar(
        leading: null,
        automaticallyImplyLeading: false,
        title: Text(
          controller.configs.value["app_name_string"],
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        iconTheme: Theme.of(context).appBarTheme.iconTheme,
        centerTitle: Theme.of(context).appBarTheme.centerTitle,
        actions: [
          ValueListenableBuilder(
            valueListenable: controller.user,
            builder: (context, user, _) {
              return IconButton(
                onPressed: () {
                  if (user != null) {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => Settings(
                      user: user,
                    )));
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => Auth(
                          withNavigator: true,
                        ),
                      ),
                    );
                  }
                },
                icon: Icon(PhosphorIcons.regular.userCircle, size: 28),
              );
            }
          )
        ],
        backgroundColor: Theme.of(context).colorScheme.primary,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            color: Theme.of(context).colorScheme.background,
            child: Container(
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.1),
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: controller.configs.value["search_string"],
                  hintStyle: TextStyle(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5)),
                  border: InputBorder.none,
                  filled: false,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                  suffixIcon: IconButton(
                    onPressed: null,
                    icon: Icon(
                      PhosphorIcons.regular.magnifyingGlass,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                ),
                onChanged: (value) => setState(() => _search = value),
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              )
            ),
          ),
        )
      ),
      body: ValueListenableBuilder<List<Episode>>(
      valueListenable: controller.episodes,
      builder: (context, List<Episode> episodes, _) {
        final filtered = episodes.where((episode) => _search != "" ? episode.title.toLowerCase().contains(_search.toLowerCase()) : true).toList();

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: filtered.length,
          itemBuilder: (BuildContext context, int index) {
            return EpisodeTile(
              key: ValueKey(filtered.elementAt(index).id),
              episode: filtered.elementAt(index)
            );
          }
        );
      })
    );
  }
  
  @override
  bool get wantKeepAlive => true;
}
