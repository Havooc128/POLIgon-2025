import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:poligon/screen/widget/team_detail_screen.dart';
import 'package:poligon/service/team_service.dart';
import 'package:provider/provider.dart';
import '../model/team.dart';
import '../provider/auth_provider.dart';
import '../provider/base_provider.dart';

/// Author: Łukasz Piętka (FUT 2025)
class TeamScreen extends StatelessWidget {
  final VoidCallback onDrawerOpen;

  const TeamScreen({super.key, required this.onDrawerOpen});

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<BaseNotifier<Team>>();
    final auth = context.watch<AuthProvider>();

    final teams = notifier.items;
    final sortedTeams = [...teams]..sort((a, b) => b.points.compareTo(a.points));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Drużyny"),
        actions: [
          if (auth.me != null && auth.me!.isSuperAdmin)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddTeamDialog(context, notifier),
            ),
        ],
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: onDrawerOpen,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            const Text("Wyniki drużyn",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceBetween,
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          final title = idx >= 0 && idx < sortedTeams.length ? sortedTeams[idx].name : '';

                          return Transform.rotate(
                            angle: -0.5, // w radianach
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                title,
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  barGroups: List.generate(sortedTeams.length, (index) {
                    final team = sortedTeams[index];
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: team.points.toDouble(),
                          color: Colors.teal,
                          width: 20,
                          borderRadius: BorderRadius.circular(4),
                        )
                      ],
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                itemCount: sortedTeams.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  final team = sortedTeams[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TeamDetailScreen(team: team),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 4,
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: ClipRRect(
                          borderRadius:
                          const BorderRadius.all(Radius.circular(16)),
                          child: Image.asset(
                            team.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                            const Icon(Icons.groups, size: 60),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTeamDialog(BuildContext context, BaseNotifier<Team> notifier) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final imageUrlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Dodaj drużynę'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nazwa drużyny'),
                    validator: (value) =>
                    value == null || value.isEmpty ? 'Podaj nazwę' : null,
                  ),
                  TextFormField(
                    controller: imageUrlController,
                    decoration:
                    const InputDecoration(labelText: 'URL zdjęcia'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Anuluj'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  final newTeam = Team(
                    name: nameController.text,
                    imageUrl: imageUrlController.text.isNotEmpty
                        ? imageUrlController.text
                        : 'https://via.placeholder.com/150',
                    points: 0,
                  );

                  TeamService().saveOrUpdate(newTeam);

                  Navigator.pop(context);
                }
              },
              child: const Text('Dodaj'),
            ),
          ],
        );
      },
    );
  }
}
