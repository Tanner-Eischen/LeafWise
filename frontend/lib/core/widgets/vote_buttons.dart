import 'package:flutter/material.dart';

enum VoteButtonSize {
  small,
  medium,
  large,
}

class VoteButtons extends StatelessWidget {
  final int upvotes;
  final int downvotes;
  final String? userVote; // 'upvote', 'downvote', or null
  final Function(String)? onVote;
  final VoteButtonSize size;
  final bool showDownvote;
  final bool horizontal;

  const VoteButtons({
    super.key,
    required this.upvotes,
    required this.downvotes,
    this.userVote,
    this.onVote,
    this.size = VoteButtonSize.medium,
    this.showDownvote = true,
    this.horizontal = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dimensions = _getDimensions();

    final upvoteButton = _buildVoteButton(
      icon: Icons.keyboard_arrow_up,
      isSelected: userVote == 'upvote',
      onPressed: () => onVote?.call('upvote'),
      color: Colors.green,
      dimensions: dimensions,
    );

    final scoreText = Text(
      '${upvotes - downvotes}',
      style: TextStyle(
        fontSize: dimensions.fontSize,
        fontWeight: FontWeight.bold,
        color: _getScoreColor(theme),
      ),
    );

    final downvoteButton = showDownvote
        ? _buildVoteButton(
            icon: Icons.keyboard_arrow_down,
            isSelected: userVote == 'downvote',
            onPressed: () => onVote?.call('downvote'),
            color: Colors.red,
            dimensions: dimensions,
          )
        : null;

    if (horizontal) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          upvoteButton,
          SizedBox(width: dimensions.spacing),
          scoreText,
          if (downvoteButton != null) ...[
            SizedBox(width: dimensions.spacing),
            downvoteButton,
          ],
        ],
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          upvoteButton,
          SizedBox(height: dimensions.spacing),
          scoreText,
          if (downvoteButton != null) ...[
            SizedBox(height: dimensions.spacing),
            downvoteButton,
          ],
        ],
      );
    }
  }

  Widget _buildVoteButton({
    required IconData icon,
    required bool isSelected,
    required VoidCallback? onPressed,
    required Color color,
    required _VoteDimensions dimensions,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(dimensions.borderRadius),
      child: Container(
        width: dimensions.buttonSize,
        height: dimensions.buttonSize,
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(dimensions.borderRadius),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: dimensions.iconSize,
          color: isSelected ? color : Colors.grey[600],
        ),
      ),
    );
  }

  Color _getScoreColor(ThemeData theme) {
    final score = upvotes - downvotes;
    if (score > 0) {
      return Colors.green[600]!;
    } else if (score < 0) {
      return Colors.red[600]!;
    } else {
      return Colors.grey[600]!;
    }
  }

  _VoteDimensions _getDimensions() {
    switch (size) {
      case VoteButtonSize.small:
        return _VoteDimensions(
          buttonSize: 28,
          iconSize: 16,
          fontSize: 12,
          spacing: 4,
          borderRadius: 6,
        );
      case VoteButtonSize.medium:
        return _VoteDimensions(
          buttonSize: 36,
          iconSize: 20,
          fontSize: 14,
          spacing: 6,
          borderRadius: 8,
        );
      case VoteButtonSize.large:
        return _VoteDimensions(
          buttonSize: 44,
          iconSize: 24,
          fontSize: 16,
          spacing: 8,
          borderRadius: 10,
        );
    }
  }
}

class _VoteDimensions {
  final double buttonSize;
  final double iconSize;
  final double fontSize;
  final double spacing;
  final double borderRadius;

  const _VoteDimensions({
    required this.buttonSize,
    required this.iconSize,
    required this.fontSize,
    required this.spacing,
    required this.borderRadius,
  });
}

// Simple vote counter widget without buttons
class VoteCounter extends StatelessWidget {
  final int upvotes;
  final int downvotes;
  final VoteButtonSize size;
  final bool showIndividualCounts;

  const VoteCounter({
    super.key,
    required this.upvotes,
    required this.downvotes,
    this.size = VoteButtonSize.medium,
    this.showIndividualCounts = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final score = upvotes - downvotes;
    final fontSize = _getFontSize();

    if (showIndividualCounts) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.keyboard_arrow_up,
            size: fontSize + 2,
            color: Colors.green[600],
          ),
          Text(
            '$upvotes',
            style: TextStyle(
              fontSize: fontSize,
              color: Colors.green[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.keyboard_arrow_down,
            size: fontSize + 2,
            color: Colors.red[600],
          ),
          Text(
            '$downvotes',
            style: TextStyle(
              fontSize: fontSize,
              color: Colors.red[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          score >= 0 ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
          size: fontSize + 2,
          color: score >= 0 ? Colors.green[600] : Colors.red[600],
        ),
        Text(
          score.abs().toString(),
          style: TextStyle(
            fontSize: fontSize,
            color: score >= 0 ? Colors.green[600] : Colors.red[600],
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  double _getFontSize() {
    switch (size) {
      case VoteButtonSize.small:
        return 12;
      case VoteButtonSize.medium:
        return 14;
      case VoteButtonSize.large:
        return 16;
    }
  }
}
