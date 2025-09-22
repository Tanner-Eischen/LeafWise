import 'package:flutter/material.dart';
import 'package:leafwise/features/plant_community/models/plant_community_models.dart';
import 'package:leafwise/core/utils/date_utils.dart' as app_date_utils;
import 'package:leafwise/core/widgets/user_avatar.dart';

class TradeCard extends StatelessWidget {
  final PlantTrade trade;
  final VoidCallback? onTap;
  final VoidCallback? onBookmark;
  final VoidCallback? onInterest;
  final bool showFullContent;

  const TradeCard({
    super.key,
    required this.trade,
    this.onTap,
    this.onBookmark,
    this.onInterest,
    this.showFullContent = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with user info and trade type
              _buildHeader(theme),
              const SizedBox(height: 12),

              // Title
              Text(
                trade.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: showFullContent ? null : 2,
                overflow: showFullContent ? null : TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Description preview
              if (trade.description.isNotEmpty)
                Text(
                  trade.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
                  maxLines: showFullContent ? null : 2,
                  overflow: showFullContent ? null : TextOverflow.ellipsis,
                ),
              const SizedBox(height: 12),

              // Plant details
              _buildPlantDetails(theme),
              const SizedBox(height: 12),

              // Images
              if (trade.imageUrls.isNotEmpty) _buildImagePreview(),
              if (trade.imageUrls.isNotEmpty) const SizedBox(height: 12),

              // Footer with location, status, and actions
              _buildFooter(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        // User avatar
        UserAvatar(
          imageUrl: trade.userAvatarUrl,
          username: trade.userDisplayName ?? 'Unknown User',
          size: 32,
        ),
        const SizedBox(width: 12),

        // User info and timestamp
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                trade.userDisplayName ?? 'Unknown User',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                app_date_utils.DateUtils.formatRelativeTime(trade.createdAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),

        // Trade type badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getTradeTypeColor(trade.tradeType).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getTradeTypeColor(trade.tradeType).withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getTradeTypeIcon(trade.tradeType),
                size: 14,
                color: _getTradeTypeColor(trade.tradeType),
              ),
              const SizedBox(width: 4),
              Text(
                TradeType.getDisplayName(trade.tradeType),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _getTradeTypeColor(trade.tradeType),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        // Status indicator
        Container(
          margin: const EdgeInsets.only(left: 8),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: _getStatusColor(trade.status),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _getStatusText(trade.status),
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlantDetails(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plant name
          Row(
            children: [
              Icon(Icons.local_florist, size: 16, color: Colors.green[600]),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  trade.speciesCommonName ?? trade.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.green[700],
                  ),
                ),
              ),
            ],
          ),

          if (trade.speciesScientificName != null &&
              trade.speciesScientificName!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              trade.speciesScientificName!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],

          // What they want (for trade/swap)
          if (trade.tradeType != TradeType.giveAway &&
              trade.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.swap_horiz, size: 16, color: Colors.blue[600]),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Description: ${trade.description}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.blue[700],
                    ),
                  ),
                ),
              ],
            ),
          ],

          // Price (for sale)
          if (trade.tradeType == TradeType.sell && trade.price != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.attach_money, size: 16, color: Colors.orange[600]),
                const SizedBox(width: 6),
                Text(
                  '\$${trade.price}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[700],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    final imageCount = trade.imageUrls.length;
    final displayCount = showFullContent
        ? imageCount
        : (imageCount > 3 ? 3 : imageCount);

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: displayCount,
        itemBuilder: (context, index) {
          final isLast = index == displayCount - 1;
          final hasMore = !showFullContent && imageCount > 3;

          return Container(
            margin: EdgeInsets.only(right: isLast ? 0 : 8),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    trade.imageUrls[index],
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),

                // Show count overlay on last image if there are more
                if (isLast && hasMore)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '+${imageCount - 3}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Row(
      children: [
        // Location
        if (trade.location.isNotEmpty) ...[
          Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              trade.location,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ] else
          const Spacer(),

        // Interest count
        if (trade.interestedCount > 0) ...[
          const SizedBox(width: 12),
          Row(
            children: [
              Icon(Icons.favorite_outline, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                '${trade.interestedCount}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],

        // Action buttons
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Interest button
            if (trade.status == 'active' && onInterest != null)
              IconButton(
                onPressed: onInterest,
                icon: Icon(
                  trade.hasExpressedInterest
                      ? Icons.favorite
                      : Icons.favorite_outline,
                  size: 20,
                  color: trade.hasExpressedInterest
                      ? Colors.red
                      : Colors.grey[600],
                ),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
              ),

            // Bookmark button
            IconButton(
              onPressed: onBookmark,
              icon: Icon(
                trade.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                size: 20,
                color: trade.isBookmarked
                    ? theme.primaryColor
                    : Colors.grey[600],
              ),
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
      ],
    );
  }

  Color _getTradeTypeColor(String tradeType) {
    switch (tradeType) {
      case TradeType.trade:
        return Colors.blue;
      case TradeType.sell:
        return Colors.orange;
      case TradeType.giveAway:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getTradeTypeIcon(String tradeType) {
    switch (tradeType) {
      case TradeType.trade:
        return Icons.swap_horiz;
      case TradeType.sell:
        return Icons.attach_money;
      case TradeType.giveAway:
        return Icons.card_giftcard;
      default:
        return Icons.help_outline;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'active':
        return 'ACTIVE';
      case 'pending':
        return 'PENDING';
      case 'completed':
        return 'DONE';
      case 'cancelled':
        return 'CANCELLED';
      default:
        return status.toUpperCase();
    }
  }
}
