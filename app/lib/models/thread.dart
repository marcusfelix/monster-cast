
import 'package:app/models/user.dart';
import 'package:pocketbase/pocketbase.dart';

class Thread {
  final String id;
  String name;
  bool private;
  List<User> members;
  String? lastMessage;
  String? image;
  DateTime created;
  DateTime updated;

  Thread({
    required this.id,
    required this.name,
    required this.private,
    required this.members,
    this.lastMessage,
    this.image,
    required this.created,
    required this.updated,
  });

  factory Thread.fromModel(RecordModel data) {
    return Thread(
      id: data.id,
      name: data.data['name'],
      private: data.data['private'],
      members: (data.expand['members'] ?? []).map<User>((e) => User.fromModel(e)).toList(),
      lastMessage: data.data['last_message'],
      image: data.data['cover'],
      created: DateTime.parse(data.created),
      updated: DateTime.parse(data.updated),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "name": name,
      "private": private,
      "members": members.map((e) => e.id).toList(),
      "last_message": lastMessage,
      "cover": image
    };
  }
}