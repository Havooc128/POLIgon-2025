import 'package:flutter/material.dart';
import 'package:poligon/screen/widget/crew_details_screen.dart';
import 'package:poligon/screen/widget/grid_list.dart';
import 'package:poligon/screen/widget/max_width_container.dart';
import 'package:provider/provider.dart';
import '../model/crew.dart';
import '../provider/base_provider.dart';

/// Author: Łukasz Piętka (FUT 2025)
class CrewScreen extends StatelessWidget {

  const CrewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<BaseNotifier<Crew>>();

    final crewList = notifier.items;

    List<List<Crew>> rows = [];
    for (var i = 0; i < crewList.length; i += 2) {
      rows.add(
        crewList.sublist(i, i + 2 > crewList.length ? crewList.length : i + 2),
      );
    }

    return MaxWidthContainer(
      child: Scaffold(
        appBar: AppBar(title: const Text("Kadra")),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GridList<Crew>(
            items: crewList,
            builder:
                (crew) => Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: GestureDetector(
                    onTap:
                        () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CrewDetailScreen(crew: crew),
                          ),
                        ),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: Colors.grey[900],
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                crew.imageUrl,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) =>
                                        const Icon(Icons.person, size: 100),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              crew.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              crew.role,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Pokój: ${crew.room}',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
          ),
        ),
      ),
    );
  }
}
