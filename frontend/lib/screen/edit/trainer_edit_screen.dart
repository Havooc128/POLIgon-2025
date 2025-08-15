import 'package:flutter/material.dart';
import 'package:poligon/main.dart';
import 'package:poligon/model/path.dart';
import 'package:poligon/model/trainer.dart';
import 'package:poligon/service/trainer_service.dart';

import '../widget/max_width_container.dart';

/// Author: Łukasz Piętka (FUT 2025)
class TrainerEditScreen extends StatefulWidget {
  final Trainer? trainer;

  const TrainerEditScreen({super.key, this.trainer});

  @override
  State<TrainerEditScreen> createState() => _TrainerEditScreenState();
}

/// Author: Łukasz Piętka (FUT 2025)
class _TrainerEditScreenState extends State<TrainerEditScreen> {
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController imageUrlController;
  late TextEditingController trainingsController;

  TrainingPath? selectedPath;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.trainer?.name ?? '');
    descriptionController = TextEditingController(text: widget.trainer?.description ?? '');
    imageUrlController = TextEditingController(text: widget.trainer?.imageUrl ?? '');
    trainingsController = TextEditingController(text: widget.trainer?.trainings ?? '');
    selectedPath = widget.trainer?.path ?? TrainingPath.all.first;
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    imageUrlController.dispose();
    trainingsController.dispose();
    super.dispose();
  }

  void saveTrainer() async {
    final newTrainer = Trainer(
      id: widget.trainer?.id ?? 0,
      name: nameController.text.trim(),
      description: descriptionController.text.trim(),
      imageUrl: imageUrlController.text.trim(),
      trainings: trainingsController.text.trim(),
      path: selectedPath!,
      imageAlignmentY: widget.trainer?.imageAlignmentY ?? 0,
    );

    await TrainerService().saveOrUpdate(newTrainer);
    sendSnackBar(context);
    if (mounted) Navigator.pop(context);
    if (mounted) Navigator.pop(context);
  }

  void deleteTrainer() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Potwierdzenie'),
        content: const Text('Czy na pewno chcesz usunąć tego szkoleniowca?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Anuluj'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Usuń'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await TrainerService().delete(widget.trainer!.id);
      sendSnackBar(context);
      Navigator.pop(context);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.trainer != null;

    return MaxWidthContainer(
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEdit ? 'Edytuj szkoleniowca' : 'Dodaj szkoleniowca'),
          actions: [
            if (isEdit)
              IconButton(
                icon: const Icon(Icons.delete),
                tooltip: 'Usuń',
                onPressed: deleteTrainer,
              ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Imię i nazwisko'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<TrainingPath>(
                value: selectedPath,
                items: TrainingPath.all
                    .map(
                      (path) => DropdownMenuItem(
                    value: path,
                    child: Text(path.label),
                  ),
                )
                    .toList(),
                onChanged: (val) => setState(() => selectedPath = val),
                decoration: const InputDecoration(labelText: 'Ścieżka'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Opis'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: trainingsController,
                decoration: const InputDecoration(labelText: 'Szkolenia'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: imageUrlController,
                decoration: const InputDecoration(labelText: 'URL zdjęcia'),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Zapisz'),
                onPressed: saveTrainer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
