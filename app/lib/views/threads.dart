import 'dart:async';

import 'package:app/controllers/app_controller.dart';
import 'package:app/models/thread.dart';
import 'package:app/views/threads_edit.dart';
import 'package:app/views/thread_view.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:pocketbase/pocketbase.dart';

class Threads extends StatefulWidget {
  Threads({
    Key? key,
    required this.service
  }) : super(key: key);

  final RecordService service;

  @override
  State<Threads> createState() => _ThreadsState();
}

class _ThreadsState extends State<Threads>  with AutomaticKeepAliveClientMixin<Threads> {
  final ValueNotifier<String> search = ValueNotifier<String>("");
  late StreamController<List<Thread>> stream;

  @override
  void initState() {
    Future<void> Function()? unsubscribe;
    final models = <Thread>[];
    void notify() {
      models.sort((a, b) => b.updated.compareTo(a.updated));
      stream.add([...models]);
    }
    stream = StreamController<List<Thread>>(
      onListen: () {
        widget.service.getFullList().then((items) {
          models.clear();
          models.addAll(items.map((e) => Thread.fromModel(e)));
          notify();
        });
        widget.service.subscribe('*', (e) {
          switch (e.action) {
            case 'create':
              final model = Thread.fromModel(e.record!);
              models.add(model);
              notify();
              break;
            case 'update':
              final model = Thread.fromModel(e.record!);
              final id = model.id;
              final i = models.indexWhere((model) => model.id == id);
              if (i != -1) {
                models[i] = model;
              }
              notify();
              break;
            case 'delete':
              final id = e.record!.id;
              models.removeWhere((model) => model.id == id);
              notify();
              break;
          }
        }).then((u) => unsubscribe = u);
      },
      onCancel: () {
        unsubscribe?.call();
        unsubscribe = null;
      },
    );

    super.initState();
  }

  @override
  void dispose() {
    widget.service.unsubscribe("*");
    stream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppContext.of(context).controller;

    return Scaffold(
      appBar: AppBar(
        leading: null,
        automaticallyImplyLeading: false,
        title: Text(controller.configs.value["threads_string"]),
      ),
      body: ValueListenableBuilder(
        valueListenable: search,
        builder: (context, search, _) {
          return StreamBuilder(
            stream: stream.stream,
            builder: (context, data) {
              final filtered = (data.data ?? []).where((thread) => thread.name.toLowerCase().contains(search.toLowerCase())).toList();
              
              return ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                      child: Icon(PhosphorIcons.regular.hash, color: Theme.of(context).colorScheme.onSecondaryContainer)
                    ),
                    title: Text(
                      filtered.elementAt(index).name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600
                      ),
                    ),
                    subtitle: Text(
                      filtered.elementAt(index).lastMessage ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: (){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => ThreadView(
                        thread: filtered.elementAt(index),
                        service: controller.client.collection("messages"),
                      )));
                    },
                  );
                },
              );
            }
          );
        }
      ),
      floatingActionButton: controller.user.value != null ? FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context, 
            isScrollControlled: true,
            builder: (context) => Container(
              height: MediaQuery.of(context).size.height * 0.5,
              margin: MediaQuery.of(context).viewInsets,
              child: ThreadEdit(
                user: controller.user.value!,
              )
            )
          );
        },
        child: Icon(
          PhosphorIcons.regular.plus,
        ),
      ) : null,
    );
  }
  
  @override
  bool get wantKeepAlive => true;
}