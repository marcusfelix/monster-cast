import 'package:app/components/avatar.dart';
import 'package:app/controllers/app_controller.dart';
import 'package:app/models/user.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class SelectUsers extends StatefulWidget {
  const SelectUsers({
    super.key,
    required this.selected,
  });

  final List<User> selected;

  @override
  State<SelectUsers> createState() => _SelectUsersState();
}

class _SelectUsersState extends State<SelectUsers> {
  final TextEditingController _search = TextEditingController();
  String? _query;
  List<User> _selected = [];

  @override
  void initState() {
    _selected = widget.selected;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppContext.of(context).controller;
    
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(_selected),
          icon: Icon(PhosphorIcons.bold.arrowLeft),
        ),
        title: Text(controller.configs.value["select_users_string"]),
      ),
      body: FutureBuilder(
        future: controller.client.collection("users").getList(filter: _query != null ? "name ~ '$_query'" : null),
        builder: (context, data) {
          final List<User> users = (data.data?.items ?? []).map((e) => User.fromModel(e)).toList();
          return ListView(
            children: users.map((user) => ListTile(
              onTap: () {
                setState(() {
                  int index = _selected.indexWhere((e) => user.id == e.id);
                  if(index > -1) {
                    _selected.removeAt(index);
                  } else {
                    _selected.add(user);
                  }
                });
              },
              leading: Avatar(user: user),
              title: Text(user.name),
              trailing: Icon(_selected.indexWhere((e) => e.id == user.id) > -1 ? PhosphorIcons.regular.radioButton : PhosphorIcons.regular.circle),
            )).toList()
          );
        }
      ),
      bottomNavigationBar: Container(
        color: Theme.of(context).colorScheme.background,
        child: Container(
          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.1),
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewPadding.bottom),
          child: TextFormField(
            controller: _search,
            decoration: InputDecoration(
              hintText: controller.configs.value["search_string"],
              hintStyle: TextStyle(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5)),
              border: InputBorder.none,
              filled: false,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
              suffixIcon: IconButton(
                onPressed: () => setState(() => _query = _search.text),
                icon: Icon(
                  PhosphorIcons.regular.magnifyingGlass,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
            ),
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          )
        ),
      ),
    );
  }
}