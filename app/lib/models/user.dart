import 'package:app/main.dart';
import 'package:pocketbase/pocketbase.dart';

class User {
  final String id;
  final String username;
  final String email;
  final String name;
  final Uri? avatar;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.name,
    required this.avatar,
  });

  factory User.fromModel(RecordModel data) {
    return User(
      id: data.id,
      username: data.data["username"],
      email: data.data["email"],
      name: data.data["name"],
      avatar: data.data["avatar"] != "" ? client.getFileUrl(data, data.data["avatar"]) : null,
    );
  }

  factory User.empty() {
    return User(
      id: "",
      username: "",
      email: "",
      name: "Hidden",
      avatar: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "username": username,
      "email": email,
      "name": name,
      "avatar": avatar?.toString(),
    };
  }
  
}