import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class Attachment extends StatelessWidget {
  const Attachment({
    required Key key, 
    required this.uri, 
  }) : super(key: key);

  final Uri uri;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      constraints: const BoxConstraints(maxWidth: 414),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Material(
          color: Theme.of(context).colorScheme.tertiaryContainer,
          child: InkWell(
            child: Column(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    uri.toString(),
                    fit: BoxFit.cover,
                  )
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Wrap(
                    runSpacing: 4,
                    children: [
                      Text(
                        uri.pathSegments.last, 
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis, 
                        style: TextStyle(
                          fontSize: 12, 
                          fontWeight: FontWeight.bold, 
                          color: Theme.of(context).colorScheme.onTertiaryContainer
                        )
                      ),
                    ],
                  ),
                )
              ],
            ),
            onTap: () {
              launchUrlString(uri.toString());
            },
          ),
        ),
      ),
    );
  }
}
