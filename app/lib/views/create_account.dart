import 'package:app/components/large_button.dart';
import 'package:app/controllers/app_controller.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:pocketbase/pocketbase.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({
    Key? key
  }) : super(key: key);

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final RegExp regex = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  String _name = "";
  String _username = "";
  String _email = "";
  String _password = "";
  bool _working = false;

  Future<RecordAuth?> create(AppController controller) async {
    setState(() => _working = true);
    try {
      await controller.client.collection("users").create(
        body: {
          "name": _name,
          "username": _username,
          "email": _email,
          "password": _password,
          "passwordConfirm": _password,
        }
      );
      RecordAuth auth = await controller.client.collection("users").authWithPassword(_email, _password);
      if(auth.record != null){
        controller.check(auth.token, auth.record!);
      }

      return auth;
    } on ClientException catch(e){
      // Show snackbar
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          e.response["message"],
          style: TextStyle(
            fontSize: 18,
            color: Theme.of(context).colorScheme.onErrorContainer
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.errorContainer
      ));
    }
    setState(() => _working = false);
    return null;
  }

  bool validate() => _name.isNotEmpty && regex.hasMatch(_email) && _password.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final services = AppContext.of(context).controller;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Theme.of(context).canvasColor,
        title: Text(
          services.configs.value["create_account_string"],
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(PhosphorIcons.bold.arrowLeft),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: services.configs.value["name_string"],
                    ),
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                    onChanged: (String value) => setState(() => _name = value),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: services.configs.value["username_string"],
                    ),
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                    onChanged: (String value) => setState(() => _username = value),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: services.configs.value["email_string"],
                    ),
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                    onChanged: (String value) => setState(() => _email = value),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: services.configs.value["password_string"],
                    ),
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                    onChanged: (String value) => setState(() => _password = value),
                  ),
                ),
              ],
            ),
          ),
          LargeButton(
            label: services.configs.value["create_account_string"],
            working: _working,
            viewPadding: true,
            onPressed: validate() ? () => create(services).then((value) => Navigator.of(context).pop(value)) : null,
          )
        ],
      ),
    );
  }

}
