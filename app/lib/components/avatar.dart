import 'package:app/models/user.dart';
import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    required this.user
  });

  final User user;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: ClipOval(
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            image: user.avatar != null ? DecorationImage(
              image: NetworkImage(user.avatar.toString()),
              fit: BoxFit.cover,
            ) : null,
          ),
          alignment: Alignment.center,
          child: user.avatar != null ? null : Text(
            user.name[0].toUpperCase(),
            style: TextStyle(
              fontSize: 14, 
              color: Theme.of(context).colorScheme.secondary, 
              fontWeight: FontWeight.bold
            ),
          )
        ),
      ),
    );
  }

}