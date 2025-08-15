import 'package:flutter/material.dart';
import 'package:poligon/screen/widget/max_width_container.dart';

/// Author: Łukasz Piętka (FUT 2025)
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();

  static Widget _buildLegendRow(String label, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              description,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

/// Author: Łukasz Piętka (FUT 2025)
class _MapScreenState extends State<MapScreen> {

  @override
  Widget build(BuildContext context) {
    return MaxWidthContainer(
      child: Scaffold(
        body: Stack(
          children: [
            // MAPA ZOOM + PAN
            Positioned.fill(
              child: InteractiveViewer(
                panEnabled: true,
                minScale: 1,
                maxScale: 4,
                clipBehavior: Clip.none,
                child: SizedBox.expand(
                  child: Image.asset(
                    'assets/Mapa-osrodka.webp',
                    fit: BoxFit.scaleDown,
                  ),
                ),
              ),
            ),

            // APPBAR
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AppBar(
                backgroundColor: Colors.black54,
                title: const Text('Mapa'),
                centerTitle: true,
                elevation: 0,
              ),
            ),

            // PODPOWIEDŹ
            Positioned(
              top: kToolbarHeight+56,
              right: 120,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Przybliż i przeciągnij mapę',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ),

            // LEGENDA
            DraggableScrollableSheet(
              initialChildSize: 0.20,
              minChildSize: 0.10,
              maxChildSize: 0.4,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: ListView(
                    controller: scrollController,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[700],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'LEGENDA (Przewiń do góry)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      MapScreen._buildLegendRow('Spanie', 'Domki 1-6'),
                      MapScreen._buildLegendRow('Jedzenie', 'Zielony - Stołówka'),
                      MapScreen._buildLegendRow(
                        'Wiedza',
                        'Czerwony - Sale Szkoleniowe',
                      ),
                      MapScreen._buildLegendRow(
                        'Chill out',
                        'Niebieski - Basen',
                      ),
                      MapScreen._buildLegendRow('FIT FUTy', 'Parking przed recepcją'),
                      MapScreen._buildLegendRow('Wieczorne integracje', 'Czerwony - Sale Szkoleniowe')
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
