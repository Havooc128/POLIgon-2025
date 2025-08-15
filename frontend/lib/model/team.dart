/// Author: Łukasz Piętka (FUT 2025)
class Team {
  final int id;
  final String name;
  final String captainName;
  final List<String>? members;
  final String imageUrl;
  final int points;
  final DateTime? lastModified;

  Team({
    this.id = -1,
    required this.name,
    this.captainName = "Brak",
    this.members,
    required this.imageUrl,
    this.points = 0,
    this.lastModified
  });
}
