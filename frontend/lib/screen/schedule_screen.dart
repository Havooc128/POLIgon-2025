import 'dart:async';

import 'package:flutter/material.dart';
import 'package:poligon/model/path.dart';
import 'package:poligon/provider/schedule_provider.dart';
import 'package:poligon/screen/edit/edit_schedule_screen.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../data/training_path_members.dart';
import '../provider/auth_provider.dart';


/// Author: Łukasz Piętka (FUT 2025)
class ScheduleScreen extends StatefulWidget {
  final VoidCallback onDrawerOpen;

  const ScheduleScreen({super.key, required this.onDrawerOpen});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

/// Author: Łukasz Piętka (FUT 2025)
class _ScheduleScreenState extends State<ScheduleScreen> {
  int selectedDayIndex = 0;
  Timer? _timer;
  DateTime _now = DateTime.now();
  bool initial = true;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  String _formatDate(DateTime date) {
    return "${date.day}.0${date.month}";
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  Future<void> _showPathPicker() async {
    final notifier = context.read<ScheduleProvider>();
    TrainingPath? selected = notifier.path;

    final chosen = await showDialog<TrainingPath>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Wybierz ścieżkę szkoleniową'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: TrainingPath.values
                    .where((path) => path != TrainingPath.wszystkie)
                    .map(
                      (path) => RadioListTile<TrainingPath>(
                    title: Text(path.label),
                    value: path,
                    groupValue: selected,
                    onChanged: (value) {
                      setState(() {
                        selected = value;
                      });
                    },
                  ),
                )
                    .toList(),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Anuluj'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(selected);
              },
              child: const Text('Zatwierdź'),
            ),
          ],
        );
      },
    );

    if (chosen != null) {
      notifier.load(chosen);
    }
  }

  void _showPeoplePopup() {
    final notifier = context.read<ScheduleProvider>();
    TrainingPath? selected = notifier.path;
    if(selected == null) {
      return;
    }
    final list = trainingPathMembers[selected.index];
    list.sort();
    showDialog(context: context, builder: (context) {
      return AlertDialog(
        scrollable: true,
        title: Text('Uczestnicy ściezki ${selected.label}'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: list
              .map((member) => Padding(
            padding:
            const EdgeInsets.symmetric(vertical: 2.0),
            child: Text('• $member'),
          ))
              .toList(),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Zamknij'))
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<ScheduleProvider>();
    final auth = context.watch<AuthProvider>();
    final canEdit = auth.me != null && auth.user != null;
    final days = notifier.days;
    if (initial && days.isNotEmpty) {
      selectedDayIndex = days.indexWhere((day) => isToday(day.day));
      initial = false;
    }
    if (selectedDayIndex == -1 || days.length < selectedDayIndex) {
      selectedDayIndex = 0;
    }

    final selectedDay = days.isNotEmpty ? days[selectedDayIndex] : null;
    return Scaffold(
      appBar: AppBar(
        title: Text(notifier.path?.label ?? 'Harmonogram'),
        actions: [
          IconButton(onPressed: _showPeoplePopup, icon: const Icon(Icons.groups)),
          IconButton(onPressed: _showPathPicker, icon: const Icon(Icons.settings)),
        ],
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: widget.onDrawerOpen,
          ),
        ),
      ),
      floatingActionButton: canEdit ? FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => EditScheduleScreen(),
          ),
        ),
        child: const Icon(Icons.add),
      ) : null,
      body: Column(
        children: [
          // Date selector
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: days.length,
              itemBuilder: (context, index) {
                bool isSelected = index == selectedDayIndex;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDayIndex = index;
                    });
                  },
                  onLongPress: canEdit ? () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EditScheduleScreen(existingDay: days[index],),
                    ),
                  ) : null,
                  child: Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.all(4),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      border: isToday(days[index].day) ? Border.all(color: Colors.teal, width: 2) : null,
                      color: isSelected
                          ? Colors.teal
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _formatDate(days[index].day),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.grey[300],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const Divider(),

          // Schedule
          Expanded(
            child: GestureDetector(
              onHorizontalDragEnd: (e) {
                final sensitivity = 500;
                if(e.primaryVelocity == null) {
                  return;
                }
                if (e.primaryVelocity! < -sensitivity && selectedDayIndex < selectedDay!.elements.length-1) {
                  setState(() {
                    selectedDayIndex++;
                  });
                } else if (e.primaryVelocity! > sensitivity && selectedDayIndex > 0) {
                  setState(() {
                    selectedDayIndex--;
                  });
                }
              },
              child: ListView.builder(
                itemCount: selectedDay?.elements.length ?? 0,
                itemBuilder: (context, index) {
                  final element = selectedDay!.elements[index];
                  final isOngoing = isCurrentBlock(selectedDay.day, element.startTime, element.endTime);
                  final minutes = minutesLeft(element.endTime);
                  final totalMinutes = element.startTime.hour * 60 + element.startTime.minute <= element.endTime.hour * 60 + element.endTime.minute
                      ? (element.endTime.hour * 60 + element.endTime.minute) - (element.startTime.hour * 60 + element.startTime.minute)
                      : (24 * 60 - (element.startTime.hour * 60 + element.startTime.minute)) + (element.endTime.hour * 60 + element.endTime.minute);
                  final progress = 1 - (minutes / totalMinutes);
                  final isEasterEgg = selectedDay.day.day == 26 && index == 1;

                  return GestureDetector(
                    onTap: isEasterEgg ? () async => await launchUrlString('https://www.youtube.com/watch?v=WNnzw90vxrE') : null,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isOngoing ? Colors.teal : Colors.grey[900],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                isEasterEgg && DateTime.now().day == 26 ? '${index + 1} KLIKNIJ NA MNIE!!' : '${index + 1}',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 24),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_formatTime(element.startTime), style: const TextStyle(fontSize: 16)),
                                  Text(_formatTime(element.endTime), style: const TextStyle(fontSize: 16)),
                                ],
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: Text(
                                  element.description,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isOngoing ? Colors.white : Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (isOngoing)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: LinearProgressIndicator(
                                      value: progress.clamp(0.0, 1.0),
                                      backgroundColor: Colors.teal.shade300,
                                      color: Colors.teal.shade100,
                                      minHeight: 6,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    "Pozostało $minutes min",
                                    style: const TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }


  bool isCurrentBlock(DateTime day, TimeOfDay start, TimeOfDay end) {
    final today = DateTime(_now.year, _now.month, _now.day);
    final blockDay = DateTime(day.year, day.month, day.day);

    final nowMinutes = _now.hour * 60 + _now.minute;
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;

    if (blockDay == today) {
      if (startMinutes <= endMinutes) {
        return nowMinutes >= startMinutes && nowMinutes < endMinutes;
      } else {
        // Przechodzi przez północ
        return nowMinutes >= startMinutes || nowMinutes < endMinutes;
      }
    } else if (blockDay.add(const Duration(days: 1)) == today && startMinutes > endMinutes) {
      // Drugi dzień bloku przez północ
      return nowMinutes < endMinutes;
    }
    return false;
  }

  int minutesLeft(TimeOfDay end) {
    final endTotal = end.hour * 60 + end.minute;
    final nowTotal = _now.hour * 60 + _now.minute;

    if (endTotal >= nowTotal) {
      return endTotal - nowTotal;
    } else {
      // Po północy
      return (24 * 60 - nowTotal) + endTotal;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }
}