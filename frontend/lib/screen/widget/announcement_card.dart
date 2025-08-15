import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:poligon/model/announcement.dart';

import 'crew_details_screen.dart';

/// Author: Łukasz Piętka (FUT 2025)
class AnnouncementCard extends StatefulWidget {
  final Announcement announcement;
  final bool isDailyQuest;

  const AnnouncementCard({
    super.key,
    required this.announcement,
    this.isDailyQuest = false,
  });

  @override
  State<AnnouncementCard> createState() => _AnnouncementCardState();
}

/// Author: Łukasz Piętka (FUT 2025)
class _AnnouncementCardState extends State<AnnouncementCard> {
  String _formatDate(DateTime date) {
    final formatter = DateFormat(
      widget.isDailyQuest ? 'EEE, dd.MM' : 'EEE, dd.MM HH:mm',
      'pl',
    );
    return formatter.format(date);
  }

  @override
  Widget build(BuildContext context) {
    Announcement announcement = widget.announcement;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        color: widget.isDailyQuest ? Colors.teal : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap:
                    () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (_) => CrewDetailScreen(crew: announcement.author),
                      ),
                    ),
                child: CircleAvatar(
                  backgroundImage: AssetImage(announcement.author.imageUrl),
                  radius: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap:
                          () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (_) => CrewDetailScreen(
                                    crew: announcement.author,
                                  ),
                            ),
                          ),
                      child: Text(
                        announcement.author.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.isDailyQuest ? 'ROZKAZ DZIENNY NA' : ''} ${_formatDate(announcement.publishDate.add(Duration(hours: 2)))}',
                      style: TextStyle(
                        color:
                            widget.isDailyQuest
                                ? Colors.white
                                : Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      announcement.text,

                      style: TextStyle(
                        fontSize: widget.isDailyQuest ? 20 : 16,
                        fontWeight:
                            widget.isDailyQuest ? FontWeight.bold : null,
                      ),
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
}
