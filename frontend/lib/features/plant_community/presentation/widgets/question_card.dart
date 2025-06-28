import 'package:flutter/material.dart';
import 'package:plant_social/features/plant_community/models/plant_community_models.dart';
import 'package:plant_social/core/theme/app_theme.dart';
import 'package:plant_social/core/utils/date_utils.dart' as AppDateUtils;
import 'package:plant_social/core/widgets/user_avatar.dart';
import 'package:plant_social/core/widgets/vote_buttons.dart';

class QuestionCard extends StatelessWidget {
  final PlantQuestion question;
  final VoidCallback? onTap;
  final Function(String)? onVote;
  final VoidCallback? onBookmark;
  final bool showFullContent;

  const QuestionCard({
    super.key,
    required this.question,
    this.onTap,
    this.onVote,
    this.onBookmark,
    this.showFullContent = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with user info and status
              _buildHeader(theme),
              const SizedBox(height: 12),

              // Title
              Text(
                question.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: showFullContent ? null : 2,
                overflow: showFullContent ? null : TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Content preview
              if (question.content.isNotEmpty)
                Text(
                  question.content,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
                  maxLines: showFullContent ? null : 3,
                  overflow: showFullContent ? null : TextOverflow.ellipsis,
                ),
              const SizedBox(height: 12),

              // Tags
              if (question.tags.isNotEmpty) _buildTags(theme),
              const SizedBox(height: 12),

              // Images preview
              if (question.imageUrl != null) _buildImagePreview(),
              if (question.imageUrl != null) const SizedBox(height: 12),

              // Footer with stats and actions
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
          imageUrl: question.userAvatarUrl,
          username: question.userDisplayName ?? 'Anonymous',
          size: 32,
        ),
        const SizedBox(width: 12),

        // User info and timestamp
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                question.userDisplayName ?? 'Anonymous',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                AppDateUtils.DateUtils.formatRelativeTime(question.createdAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),

        // Category badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getCategoryColor(question.category).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getCategoryColor(question.category).withOpacity(0.3),
            ),
          ),
          child: Text(
            QuestionCategory.getDisplayName(question.category),
            style: theme.textTheme.bodySmall?.copyWith(
              color: _getCategoryColor(question.category),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Solved indicator
        if (question.isSolved)
          Container(
            margin: const EdgeInsets.only(left: 8),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.check,
              size: 16,
              color: Colors.white,
            ),
          ),
      ],
    );
  }

  Widget _buildTags(ThemeData theme) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: question.tags.take(showFullContent ? question.tags.length : 3).map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '#$tag',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildImagePreview() {
    if (question.imageUrl == null) return const SizedBox.shrink();
    
    return Container(
      height: 80,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          question.imageUrl!,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 80,
              height: 80,
              color: Colors.grey[200],
              child: const Icon(
                Icons.image_not_supported,
                color: Colors.grey,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Row(
      children: [
        // Vote buttons
        VoteButtons(
          upvotes: question.upvotes,
          downvotes: question.downvotes,
          userVote: question.userVote,
          onVote: onVote,
          size: VoteButtonSize.small,
        ),
        const SizedBox(width: 16),

        // Answer count
        Row(
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              '${question.answerCount}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),

        // View count
        Row(
          children: [
            Icon(
              Icons.visibility_outlined,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              '${question.views}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),

        const Spacer(),

        // Bookmark button
        IconButton(
          onPressed: onBookmark,
          icon: Icon(
            question.isBookmarked
                ? Icons.bookmark
                : Icons.bookmark_border,
            size: 20,
            color: question.isBookmarked
                ? theme.primaryColor
                : Colors.grey[600],
          ),
          constraints: const BoxConstraints(
            minWidth: 32,
            minHeight: 32,
          ),
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case QuestionCategory.identification:
        return Colors.blue;
      case QuestionCategory.care:
        return Colors.green;
      case QuestionCategory.diseases:
        return Colors.red;
      case QuestionCategory.pests:
        return Colors.orange;
      case QuestionCategory.propagation:
        return Colors.purple;
      case QuestionCategory.general:
      default:
        return Colors.grey;
    }
  }
}