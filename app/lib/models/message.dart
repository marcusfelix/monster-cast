
import 'package:app/main.dart';
import 'package:app/models/user.dart';
import 'package:pocketbase/pocketbase.dart';

class Message {
  final String id;
  String body;
  User user;
  List<Uri> attachments = [];
  List<Map<String, dynamic>> metadata;
  DateTime created;

  Message({
    required this.id,
    required this.body,
    required this.user,
    required this.attachments,
    required this.metadata,
    required this.created,
  });

  factory Message.fromModel(RecordModel data) {
    return Message(
      id: data.id,
      body: data.data['body'],
      user: data.expand['user'] != null ? User.fromModel(data.expand['user']![0]) : User.empty(),
      attachments: List<String>.from(data.data['attachments'] ?? []).map<Uri>((e) => client.getFileUrl(data, e, thumb: "200x200")).toList(),
      metadata: List<Map<String, dynamic>>.from(data.data['metadata'] ?? []),
      created: DateTime.parse(data.created),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "body": body,
      "user": user.toJson(),
      "attachments": attachments,
      "metadata": metadata,
      "created": created.millisecondsSinceEpoch,
    };
  }
}
