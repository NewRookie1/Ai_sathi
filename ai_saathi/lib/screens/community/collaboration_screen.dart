import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/config/theme.dart';
import '../../services/community_service.dart';
import '../../services/localization_service.dart';

class CollaborationScreen extends StatefulWidget {
  const CollaborationScreen({super.key});

  @override
  State<CollaborationScreen> createState() => _CollaborationScreenState();
}

class _CollaborationScreenState extends State<CollaborationScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => context.read<CommunityService>().refreshFromBackend());
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<CommunityService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t('collaboration')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        bottom: service.isSyncing
            ? const PreferredSize(
                preferredSize: Size.fromHeight(3),
                child: LinearProgressIndicator(minHeight: 3),
              )
            : null,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context),
        icon: const Icon(Icons.add),
        label: Text(context.t('create_post')),
      ),
      body: RefreshIndicator(
        onRefresh: () => service.refreshFromBackend(),
        child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            context.t('collaboration_desc'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 16),
          ...service.collabs.map((post) {
            final interested =
                service.isInterested(post.id) || post.interested;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            post.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _localizedType(context, post.type),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.purple,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      post.description,
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${post.author} • ${post.location}',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final nowInterested = await service
                              .toggleInterest(post.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  content: Text(nowInterested
                                      ? '${context.t('interested')} ✓ (${post.interestedCount + 1})'
                                      : context.t('interested')),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                          }
                        },
                        icon: Icon(
                          interested
                              ? Icons.check_circle
                              : Icons.handshake_outlined,
                          size: 18,
                        ),
                        label: Text(
                          '${context.t('interested')} (${post.interestedCount})',
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: interested
                              ? Colors.green
                              : AppTheme.primaryColor,
                          side: BorderSide(
                            color: interested
                                ? Colors.green
                                : AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 80),
        ],
        ),
      ),
    );
  }

  String _localizedType(BuildContext context, String type) {
    switch (type) {
      case 'Need help':
        return context.t('need_help');
      case 'Share material':
        return context.t('share_material');
      case 'Joint product':
        return context.t('joint_product');
      default:
        return type;
    }
  }

  void _showCreateDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String type = 'Need help';

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(context.t('create_post')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: context.t('post_title'),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: type,
                  items: [
                    DropdownMenuItem(
                      value: 'Need help',
                      child: Text(context.t('need_help')),
                    ),
                    DropdownMenuItem(
                      value: 'Share material',
                      child: Text(context.t('share_material')),
                    ),
                    DropdownMenuItem(
                      value: 'Joint product',
                      child: Text(context.t('joint_product')),
                    ),
                  ],
                  onChanged: (v) {
                    if (v != null) setDialogState(() => type = v);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: context.t('post_desc'),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(context.t('cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty) return;
                context.read<CommunityService>().addCollabPost(
                      title: titleController.text.trim(),
                      type: type,
                      description: descController.text.trim(),
                    );
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.t('post_created'))),
                );
              },
              child: Text(context.t('submit')),
            ),
          ],
        ),
      ),
    );
  }
}
