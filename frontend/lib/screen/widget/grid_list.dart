import 'package:flutter/material.dart';

/// Author: Łukasz Piętka (FUT 2025)
class GridList<T> extends StatelessWidget {
  const GridList({
    super.key,
    required this.items,
    required this.builder,
    this.crossAxisCount = 2,
  });

  final List<T> items;
  final Widget Function(T item) builder;
  final int crossAxisCount;

  @override
  Widget build(BuildContext context) {
    List<List<T>> rows = [];
    for (var i = 0; i < items.length; i += crossAxisCount) {
      rows.add(
        items.sublist(
          i,
          (i + crossAxisCount > items.length) ? items.length : i + crossAxisCount,
        ),
      );
    }

    return ListView.builder(
      itemCount: rows.length,
      itemBuilder: (context, rowIndex) {
        final rowItems = rows[rowIndex];
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final item in rowItems)
                Expanded(child: builder(item)),
              if (rowItems.length < crossAxisCount)
                ...List.generate(
                  crossAxisCount - rowItems.length,
                      (_) => const Expanded(child: SizedBox()),
                ),
            ],
          ),
        );
      },
    );
  }
}
