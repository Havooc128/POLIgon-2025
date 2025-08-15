import 'package:flutter/material.dart';
import 'package:poligon/service/trainer_service.dart';
import 'package:provider/provider.dart';

import '../../model/trainer.dart';
import '../../provider/auth_provider.dart';
import '../edit/trainer_edit_screen.dart';
import 'max_width_container.dart';

/// Author: Łukasz Piętka (FUT 2025)
class TrainerDetailScreen extends StatefulWidget {
  final Trainer trainer;

  const TrainerDetailScreen({super.key, required this.trainer});

  @override
  State<TrainerDetailScreen> createState() => _TrainerDetailScreenState();
}

/// Author: Łukasz Piętka (FUT 2025)
class _TrainerDetailScreenState extends State<TrainerDetailScreen> {
  double _currentAlignmentY = 0;

  @override
  void initState() {
    super.initState();
    _currentAlignmentY = widget.trainer.imageAlignmentY;
  }

  @override
  Widget build(BuildContext context) {
    final me = Provider.of<AuthProvider>(context, listen: false).me;
    final canEdit = me != null && me.isSuperAdmin;

    return MaxWidthContainer(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.trainer.name),
          actions: [
            if (canEdit)
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TrainerEditScreen(trainer: widget.trainer),
                    ),
                  );
                },
                icon: const Icon(Icons.edit),
              ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Zdjęcie
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 340,
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(),
                    child: FittedBox(
                      fit: BoxFit.cover,
                      alignment: Alignment(0, _currentAlignmentY),
                      child: Image.asset(
                        widget.trainer.imageUrl,
                        errorBuilder:
                            (_, __, ___) => const Icon(Icons.person, size: 100),
                      ),
                    ),
                  ),

                  if (me != null && me.isSuperAdmin)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: Icon(Icons.tune, color: Colors.white),
                        onPressed: () {
                          _showImagePositionEditor(context);
                        },
                      ),
                    ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Imię
                    Text(
                      widget.trainer.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Ścieżka szkoleniowa
                    Text(
                      widget.trainer.path.label,
                      style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                    ),
                    const SizedBox(height: 16),

                    // Szkolenia
                    const Text(
                      'Szkolenia:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.trainer.trainings,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    const SizedBox(height: 24),

                    // Opis
                    const Text(
                      'Opis:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.trainer.description,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImagePositionEditor(BuildContext context) async {
    final result = await showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, localSetState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Ustawienie zdjęcia', style: TextStyle(fontSize: 18)),
                  Slider(
                    value: _currentAlignmentY,
                    min: -1.0,
                    max: 1.0,
                    divisions: 20,
                    label: _currentAlignmentY.toStringAsFixed(2),
                    onChanged: (value) {
                      setState(() {
                        _currentAlignmentY = value;
                      });
                      localSetState(() {
                        _currentAlignmentY = value;
                      });
                    },
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context).pop(true);
                      widget.trainer.imageAlignmentY = _currentAlignmentY;
                      TrainerService().saveOrUpdate(widget.trainer);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Pozycja zdjęcia zaktualizowana'),
                        ),
                      );
                    },
                    child: Text('Zapisz'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    if (result == null) {
      setState(() {
        _currentAlignmentY = widget.trainer.imageAlignmentY;
      });
    }
  }
}
