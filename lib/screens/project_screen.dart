import 'package:flutter/material.dart';

class ProjectScreen extends StatelessWidget {
  const ProjectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Layers'), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Import or create a project',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Turn any image into editable layers',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.upload_file),
              label: const Text('Import Image'),
            ),
          ],
        ),
      ),
    );
  }
}
