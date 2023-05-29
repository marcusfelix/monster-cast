import 'package:app/components/large_button.dart';
import 'package:app/controllers/app_controller.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:pocketbase/pocketbase.dart';

class LoginWithEmail extends StatefulWidget {
  const LoginWithEmail({
    Key? key,
  }) : super(key: key);

  @override
  State<LoginWithEmail> createState() => _LoginWithEmailState();
}

class _LoginWithEmailState extends State<LoginWithEmail> {

  String _email = "";
  String _password = "";
  bool _working = false;

  Future<RecordAuth?> login(AppController controller) async {
    setState(() => _working = true);
    try {
      // Login with email and password
      RecordAuth data = await controller.client.collection("users").authWithPassword(_email, _password);
    
      if(data.record != null){
        controller.check(data.token, data.record!);
      }

      return data;
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

  void forgot(AppController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(controller.configs.value["password_reset_string"]),
        content: Text(controller.configs.value["you_will_receive_email_string"]),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              controller.configs.value["cancel_string"].toUpperCase(),
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              controller.client.collection("users").requestPasswordReset(_email).then((value) => Navigator.of(context).pop());
            },
            child: Text(controller.configs.value["cancel_string"].toUpperCase()),
          )
        ],
      ),
    );
  }

  bool validate() => (validateEmail(_email) && _password.isNotEmpty);

  bool validateEmail(String email) => RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);

  @override
  Widget build(BuildContext context) {
    final controller = AppContext.of(context).controller;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Theme.of(context).canvasColor,
        title: Text(
          controller.configs.value["login_with_email_string"],
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
                    child: TextFormField(
                      key: const Key("email"),
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: controller.configs.value["email_string"],
                      ),
                      style: const TextStyle(fontSize: 18, color: Colors.black),
                      onChanged: (String value) => setState(() => _email = value),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                    child: TextFormField(
                      key: const Key("password"),
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: controller.configs.value["password_string"],
                      ),
                      style: const TextStyle(fontSize: 18, color: Colors.black),
                      onChanged: (String value) => setState(() => _password = value),
                    ),
                  ),
                  validateEmail(_email) ? TextButton(
                    onPressed: () => forgot(controller), 
                    child: Text(controller.configs.value["forgot_password_string"].toUpperCase())) : Container()
                ],
              ),
            ),
          ),
          LargeButton(
            label: controller.configs.value["login_string"],
            working: _working,
            viewPadding: true,
            onPressed: validate() ? () {
              login(controller).then((auth) {
                if(auth != null){
                  Navigator.of(context).pop(auth);
                }
              });
            } : null,
          ),
        ],
      ),
    );
  }

}
