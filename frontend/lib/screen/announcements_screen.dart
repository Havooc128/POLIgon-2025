import 'package:flutter/material.dart';
import 'package:poligon/provider/daily_quest_provider.dart';
import 'package:poligon/service/announcement_service.dart';
import 'package:poligon/service/daily_service.dart';
import 'package:provider/provider.dart';
import 'package:poligon/screen/widget/announcement_card.dart';

import '../model/announcement.dart';
import '../model/crew.dart';
import '../provider/auth_provider.dart';
import '../provider/base_provider.dart';

/// Author: Łukasz Piętka (FUT 2025)
class AnnouncementsScreen extends StatelessWidget {
  final VoidCallback onDrawerOpen;

  const AnnouncementsScreen({super.key, required this.onDrawerOpen});

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<BaseNotifier<Announcement>>();
    final authProvider = context.watch<AuthProvider>();

    final announcements = notifier.items;

    final dailyAnnouncement =
        context.watch<DailyQuestProvider>().getAnnouncementForToday();
    final isLoggedIn = authProvider.user != null && authProvider.me != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ogłoszenia'),
        actions: [
          if (isLoggedIn)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed:
                  () => _showAddAnnouncementDialog(context, authProvider.me!),
            ),
        ],
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: onDrawerOpen,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          if (dailyAnnouncement != null)
            const Text('ROZKAZ DZIENNY', style: TextStyle(fontSize: 25)),
          if (dailyAnnouncement != null)
            GestureDetector(
              child: AnnouncementCard(
                announcement: dailyAnnouncement,
                isDailyQuest: true,
              ),
              onLongPress: () {
                if (!isLoggedIn) return;
                _showAddAnnouncementDialog(
                  context,
                  authProvider.me!,
                  announcementType: 'Rozkaz Dnia',
                  toBeEdited: dailyAnnouncement,
                );
              },
            ),
          Expanded(
            child: ListView.builder(
              itemCount: announcements.length,
              itemBuilder: (context, index) {
                final announcement = announcements[index];
                return GestureDetector(
                  child: AnnouncementCard(announcement: announcement),
                  onLongPress: () {
                    if (!isLoggedIn) return;
                    _showAddAnnouncementDialog(
                      context,
                      authProvider.me!,
                      toBeEdited: announcement,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddAnnouncementDialog(
    BuildContext context,
    Crew author, {
    Announcement? toBeEdited,
    announcementType = 'Ogłoszenie',
  }) {
    final formKey = GlobalKey<FormState>();
    DateTime? publishDate = toBeEdited?.publishDate;
    final TextEditingController contentController = TextEditingController(
      text: toBeEdited?.text,
    );

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Dodaj nowe ogłoszenie'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        value: announcementType,
                        decoration: const InputDecoration(labelText: 'Typ'),
                        items: const [
                          DropdownMenuItem(
                            value: 'Ogłoszenie',
                            child: Text('Ogłoszenie'),
                          ),
                          DropdownMenuItem(
                            value: 'Rozkaz Dnia',
                            child: Text('Rozkaz Dnia'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              announcementType = value;
                            });
                          }
                        },
                      ),
                      if (announcementType == 'Rozkaz Dnia')
                        ElevatedButton(
                          onPressed: () async {
                            final selectedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (selectedDate != null) {
                              setState(() {
                                publishDate = selectedDate;
                              });
                            }
                          },
                          child: Text(
                            publishDate == null
                                ? 'Wybierz datę publikacji'
                                : 'Data: ${publishDate!.toLocal().toString().split(' ')[0]}',
                          ),
                        ),
                      TextFormField(
                        controller: contentController,
                        decoration: const InputDecoration(
                          labelText: 'Treść',
                          alignLabelWithHint: true,
                        ),
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Podaj treść ogłoszenia';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Anuluj'),
                ),
                if (toBeEdited != null)
                  OutlinedButton(
                    onPressed: () async {
                      bool deleted = await _onDeleteButtonPressed(context, toBeEdited, announcementType) ?? false;
                      if (deleted) {
                        Navigator.of(context).pop();

                      }
                    },
                    child: Text('Usuń'),
                  ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      if (announcementType == 'Rozkaz Dnia' &&
                          publishDate == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Podaj datę publikacji dla Rozkazu Dnia',
                            ),
                          ),
                        );
                        return;
                      }

                      final newAnnouncement = Announcement(
                        id: toBeEdited != null ? toBeEdited.id : -1,
                        text: contentController.text.trim(),
                        publishDate: publishDate ?? DateTime.now(),
                        author: author,
                      );

                      if (announcementType == 'Rozkaz Dnia') {
                        DailyQuestService().saveOrUpdate(newAnnouncement);
                      } else {
                        AnnouncementService().saveOrUpdate(newAnnouncement);
                      }
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Dodaj'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<bool?> _onDeleteButtonPressed(BuildContext context, Announcement announcement, String type) async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Czy na pewno usunąć?'),
          content: Text('Czy na pewno chcesz usunąć ogłoszenie?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Anuluj')),
            ElevatedButton(onPressed: () async {
              if (type == 'Rozkaz Dnia') {
                await DailyQuestService().delete(announcement.id);
              } else {
                await AnnouncementService().delete(announcement.id);
              }
              Navigator.pop(context, true);
            }, child: Text('Usuń'))
          ],
        );
      },
    );
  }
}
