import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../utils/constants.dart';
import '../utils/date_time_localizations.dart';
import '../providers/language_provider.dart';

/// Widget for displaying a friend in the friends list
class FriendListItem extends ConsumerWidget {
  const FriendListItem({
    super.key,
    required this.friend,
    this.onTap,
    this.onRemove,
    this.showLastActive = true,
  });

  final Friend friend;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final bool showLastActive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(languageProvider);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppConstants.defaultPadding),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            friend.user.name.substring(0, 1).toUpperCase(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          friend.user.name,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showLastActive) ...[
              const SizedBox(height: 4),
              Text(
                DateTimeLocalizations.getActivityTime(
                  friend.user.lastActiveAt,
                  locale,
                ),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.people,
                  size: 14,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  locale.languageCode == 'es'
                      ? 'Amigos desde ${DateTimeLocalizations.getRelativeDate(friend.friendsSince, locale)}'
                      : 'Friends since ${DateTimeLocalizations.getRelativeDate(friend.friendsSince, locale)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'remove':
                _showRemoveDialog(context);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'remove',
              child: Row(
                children: [
                  Icon(Icons.person_remove, size: 18),
                  SizedBox(width: 8),
                  Text('Remove Friend'),
                ],
              ),
            ),
          ],
          child: Icon(
            Icons.more_vert,
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  void _showRemoveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Friend'),
        content: Text(
          'Are you sure you want to remove ${friend.user.name} from your friends? '
          'This will also delete any shared readings between you.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onRemove?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
