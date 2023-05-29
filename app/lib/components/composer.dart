import 'dart:io';

import 'package:app/controllers/app_controller.dart';
import 'package:app/includes/uploads.dart';
import 'package:app/models/thread.dart';
import 'package:app/models/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class Composer extends StatefulWidget {
  const Composer({
    super.key,
    required this.thread
  });

  final Thread thread;

  @override
  State<Composer> createState() => _ComposerState();
}

class _ComposerState extends State<Composer> {
  final TextEditingController body = TextEditingController();
  List<File> attachments = [];
  bool _working = false;

  @override
  void initState() {
    super.initState();
  }

  void send(AppController controller) async {

    // Setting state to working
    setState(() => _working = true);

    User user = controller.user.value!;

    await controller.client.collection("messages").create(
      body: {
        "body": body.text,
        "user": user.id,
        "metadata": [],
        "thread": widget.thread.id,
      },
      files: await Future.wait(attachments.map((e) => MultipartFile.fromPath(
        'attachments',
        e.path,
        filename: e.path.split("/").last,
      )).toList())
    );

    await controller.client.collection("threads").update(
      widget.thread.id,
      body: {
        "last_message": body.text,
      }
    );

    // Clearing text field
    body.clear();
    setState(() {
      attachments = [];
      _working = false;
    });
  }

  Future upload(AppController services) async {
    setState(() => _working = true);

    // Pick a image file
    File? image = await filePicker();

    if(image == null) return;

    // Resize
    File resized = await resizeImage(image, const Size(1024, 1024));

    setState(() {
      attachments.add(resized);
      _working = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppContext.of(context).controller;
    
    return Container(
      color: Theme.of(context).colorScheme.onBackground,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? MediaQuery.of(context).viewInsets.bottom : MediaQuery.of(context).viewPadding.bottom),
      child: TextFormField(
        controller: body,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          hintText: controller.configs.value["your_next_message_string"],
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.background.withOpacity(0.3)
          ),
          border: InputBorder.none,
          prefixIcon: IconButton(
            onPressed: () => attachments.length < 4 ? upload(controller) : null,
            icon: attachments.isNotEmpty ? Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.background,
                  width: 1.5
                ),
                shape: BoxShape.circle,
              ),
              child: Text(
                "${attachments.length}",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.background,
                  fontSize: 12,
                  fontWeight: FontWeight.bold
                ),
              ),
            ) : Icon(
              PhosphorIcons.regular.imageSquare,
              color: Theme.of(context).colorScheme.background,
              size: 24,
            ),
          ),
          suffixIcon: IconButton(
            onPressed: _working ? null : () => send(controller),
            icon: _working ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.background),
              ),
            ) : Icon(
              PhosphorIcons.regular.checkCircle,
              color: Theme.of(context).colorScheme.background,
              size: 24,
            ),
          )
        ),
        style: TextStyle(
          fontSize: 16, 
          color: Theme.of(context).colorScheme.background
        ),
      ),
    );
  }
}