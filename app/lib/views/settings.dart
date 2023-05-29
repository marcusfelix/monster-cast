import 'dart:io';

import 'package:app/controllers/app_controller.dart';
import 'package:app/includes/uploads.dart';
import 'package:app/main.dart';
import 'package:app/models/user.dart';
import 'package:app/views/login_with_email.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:pocketbase/pocketbase.dart';

class Settings extends StatefulWidget {
  const Settings({
    Key? key,
    required this.user,
  }) : super(key: key);

  final User user;

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late String _name;
  late String _email;
  late Uri? _photo;
  File? _upload;
  bool _working = false;

  @override
  void initState() {
    _email = widget.user.email;
    _name = widget.user.name;
    _photo = widget.user.avatar;
    super.initState();
  }

  Future<RecordModel> save(AppController controller) async {
     print(_upload);
    // Upload the image
    return controller.client.collection("users").update(
      widget.user.id,
      body: {
        "name": _name,
        "photo": _photo
      },
      files: _upload != null ? [
        await MultipartFile.fromPath(
          'avatar',
          _upload!.path,
          filename: "${widget.user.id}.jpg",
        )
      ] : []
    );
  }

  Future upload(AppController services) async {
    setState(() => _working = true);

    // Pick a image file
    File? image = await filePicker();

    if(image == null) return;

    // Resize
    File thumb = await resizeImage(image, const Size(120, 120));

    setState(() {
      _upload = thumb;
      _working = false;
    });
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
        title: Text(
          controller.configs.value["settings_string"],
        ),
        actions: [
          IconButton(
            onPressed: _working ? null : () {
              setState(() => _working = true);
              save(controller).then((value) => Navigator.of(context).pop());
              setState(() => _working = false);
            }, 
            icon: _working ? SizedBox(
              width: 24, 
              height: 24, 
              child: CircularProgressIndicator(
                strokeWidth: 2, 
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.onPrimary)
              )
            ) : Icon(
              PhosphorIcons.regular.checkCircle, 
              size: 28
            )
          )
        ],
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: ListView(padding: const EdgeInsets.symmetric(vertical: 16), children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              backgroundImage: _photo != null ? NetworkImage(_photo.toString()) : null,
            ),
            title: Text(controller.configs.value["upload_profile_image_string"]),
            onTap: () => upload(controller),
            trailing: Icon(
              PhosphorIcons.regular.uploadSimple,
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.3)
            ),
          )
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextFormField(
            initialValue: _name,
            keyboardType: TextInputType.name,
            decoration: InputDecoration(
              labelText: controller.configs.value["name_string"]
            ),
            style: const TextStyle(fontSize: 18, color: Colors.black),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextFormField(
            initialValue: _email,
            keyboardType: TextInputType.emailAddress,
            enabled: false,
            decoration: InputDecoration(
              labelText: controller.configs.value["email_string"]
            ),
            style: const TextStyle(fontSize: 18, color: Colors.black),
          ),
        ),
        const SizedBox(height: 42),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: TextButton(
            onPressed: () => changePassword(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.all(16),
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              textStyle: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            child: Text(
              controller.configs.value["change_password_string"].toUpperCase(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: TextButton(
            onPressed: () => askToLogout(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.all(16),
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              textStyle: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            child: Text(
              controller.configs.value["logout_string"].toUpperCase(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: TextButton(
            onPressed: () => delete(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.all(16),
              backgroundColor: Colors.transparent,
              textStyle: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            child: Text(
              controller.configs.value["delete_account_string"].toUpperCase(),
            ),
          ),
        ),
        !kIsWeb ? Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: TextButton(
            onPressed: () => clear(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.all(16),
              backgroundColor: Colors.transparent,
              textStyle: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            child: Text(
              controller.configs.value["clear_local_data_string"].toUpperCase(),
            ),
          ),
        ) : Container(),
      ]),
    );
  }

  void changePassword() {
    final services = AppContext.of(context).controller;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(services.configs.value["password_reset_string"]),
        content: Text(services.configs.value["you_will_receive_email_string"]),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              services.configs.value["cancel_string"].toUpperCase(),
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              services.client.collection("users").requestPasswordReset(_email);
              Navigator.of(context).pop();
            },
            child: Text(services.configs.value["continue_string"].toUpperCase()),
          )
        ],
      ),
    );
  }

  void askToLogout() async {
    final services = AppContext.of(context).controller;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(services.configs.value["logout_string"]),
        content: Text(services.configs.value["are_you_shure_question_string"]),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              services.configs.value["cancel_string"].toUpperCase(),
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              logout();
            },
            child: Text(services.configs.value["logout_string"].toUpperCase()),
          )
        ],
      ),
    );
  }

  void logout(){
    final services = AppContext.of(context).controller;
    services.client.authStore.clear();
    Navigator.of(context).pop();
  }

  void delete() {
    final services = AppContext.of(context).controller;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(services.configs.value["delete_account_question_string"]),
        content: Text(services.configs.value["this_action_will_delete_string"]),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              services.configs.value["cancel_string"].toUpperCase(),
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
              // Reauthenticate
              Navigator.of(context).pop();
              RecordAuth? data = await showModalBottomSheet<RecordAuth?>(
                context: context, 
                isScrollControlled: true,
                builder: (context) => Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  margin: MediaQuery.of(context).viewInsets,
                  child: const LoginWithEmail()
                )
              );

              if(data != null){
                await services.client.collection("users").delete(data.record?.id ?? "");
                // Logout
                logout();
              }
            },
            child: Text(
              services.configs.value["delete_string"].toUpperCase(),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          )
        ],
      ),
    );
  }

  void clear() async {
    final services = AppContext.of(context).controller;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(services.configs.value["clear_local_data_question_string"]),
        content: Text(services.configs.value["this_action_will_clear_string"]),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              services.configs.value["cancel_string"].toUpperCase(),
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
              // Delete all local files
              List<FileSystemEntity> files = services.directory?.listSync() ?? [];
              for (FileSystemEntity file in files) {
                try {
                  file.deleteSync();
                } catch(e){
                  print(e);
                }
              }
              Navigator.of(context).pop();
            },
            child: Text(
              services.configs.value["clear_string"].toUpperCase(),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          )
        ],
      ),
    );
    
  }
}
