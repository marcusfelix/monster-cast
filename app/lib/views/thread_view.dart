import 'dart:async';

import 'package:collection/collection.dart';
import 'package:app/components/composer.dart';
import 'package:app/components/message_tile.dart';
import 'package:app/controllers/app_controller.dart';
import 'package:app/models/message.dart';
import 'package:app/models/thread.dart';
import 'package:app/views/threads_edit.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:pocketbase/pocketbase.dart';

class ThreadView extends StatefulWidget {
  ThreadView({
    super.key,
    required this.thread,
    required this.service,
  });

  final Thread thread;
  final RecordService service;

  @override
  State<ThreadView> createState() => _ThreadViewState();
}

class _ThreadViewState extends State<ThreadView> {
  late StreamController<List<Message>> stream;

  @override
  void initState() {
    Future<void> Function()? unsubscribe;
    final models = <Message>[];
    void notify() {
      models.sort((a, b) => b.created.compareTo(a.created));
      stream.add([...models]);
    }
    stream = StreamController<List<Message>>(
      onListen: () {
        widget.service.getFullList(
          filter: "thread.id = '${widget.thread.id}'",
          expand: "user",
        ).then((items) {
          models.clear();
          models.addAll(items.map((e) => Message.fromModel(e)));
          notify();
        });
        widget.service.subscribe('*', (e) async {

          // ignore events from other threads
          if(e.record == null){
            return;
          }

          if(e.record != null && e.record!.data["thread"] != widget.thread.id){
            return;
          }

          if(e.action == "create" || e.action == "update"){
            // try to expand the user
            if(e.record!.expand['user'] == null){
              final Map<String, dynamic>? data = models.firstWhereOrNull((model) => model.user.id == e.record!.data["user"])?.user.toJson();
              if(data != null){
                e.record!.expand['user'] = [RecordModel.fromJson(data)];
              } else {
                final expanded = await widget.service.getOne(e.record!.id, expand: 'user');
                if(expanded.expand['user'] != null){
                  e.record!.expand['user'] = [RecordModel.fromJson(expanded.expand['user']?[0].data ?? {})];
                }
              }
            }
          }

          switch (e.action) {
            case 'create':
              final model = Message.fromModel(e.record!);
              models.add(model);
              notify();
              break;

            case 'update':
              final model = Message.fromModel(e.record!);
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
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(PhosphorIcons.bold.arrowLeft),
        ),
        title: Text(widget.thread.name),
        actions: [
          IconButton(
            onPressed: () async {
              controller.client.collection("threads").getOne(widget.thread.id, expand: "members").then((data) => showModalBottomSheet(
                context: context, 
                isScrollControlled: true,
                builder: (context) => Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  margin: MediaQuery.of(context).viewInsets,
                  child: ThreadEdit(
                    thread: Thread.fromModel(data),
                    user: controller.user.value!,
                  )
                )
              ));
            },
            icon: Icon(PhosphorIcons.regular.pencilSimple),
          ),
        ],
      ),
      body: StreamBuilder<List<Message>>(
        stream: stream.stream,
        builder: (context, messages) {

          return ListView(
            reverse: true,
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: (messages.data ?? []).map((message) => MessageTile(
              key: Key(message.id), 
              message: message
            )).toList()
          );
        }
      ),
      bottomNavigationBar: controller.user.value != null ? Composer(
        thread: widget.thread
      ) : null,
    );
  }
}