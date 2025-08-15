import 'package:flutter/material.dart';
import 'package:poligon/main.dart';
import 'package:poligon/model/path.dart';
import 'package:poligon/model/schedule_day.dart';
import 'package:poligon/model/schedule_element.dart';
import 'package:poligon/provider/schedule_provider.dart';
import 'package:poligon/service/schedule_service.dart';
import 'package:provider/provider.dart';

import '../../provider/auth_provider.dart';
import '../widget/max_width_container.dart';

/// Author: Łukasz Piętka (FUT 2025)
class EditScheduleScreen extends StatefulWidget {
  final ScheduleDay? existingDay;

  const EditScheduleScreen({super.key, this.existingDay});

  @override
  State<EditScheduleScreen> createState() => _EditScheduleScreenState();
}

/// Author: Łukasz Piętka (FUT 2025)
class _EditScheduleScreenState extends State<EditScheduleScreen> {
  late DateTime _selectedDate;
  late TrainingPath _selectedPath;
  late List<ScheduleElement> _elements;

  @override
  void initState() {
    super.initState();
    if (widget.existingDay != null) {
      _selectedDate = widget.existingDay!.day;
      _selectedPath = widget.existingDay!.path;
      _elements =
          widget.existingDay!.elements
              .map(
                (e) => ScheduleElement(
                  id: e.id,
                  startTime: e.startTime,
                  endTime: e.endTime,
                  description: e.description,
                ),
              )
              .toList();
    } else {
      _selectedDate = DateTime.now();
      _selectedPath = Provider.of<ScheduleProvider>(context, listen: false).path ?? TrainingPath.wspolpraca;
      _elements = [];
    }
  }

  void _addElement() {
    setState(() {
      _elements.add(
        ScheduleElement(
          id: DateTime.now().millisecondsSinceEpoch,
          startTime: const TimeOfDay(hour: 9, minute: 0),
          endTime: const TimeOfDay(hour: 10, minute: 0),
          description: '',
        ),
      );
    });
  }

  void _delete() async {
    if (_selectedPath == TrainingPath.wszystkie) {
      return;
    }
    if (widget.existingDay != null) {
      final confirm = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Potwierdzenie'),
              content: const Text('Na pewno chcesz usunąć ten dzień?'),
              actions: [
                TextButton(
                  child: const Text('Anuluj'),
                  onPressed: () => Navigator.pop(context, false),
                ),
                TextButton(
                  child: const Text('Usuń'),
                  onPressed: () => Navigator.pop(context, true),
                ),
              ],
            ),
      );

      if (confirm == true) {
        final secondConfirm = await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Uwaga!'),
                content: const Text(
                  'To jest operacja nieodwracalna! Na pewno chcesz usunąć cały dzień w harmonogramie?',
                ),
                actions: [
                  TextButton(
                    child: const Text('Anuluj'),
                    onPressed: () => Navigator.pop(context, false),
                  ),
                  TextButton(
                    child: const Text('Tak, usuń'),
                    onPressed: () => Navigator.pop(context, true),
                  ),
                ],
              ),
        );

        if (secondConfirm == true) {
          await ScheduleService().delete(widget.existingDay!.id);
          sendSnackBar(context);
          Navigator.pop(context);
        }
      }
    } else {
      Navigator.of(context).pop();
    }
  }

  void _save({copy = false}) async {
    final id = copy ? -1 : widget.existingDay?.id ?? -1;
    if (_selectedPath == TrainingPath.wszystkie) {
      for (TrainingPath path in TrainingPath.all) {
        if(path == TrainingPath.wszystkie) {
          continue;
        }
        final newDay = ScheduleDay(
          id: id,
          day: _selectedDate,
          path: path,
          elements: List.from(_elements),
          lastModified: DateTime.now(),
        );

        await ScheduleService().saveOrUpdate(newDay);
      }
    } else {
      final newDay = ScheduleDay(
        id: id,
        day: _selectedDate,
        path: _selectedPath,
        elements: List.from(_elements),
        lastModified: DateTime.now(),
      );

      await ScheduleService().saveOrUpdate(newDay);
    }
    sendSnackBar(context);
    Navigator.of(context).pop();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final canCopyDay = authProvider.me != null && authProvider.me!.isSuperAdmin;
    return MaxWidthContainer(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.existingDay == null ? 'Dodaj dzień' : 'Edytuj dzień',
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              // Data
              Row(
                children: [
                  const Text("Data: "),
                  TextButton(
                    onPressed: _pickDate,
                    child: Text(
                      '${_selectedDate.day}.${_selectedDate.month}.${_selectedDate.year}',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Ścieżka
              DropdownButtonFormField<TrainingPath>(
                value: _selectedPath,
                decoration: const InputDecoration(
                  labelText: 'Ścieżka szkoleniowa',
                ),
                items:
                    TrainingPath.values.map((path) {
                      return DropdownMenuItem(
                        value: path,
                        child: Text(path.label),
                      );
                    }).toList(),
                onChanged: (newPath) {
                  if (newPath != null) {
                    setState(() => _selectedPath = newPath);
                  }
                },
              ),

              const SizedBox(height: 16),

              // Lista elementów
              ..._elements.map((e) {
                final idx = _elements.indexOf(e);
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Opis ${idx + 1}',
                          ),
                          controller: TextEditingController(text: e.description),
                          onChanged: (val) => e.description = val,
                        ),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () async {
                                final picked = await showTimePicker(
                                  context: context,
                                  initialTime: e.startTime,
                                );
                                if (picked != null) {
                                  setState(() => e.startTime = picked);
                                }
                              },
                              child: Text('Od: ${e.startTime.format(context)}'),
                            ),
                            TextButton(
                              onPressed: () async {
                                final picked = await showTimePicker(
                                  context: context,
                                  initialTime: e.endTime,
                                );
                                if (picked != null) {
                                  setState(() => e.endTime = picked);
                                }
                              },
                              child: Text('Do: ${e.endTime.format(context)}'),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() => _elements.removeAt(idx));
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 16),

              ElevatedButton.icon(
                onPressed: _addElement,
                icon: const Icon(Icons.add),
                label: const Text('Dodaj element'),
              ),

              const SizedBox(height: 10),

              ElevatedButton(onPressed: _save, child: const Text('Zapisz dzień')),

              if (canCopyDay)
                const SizedBox(height: 10,),
              if (canCopyDay)
                ElevatedButton(onPressed: () => _save(copy: true), child: const Text('Kopiuj dzień')),

              const SizedBox(height: 36),
              OutlinedButton(
                onPressed: _delete,
                child: Text(
                  widget.existingDay == null
                      ? 'Anuluj dodawanie dnia'
                      : 'Usuń dzień',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
