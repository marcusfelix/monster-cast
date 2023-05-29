import 'package:app/components/avatar.dart';
import 'package:app/components/large_button.dart';
import 'package:app/controllers/app_controller.dart';
import 'package:app/models/thread.dart';
import 'package:app/models/user.dart';
import 'package:app/views/select_users.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:pocketbase/pocketbase.dart';

class ThreadEdit extends StatefulWidget {
  const ThreadEdit({
    super.key,
    this.thread,
    required this.user,
  });

  final Thread? thread;
  final User user;

  @override
  State<ThreadEdit> createState() => _ThreadEditState();
}

class _ThreadEditState extends State<ThreadEdit> {
  late Thread _thread;
  bool _working = false;

  @override
  void initState() {
    _thread = widget.thread ?? Thread(
      id: "",
      name: "",
      private: false,
      members: [widget.user],
      created: DateTime.now(),
      updated: DateTime.now(),
    );
    super.initState();
  }

  Future save(AppController controller) async {
    if(widget.thread != null){
      return controller.client.collection("threads").update(_thread.id, body: {
        "name": _thread.name,
        "private": _thread.private,
        "members": _thread.members.map((e) => e.id).toList()
      });
    } else {
      return controller.client.collection("threads").create(body: {
        "name": _thread.name,
        "private": _thread.private,
        "members": _thread.members.map((e) => e.id).toList()
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppContext.of(context).controller;
    
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(PhosphorIcons.bold.x),
        ),
        title: Text(controller.configs.value[widget.thread == null ? "new_thread_string" : "edit_thread_string"]),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              child: Icon(PhosphorIcons.regular.hash, color: Theme.of(context).colorScheme.onSecondaryContainer)
            ),
            title: Text(controller.configs.value["thread_icon_string"]),
            onTap: (){},
          ),
          const SizedBox(height: 8),
          ListTile(
            title: TextFormField(
              initialValue: widget.thread?.name ?? "",
              maxLength: 32,
              decoration: InputDecoration(
                labelText: controller.configs.value["thread_name_string"],
              ),
              onChanged: (value) => setState(() => _thread.name = value),
            ),
          ),
          const SizedBox(height: 8),
          SwitchListTile.adaptive(
            value: _thread.private,
            title: Text(controller.configs.value["private_string"]),
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: (value) => setState(() => _thread.private = value),
          ),
          const SizedBox(height: 8),
          _thread.private ? Column(
            children: _thread.members.map((e) => ListTile(
              leading: Avatar(user: e),
              title: Text(e.name),
              trailing: IconButton(
                onPressed: widget.user.id != e.id ? () => setState(() => _thread.members.remove(e)) : null,
                icon: Icon(PhosphorIcons.regular.minusCircle),
              ),
            )).toList(),
          ) : Container(),
          const SizedBox(height: 72),
        ],
      ),
      floatingActionButton: _thread.private ? FloatingActionButton(
        onPressed: () async {
          List<User>? selected = await showModalBottomSheet(
            context: context, 
            isScrollControlled: true,
            barrierColor: Colors.transparent,
            builder: (context) => Container(
              height: MediaQuery.of(context).size.height * 0.5,
              margin: MediaQuery.of(context).viewInsets,
              child: SelectUsers(
                selected: _thread.members,
              )
            )
          );
          
          if(selected != null){
            setState(() {
              _thread.members.addAll(selected.where((e) => !_thread.members.contains(e)));
            });
          }
        },
        child: Icon(PhosphorIcons.regular.userCirclePlus),
      ) : null,
      bottomNavigationBar: LargeButton(
        label: controller.configs.value["save_string"],
        working: _working,
        viewPadding: true,
        onPressed: () {
          setState(() => _working = true);
          save(controller).then((value) => Navigator.of(context).pop());
          setState(() => _working = false);
        },
      ),
    );
  }
}