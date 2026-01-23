import 'package:flutter/material.dart';

class LayersScreen extends StatelessWidget {
  const LayersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Layers'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.view_in_ar),
            tooltip: '3D View',
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.list),
            tooltip: '2D Stack',
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.view_in_ar_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              '3D Layer View',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Import an image to see layers here',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Export',
        child: const Icon(Icons.ios_share),
      ),
    );
  }
}
