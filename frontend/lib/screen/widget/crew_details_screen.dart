import 'package:flutter/material.dart';
import 'package:poligon/service/crew_service.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../model/crew.dart';
import '../../provider/auth_provider.dart';
import '../edit/edit_crew_screen.dart';
import 'max_width_container.dart';

/// Author: Łukasz Piętka (FUT 2025)
class CrewDetailScreen extends StatefulWidget {
  final Crew crew;

  const CrewDetailScreen({super.key, required this.crew});

  @override
  State<CrewDetailScreen> createState() => _CrewDetailScreenState();
}

/// Author: Łukasz Piętka (FUT 2025)
class _CrewDetailScreenState extends State<CrewDetailScreen> {
  double _currentAlignmentY = 0.0;

  bool _isSobrietyToday() {
    final now = DateTime.now();

    final sobrietyStart = DateTime(
      now.year,
      widget.crew.sobrietyDay.month,
      widget.crew.sobrietyDay.day,
      8,
      30,
    );
    final sobrietyEnd = sobrietyStart.add(const Duration(hours: 24));

    return now.isAfter(sobrietyStart) && now.isBefore(sobrietyEnd);
  }


  void _callPhoneNumber(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  void initState() {
    super.initState();
    _currentAlignmentY = widget.crew.imageAlignmentY;
  }

  @override
  Widget build(BuildContext context) {
    final Crew? me = Provider.of<AuthProvider>(context, listen: false).me;
    final isSobriety = _isSobrietyToday();
    return MaxWidthContainer(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.crew.name),
          actions: [
            if (me != null && (me.id == widget.crew.id || me.isSuperAdmin))
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EditCrewScreen(crew: widget.crew),
                    ),
                  );
                },
                icon: Icon(Icons.edit),
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
                        widget.crew.imageUrl,
                        errorBuilder:
                            (_, __, ___) => const Icon(Icons.person),
                      ),
                    ),
                  ),

                  if (me != null && (me.id == widget.crew.id || me.isSuperAdmin))
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
                    // Imię, rola, pokój
                    Text(
                      widget.crew.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.crew.role}\nPokój ${widget.crew.room}',
                      style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                    ),
                    const SizedBox(height: 16),

                    // Telefon + TRZEŹWIK
                    Row(
                      children: [
                        // Numer telefonu
                        Expanded(
                          flex: 3,
                          child: GestureDetector(
                            onTap:
                                () => _callPhoneNumber(widget.crew.phoneNumber),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.teal[700],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.phone,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    widget.crew.phoneNumber,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // TRZEŹWIK
                        if (isSobriety)
                          Expanded(
                            flex: 2,
                            child: GestureDetector(
                              onTap: () {
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${widget.crew.name} ma dziś dzień trzeźwości.',
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.teal[900],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.no_drinks,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'DYŻUR',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
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
                      widget.crew.description,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),

                    const SizedBox(height: 24),

                    // Rozkaz
                    const Text(
                      'Rozkaz kadrowicza:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.crew.crewQuest,
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
                      widget.crew.imageAlignmentY = _currentAlignmentY;
                      CrewService().saveOrUpdate(widget.crew);
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
        _currentAlignmentY = widget.crew.imageAlignmentY;
      });
    }
  }
}
