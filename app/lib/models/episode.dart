import 'dart:io';
import 'package:webfeed/webfeed.dart';

class Episode {
  final String id;
  final String title;
  final String description;
  final String url;
  final String? cover;
  final Duration duration;
  final DateTime date;
  final Uri? audio;
  final File? local;

  Episode({
    required this.id,
    required this.title,
    required this.description,
    required this.url,
    this.cover,
    required this.duration,
    required this.date,
    this.audio,
    required this.local,
  });

  factory Episode.fromFeed(RssItem feed, String? path) {
    return Episode(
      id: feed.guid ?? '',
      title: feed.title ?? '',
      description: feed.description ?? '',
      url: feed.link ?? '',
      cover: feed.itunes?.image?.href,
      duration: feed.itunes?.duration ?? Duration.zero,
      date: feed.pubDate ?? DateTime.now(),
      audio: feed.enclosure?.url != null ? Uri.parse(feed.enclosure!.url!) : null,
      local: path != null ? File("$path/${feed.guid}.mp3") : null
    );
  }
}