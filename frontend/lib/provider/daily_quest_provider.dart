import 'package:poligon/model/announcement.dart';
import 'package:poligon/provider/base_provider.dart';
import 'package:poligon/service/daily_service.dart';

/// Author: Łukasz Piętka (FUT 2025)
class DailyQuestProvider extends BaseNotifier<Announcement> {
  DailyQuestProvider() : super(DailyQuestService());

  Announcement? getAnnouncementForToday() {
    final now = DateTime.now();

    final todayCutoff = DateTime(now.year, now.month, now.day, 12);

    // Jeśli teraz jest przed 12:00, to bierzemy wczoraj
    final effectiveDate = now.isBefore(todayCutoff)
        ? DateTime(now.year, now.month, now.day - 1)
        : DateTime(now.year, now.month, now.day);

    try {
      return items.firstWhere(
            (announcement) {
          final pubDate = announcement.publishDate;
          return pubDate.year == effectiveDate.year &&
              pubDate.month == effectiveDate.month &&
              pubDate.day == effectiveDate.day;
        });
    } catch (e) {
      return null;
    }
  }

}