import 'package:flutter/material.dart';
import 'package:poligon/provider/auth_provider.dart';
import 'package:poligon/screen/widget/max_width_container.dart';
import 'package:poligon/screen/widget/song_detail_screen.dart';
import 'package:provider/provider.dart';

import '../model/song.dart';
import '../provider/base_provider.dart';

/// Author: Łukasz Piętka (FUT 2025)
class SongScreen extends StatefulWidget {
  const SongScreen({super.key});

  @override
  State<SongScreen> createState() => _SongScreenState();
}

/// Author: Łukasz Piętka (FUT 2025)
class _SongScreenState extends State<SongScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<BaseNotifier<Song>>();
    final auth = context.watch<AuthProvider>();
    final isLoggedIn = auth.me != null && auth.user != null;
    final songs = notifier.items;

    final filteredSongs = songs
        .where((song) =>
        song.title.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return MaxWidthContainer(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Śpiewnik"),
          actions: [
            if (isLoggedIn)
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: 'Dodaj piosenkę',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SongEditScreen(),
                    ),
                  );
                },
              ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Wyszukaj piosenkę',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredSongs.length,
                itemBuilder: (context, index) {
                  final song = filteredSongs[index];
                  return ListTile(
                    title: Text('${index + 1}. ${song.title}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SongDetailScreen(song: song),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}