import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/project.dart';
import '../providers/project_provider.dart';
import '../providers/entitlement_provider.dart';
import 'layers_screen.dart';
import 'paywall_screen.dart';

class ProjectScreen extends ConsumerStatefulWidget {
  const ProjectScreen({super.key});

  @override
  ConsumerState<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends ConsumerState<ProjectScreen> {
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Load projects on init
    Future.microtask(
      () => ref.read(projectListProvider.notifier).loadProjects(),
    );
  }

  Future<void> _pickAndCreateProject() async {
    // Check if user can create more projects
    final canCreate = ref.read(canCreateProjectProvider);

    if (!canCreate) {
      // Show paywall
      final upgraded = await Navigator.of(
        context,
      ).push<bool>(MaterialPageRoute(builder: (_) => const PaywallScreen()));

      if (upgraded != true) return; // User didn't upgrade
    }

    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 2048,
      maxHeight: 2048,
    );

    if (image == null) return;

    // Read bytes directly from XFile (works on iOS sandbox)
    final bytes = await image.readAsBytes();
    final fileName = image.name;

    await ref.read(projectListProvider.notifier).createProject(bytes, fileName);
  }

  void _navigateToProject(Project project) {
    // Set current project and navigate to layers screen
    ref.read(currentProjectProvider.notifier).state = project;
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const LayersScreen()));
  }

  Future<void> _deleteProject(Project project) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project?'),
        content: Text(
          'Are you sure you want to delete "${project.name}"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(projectListProvider.notifier).deleteProject(project.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectState = ref.watch(projectListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Layers'), centerTitle: true),
      body: _buildBody(context, projectState),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pickAndCreateProject,
        icon: const Icon(Icons.add_photo_alternate),
        label: const Text('New Project'),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ProjectListState state) {
    switch (state.status) {
      case ProjectListStatus.initial:
      case ProjectListStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case ProjectListStatus.error:
        return _buildErrorState(context, state.errorMessage ?? 'Unknown error');
      case ProjectListStatus.loaded:
        return state.projects.isEmpty
            ? _buildEmptyState(context)
            : _buildProjectGrid(context, state.projects);
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
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
            'No projects yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first project to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: _pickAndCreateProject,
            icon: const Icon(Icons.upload_file),
            label: const Text('Import Image'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load projects',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () =>
                ref.read(projectListProvider.notifier).loadProjects(),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectGrid(BuildContext context, List<Project> projects) {
    return RefreshIndicator(
      onRefresh: () => ref.read(projectListProvider.notifier).loadProjects(),
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: projects.length,
        itemBuilder: (context, index) {
          final project = projects[index];
          return _ProjectCard(
            project: project,
            onTap: () => _navigateToProject(project),
            onDelete: () => _deleteProject(project),
          );
        },
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ProjectCard({
    required this.project,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isProcessing =
        project.status == 'processing' || project.status == 'queued';
    final isFailed = project.status == 'failed';
    final isReady = project.status == 'ready';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isReady ? onTap : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thumbnail
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Source image thumbnail
                  _buildThumbnail(context),
                  // Status overlay
                  if (!isReady) _buildStatusOverlay(context),
                ],
              ),
            ),
            // Info footer
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.name,
                          style: Theme.of(context).textTheme.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        _buildStatusBadge(context),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 20),
                    itemBuilder: (context) => [
                      if (isReady)
                        const PopupMenuItem(
                          value: 'open',
                          child: ListTile(
                            leading: Icon(Icons.open_in_new),
                            title: Text('Open'),
                            dense: true,
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          title: Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                          dense: true,
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'open') onTap();
                      if (value == 'delete') onDelete();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(BuildContext context) {
    // Generate signed URL from storage path
    if (project.sourceImagePath.isEmpty) {
      return _buildPlaceholder(context);
    }

    if (project.sourceImagePath.startsWith('http')) {
      return Image.network(
        project.sourceImagePath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(context),
      );
    }

    // Use FutureBuilder to get signed URL for private bucket
    return FutureBuilder<String>(
      future: Supabase.instance.client.storage
          .from('source-images')
          .createSignedUrl(project.sourceImagePath, 3600), // 1 hour expiry
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Image.network(
            snapshot.data!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildPlaceholder(context),
          );
        }
        return _buildPlaceholder(context);
      },
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.image_outlined,
        size: 48,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildStatusOverlay(BuildContext context) {
    final isProcessing =
        project.status == 'processing' || project.status == 'queued';
    final isFailed = project.status == 'failed';

    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isProcessing) ...[
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 12),
              Text(
                project.status == 'queued' ? 'Queued...' : 'Processing...',
                style: const TextStyle(color: Colors.white),
              ),
            ],
            if (isFailed) ...[
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 8),
              const Text(
                'Processing failed',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Color backgroundColor;
    Color textColor;
    String label;
    IconData icon;

    switch (project.status) {
      case 'queued':
        backgroundColor = colorScheme.secondaryContainer;
        textColor = colorScheme.onSecondaryContainer;
        label = 'Queued';
        icon = Icons.schedule;
        break;
      case 'processing':
        backgroundColor = colorScheme.primaryContainer;
        textColor = colorScheme.onPrimaryContainer;
        label = 'Processing';
        icon = Icons.autorenew;
        break;
      case 'ready':
        backgroundColor = colorScheme.tertiaryContainer;
        textColor = colorScheme.onTertiaryContainer;
        label = 'Ready';
        icon = Icons.check_circle_outline;
        break;
      case 'failed':
        backgroundColor = colorScheme.errorContainer;
        textColor = colorScheme.onErrorContainer;
        label = 'Failed';
        icon = Icons.error_outline;
        break;
      default:
        backgroundColor = colorScheme.surfaceContainerHighest;
        textColor = colorScheme.onSurfaceVariant;
        label = project.status;
        icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
