import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/constants.dart';

/// Widget for displaying a friend in the friends list
class FriendListItem extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
                _getLastActiveText(),
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
                  'Friends since ${_getFriendsSinceText()}',
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

  String _getLastActiveText() {
    final now = DateTime.now();
    final difference = now.difference(friend.user.lastActiveAt);

    if (difference.inMinutes < 5) {
      return 'Active now';
    } else if (difference.inMinutes < 60) {
      return 'Active ${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return 'Active ${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Active yesterday';
    } else if (difference.inDays < 7) {
      return 'Active ${difference.inDays} days ago';
    } else {
      return 'Active ${friend.user.lastActiveAt.day}/${friend.user.lastActiveAt.month}';
    }
  }

  String _getFriendsSinceText() {
    final friendsSince = friend.friendsSince;
    final now = DateTime.now();
    final difference = now.difference(friendsSince);

    if (difference.inDays < 1) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? '1 year ago' : '$years years ago';
    }
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
