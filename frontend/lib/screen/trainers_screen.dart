import 'package:flutter/material.dart';
import 'package:poligon/model/trainer.dart';
import 'package:poligon/screen/widget/grid_list.dart';
import 'package:poligon/screen/edit/trainer_edit_screen.dart';
import 'package:poligon/screen/widget/max_width_container.dart';
import 'package:poligon/screen/widget/trainer_detail_screen.dart';
import 'package:provider/provider.dart';

import '../provider/base_provider.dart';
import '../provider/auth_provider.dart';

/// Author: Łukasz Piętka (FUT 2025)
class TrainersScreen extends StatelessWidget {
  const TrainersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<BaseNotifier<Trainer>>();
    final trainers = notifier.items;

    final auth = context.watch<AuthProvider>();
    final canAddTrainer =
        auth.user != null && auth.me != null && auth.me!.isSuperAdmin;

    return MaxWidthContainer(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Szkoleniowcy"),
          actions: [
            if (canAddTrainer)
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TrainerEditScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
              ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GridList<Trainer>(
            items: trainers,
            crossAxisCount: 2,
            builder:
                (trainer) => Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: GestureDetector(
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => TrainerDetailScreen(trainer: trainer),
                          ),
                        ),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: Colors.grey[900],
                      elevation: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                            child: Image.asset(
                              trainer.imageUrl,
                              height: 200,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) =>
                                      const Icon(Icons.person, size: 100),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  trainer.name,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  trainer.path.label,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[400],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  trainer.trainings.length > 50
                                      ? '${trainer.trainings.substring(0, 50)}...'
                                      : trainer.trainings,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
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
    );
  }
}
