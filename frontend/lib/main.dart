import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:poligon/provider/auth_provider.dart';
import 'package:poligon/provider/base_provider.dart';
import 'package:poligon/provider/daily_quest_provider.dart';
import 'package:poligon/provider/schedule_provider.dart';
import 'package:poligon/screen/main_screen.dart';
import 'package:poligon/service/announcement_service.dart';
import 'package:poligon/service/crew_service.dart';
import 'package:poligon/service/song_service.dart';
import 'package:poligon/service/team_service.dart';
import 'package:poligon/service/trainer_service.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'screen/widget/max_width_container.dart';

/// Author: Łukasz Piętka (FUT 2025)
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  initializeDateFormatting();
  await Hive.initFlutter();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DailyQuestProvider()),
        ChangeNotifierProvider(create: (_) => ScheduleProvider()),
        ChangeNotifierProvider(create: (_) => BaseNotifier(AnnouncementService())),
        ChangeNotifierProvider(create: (_) => BaseNotifier(TrainerService())),
        ChangeNotifierProvider(create: (_) => BaseNotifier(SongService())),
        ChangeNotifierProvider(create: (_) => BaseNotifier(TeamService())),
        ChangeNotifierProvider(create: (_) => BaseNotifier(CrewService())),
      ],
      child: const MyApp(),
    ),
  );
}

void sendSnackBar(BuildContext context, {String message = 'Pomyślnie zapisano zmiany'}) async {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POLIgon 2025',
      theme: ThemeData.dark().copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        primaryColor: Colors.teal,
        scaffoldBackgroundColor: Colors.black,
        bottomAppBarTheme: BottomAppBarTheme(color: Colors.grey[900]),
      ),
      home: MaxWidthContainer(child: const MainScreen()),
    );
  }
}
