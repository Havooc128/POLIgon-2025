/// Author: Łukasz Piętka (FUT 2025)
class Song {
  final int id;
  final String title;
  final String songText;
  final DateTime? lastModified;

  Song({required this.id, required this.title, required this.songText, this.lastModified});
}
