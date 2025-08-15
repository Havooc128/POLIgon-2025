/// Author: Łukasz Piętka (FUT 2025)
class Crew {
  final int id; // non editable
  final String name;
  final String room;
  final String role;
  final String imageUrl;
  final DateTime sobrietyDay; //Editable by superAdmin
  final String description;
  final String email; //non editable
  final bool isSuperAdmin; // editable by superAdmin
  final String crewQuest;
  final String phoneNumber;
  double imageAlignmentY;
  final DateTime? lastModified;

  Crew({
    required this.id,
    required this.name,
    required this.room,
    required this.role,
    required this.imageUrl,
    required this.sobrietyDay,
    required this.description,
    required this.crewQuest,
    required this.phoneNumber,
    required this.email,
    required this.isSuperAdmin,
    required this.imageAlignmentY,
    this.lastModified,
  });
}
