import 'crew.dart';

/// Author: Łukasz Piętka (FUT 2025)
class Announcement {
  final int id;
  final String text;
  final Crew author;
  final DateTime publishDate;
  final DateTime? lastModified;

  Announcement({
    this.id = -1,
    required this.text,
    required this.author,
    required this.publishDate,
    this.lastModified,
  });
}