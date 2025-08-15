import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/team.dart';
import '../../provider/auth_provider.dart';
import '../edit/edit_team_screen.dart';
import 'max_width_container.dart';

/// Author: Łukasz Piętka (FUT 2025)
class TeamDetailScreen extends StatelessWidget {
  final Team team;

  const TeamDetailScreen({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    final isSuperAdmin = authProvider.me?.isSuperAdmin == true;

    return MaxWidthContainer(
      child: Scaffold(
        appBar: AppBar(title: Text(team.name)),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    team.imageUrl,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                    const Icon(Icons.groups, size: 100),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Kapitan: ${team.captainName}',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 12),
              Text('Punkty: ${team.points}',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 12),
              const Text('Członkowie:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              team.members != null && team.members!.isNotEmpty
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: team.members!
                    .map((member) => Padding(
                  padding:
                  const EdgeInsets.symmetric(vertical: 2.0),
                  child: Text('• $member'),
                ))
                    .toList(),
              )
                  : const Text('Brak członków w drużynie.'),
            ],
          ),
        ),
        floatingActionButton: authProvider.user != null && authProvider.me != null
            ? FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditTeamScreen(
                  team: team,
                  canEditAll: isSuperAdmin,
                ),
              ),
            );
          },
          child: const Icon(Icons.edit),
        )
            : null,
      ),
    );
  }
}
