import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../model/song.dart';
import '../../provider/auth_provider.dart';
import '../../service/song_service.dart';
import 'max_width_container.dart';

/// Author: Łukasz Piętka (FUT 2025)
class SongDetailScreen extends StatelessWidget {
  final Song song;

  const SongDetailScreen({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final canEdit = authProvider.user != null && authProvider.me != null;

    return MaxWidthContainer(
      child: Scaffold(
        appBar: AppBar(
          title: Text(song.title),
          actions: [
            if (canEdit)
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Edytuj',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SongEditScreen(song: song),
                    ),
                  );
                },
              ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Text(
              song.songText,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }
}

class SongEditScreen extends StatefulWidget {
  final Song? song;

  const SongEditScreen({super.key, this.song});

  @override
  State<SongEditScreen> createState() => _SongEditScreenState();
}

/// Author: Łukasz Piętka (FUT 2025)
class _SongEditScreenState extends State<SongEditScreen> {
  late TextEditingController titleController;
  late TextEditingController textController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.song?.title ?? '');
    textController = TextEditingController(text: widget.song?.songText ?? '');
  }

  @override
  void dispose() {
    titleController.dispose();
    textController.dispose();
    super.dispose();
  }

  void saveSong() async {
    final newSong = Song(
      id: widget.song?.id ?? 0, // 0 dla nowej piosenki
      title: titleController.text,
      songText: textController.text,
    );

    await SongService().saveOrUpdate(newSong);
    if (mounted) Navigator.pop(context);
  }

  void deleteSong() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Potwierdzenie'),
        content: const Text('Na pewno chcesz usunąć tę piosenkę?'),
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
      await SongService().delete(widget.song!.id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.song != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edytuj piosenkę' : 'Dodaj piosenkę'),
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Usuń piosenkę',
              onPressed: deleteSong,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Tytuł'),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: textController,
                decoration: const InputDecoration(labelText: 'Treść piosenki'),
                maxLines: null,
                expands: true,
                keyboardType: TextInputType.multiline,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Zapisz'),
              onPressed: saveSong,
            ),
          ],
        ),
      ),
    );
  }
}
