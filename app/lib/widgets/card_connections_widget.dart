import 'package:flutter/material.dart';
import '../services/manual_interpretation_service.dart';
import '../utils/constants.dart';

/// Widget for displaying connections between cards in a manual interpretation
class CardConnectionsWidget extends StatelessWidget {
  final List<CardConnection> connections;

  const CardConnectionsWidget({super.key, required this.connections});

  @override
  Widget build(BuildContext context) {
    if (connections.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.link,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Card Connections',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Connections list
            ...connections.map(
              (connection) => _buildConnectionItem(context, connection),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionItem(BuildContext context, CardConnection connection) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getConnectionColor(context, connection.connectionType),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Connection type and cards
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getConnectionColor(
                    context,
                    connection.connectionType,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  connection.connectionType.displayName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${connection.card1.card.name} ↔ ${connection.card2.card.name}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Connection description
          Text(
            connection.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Color _getConnectionColor(BuildContext context, ConnectionType type) {
    switch (type) {
      case ConnectionType.suit:
        return Colors.blue;
      case ConnectionType.majorArcana:
        return Colors.purple;
      case ConnectionType.reversed:
        return Colors.orange;
      case ConnectionType.thematic:
        return Colors.green;
    }
  }
}

/// Expandable widget for showing card connections
class ExpandableCardConnections extends StatefulWidget {
  final List<CardConnection> connections;

  const ExpandableCardConnections({super.key, required this.connections});

  @override
  State<ExpandableCardConnections> createState() =>
      _ExpandableCardConnectionsState();
}

class _ExpandableCardConnectionsState extends State<ExpandableCardConnections> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.connections.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      child: Column(
        children: [
          // Header with expand/collapse
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Row(
                children: [
                  Icon(
                    Icons.link,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Card Connections',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${widget.connections.length}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ],
              ),
            ),
          ),

          // Expandable content
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.defaultPadding,
                0,
                AppConstants.defaultPadding,
                AppConstants.defaultPadding,
              ),
              child: Column(
                children: widget.connections
                    .map(
                      (connection) => _buildConnectionItem(context, connection),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildConnectionItem(BuildContext context, CardConnection connection) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getConnectionColor(context, connection.connectionType),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Connection type and cards
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getConnectionColor(
                    context,
                    connection.connectionType,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  connection.connectionType.displayName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Connected cards
          Text(
            '${connection.card1.card.name} (${connection.card1.positionName}) ↔ ${connection.card2.card.name} (${connection.card2.positionName})',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.outline,
            ),
          ),

          const SizedBox(height: 4),

          // Connection description
          Text(
            connection.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Color _getConnectionColor(BuildContext context, ConnectionType type) {
    switch (type) {
      case ConnectionType.suit:
        return Colors.blue;
      case ConnectionType.majorArcana:
        return Colors.purple;
      case ConnectionType.reversed:
        return Colors.orange;
      case ConnectionType.thematic:
        return Colors.green;
    }
  }
}
