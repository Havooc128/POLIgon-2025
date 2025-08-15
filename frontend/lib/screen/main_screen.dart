import 'package:flutter/material.dart';
import 'package:poligon/screen/map_screen.dart';
import 'package:poligon/screen/song_screen.dart';
import 'package:poligon/screen/trainers_screen.dart';
import 'package:poligon/service/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../model/crew.dart';
import '../provider/auth_provider.dart';
import 'widget/crew_details_screen.dart';
import 'schedule_screen.dart';
import 'teams_screen.dart';
import 'announcements_screen.dart';
import 'crew_screen.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

/// Author: Łukasz Piętka (FUT 2025)
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

/// Author: Łukasz Piętka (FUT 2025)
class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1;

  final List<Widget> _screens = [
    TeamScreen(onDrawerOpen: () => _scaffoldKey.currentState?.openDrawer()),
    ScheduleScreen(onDrawerOpen: () => _scaffoldKey.currentState?.openDrawer()),
    AnnouncementsScreen(
      onDrawerOpen: () => _scaffoldKey.currentState?.openDrawer(),
    ),
  ];

  void _onBottomNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToWidget(BuildContext context, Widget widget) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => widget));
  }

  Widget bottomTile(BuildContext context) {
    Crew? me = Provider.of<AuthProvider>(context, listen: false).me;

    if (me != null) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => CrewDetailScreen(crew: me)),
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: AssetImage(me.imageUrl),
                  backgroundColor: Colors.grey[300],
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(me.name, overflow: TextOverflow.ellipsis)),
                Divider(),
                IconButton(
                  onPressed: () => AuthService().signOut(),
                  icon: Icon(Icons.logout),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () async => AuthService().signInWithGoogle(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          '© 2025 Łukasz Piętka',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AuthProvider>();
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        backgroundColor: Theme.of(context).colorScheme.surface,
        child: Column(
          children: [
            DrawerHeader(padding: EdgeInsets.zero,
              child: SizedBox.expand(
                child: Image.asset(
                  'assets/logo.webp',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(top: 20),
                children: [
                  ListTile(
                    leading: const Icon(Icons.group),
                    title: const Text('Kadra'),
                    onTap: () => _navigateToWidget(context, CrewScreen()),
                  ),
                  ListTile(
                    leading: const Icon(Icons.queue_music),
                    title: const Text('Śpiewnik'),
                    onTap: () => _navigateToWidget(context, SongScreen()),
                  ),
                  ListTile(
                    leading: const Icon(Icons.groups),
                    title: const Text('Szkoleniowcy'),
                    onTap: () => _navigateToWidget(context, TrainersScreen()),
                  ),
                  ListTile(
                    leading: const Icon(Icons.map),
                    title: const Text('Mapa'),
                    onTap: () => _navigateToWidget(context, MapScreen()),
                  ),
                  ListTile(
                    leading: const Icon(Icons.rule),
                    title: const Text('Regulamin'),
                    onTap:
                        () async => await launchUrlString(
                          'https://rejestracja.fut.edu.pl/wp-content/uploads/2025/06/Regulamin-POLIgon-2025.pdf',
                        ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.facebook),
                    title: const Text('Grupa na FB'),
                    onTap:
                        () async => await launchUrlString(
                          'https://www.facebook.com/groups/4136628859993207/',
                        ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.queue_music),
                    title: const Text('Playlista na Spotify'),
                    onTap:
                        () async => await launchUrlString(
                      'https://l.facebook.com/l.php?u=https%3A%2F%2Fopen.spotify.com%2Fplaylist%2F2nUWetPB9MfcTvuykpaWPc%3Fsi%3Df5638fab5f5b4570%26pt%3Dd96145804959c7c7b70d81b7248ce0fa%26fbclid%3DIwZXh0bgNhZW0CMTAAYnJpZBEwbDVvdzNsQzg1MVZGZkdUeAEe-EMBr8M8g9eAkA4VYmwAAdyyJUFLsKx0jL-ApFHVWUstQcX7hnqC-aA74o4_aem_k6vfGcfew_uvKAgi45M9_A&h=AT3sXHx1Vp3u2KzCG5Iy-BzDckWJrmdgJDceE0VTDpFddbqiYYQy2KAyO2BHF18-LbWNe4v5urb0ITVrcjtnzLdeB2f5NKnQk375Ca-_5KELSo8VV5bAyM2WRGpJEwRh2HHszVG1HfX0vEcCY_U0cfJc7eDXXDBf&__tn__=-UK-R&c[0]=AT2Gstmt8-uBMTfDAq9n_JYlaylkYA7WkjO3jguyoMGdCVdHk_eW3FfPCQP_lwE7HHAN_NyJoHWqlNo9izYwpAT2A7cajdN8Soud2dItECJK4VRbtJg-0I9KXwzj7_JTpd3lY42CbzFHsf_363Uj8ZdwZTivxlu1HILbSX3jbgpNZZ2ywg1LTYiatEn6t_WiaaxOBUWyjt1qk6aMGjYz3THBzFuoapA',
                    ),
                  )
                ],
              ),
            ),
            bottomTile(context),
          ],
        ),
      ),

      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        selectedFontSize: 18,
        unselectedFontSize: 12,
        onTap: _onBottomNavTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.groups), label: 'Drużyny'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Harmonogram',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign),
            label: 'Ogłoszenia',
          ),
        ],
      ),
    );
  }
}
