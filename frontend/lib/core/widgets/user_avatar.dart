import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String username;
  final double size;
  final VoidCallback? onTap;
  final bool showOnlineIndicator;
  final bool isOnline;
  final Color? backgroundColor;
  final Color? textColor;
  final Widget? badge;

  const UserAvatar({
    super.key,
    this.imageUrl,
    required this.username,
    this.size = 40,
    this.onTap,
    this.showOnlineIndicator = false,
    this.isOnline = false,
    this.backgroundColor,
    this.textColor,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ?? _getBackgroundColor(username),
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: _buildAvatarContent(theme),
      ),
    );

    // Add online indicator if needed
    if (showOnlineIndicator) {
      avatar = Stack(
        children: [
          avatar,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: size * 0.25,
              height: size * 0.25,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isOnline ? Colors.green : Colors.grey,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Add badge if provided
    if (badge != null) {
      avatar = Stack(
        children: [
          avatar,
          Positioned(
            right: -2,
            top: -2,
            child: badge!,
          ),
        ],
      );
    }

    // Make tappable if onTap is provided
    if (onTap != null) {
      avatar = GestureDetector(
        onTap: onTap,
        child: avatar,
      );
    }

    return avatar;
  }

  Widget _buildAvatarContent(ThemeData theme) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildInitialsAvatar(theme);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: size,
            height: size,
            color: Colors.grey[200],
            child: Center(
              child: SizedBox(
                width: size * 0.4,
                height: size * 0.4,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.primaryColor,
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    return _buildInitialsAvatar(theme);
  }

  Widget _buildInitialsAvatar(ThemeData theme) {
    final initials = _getInitials(username);
    final fontSize = size * 0.4;
    
    return Container(
      width: size,
      height: size,
      color: backgroundColor ?? _getBackgroundColor(username),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: textColor ?? Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    
    final words = name.trim().split(' ');
    if (words.length == 1) {
      return words[0].substring(0, 1).toUpperCase();
    }
    
    return (words[0].substring(0, 1) + words[1].substring(0, 1)).toUpperCase();
  }

  Color _getBackgroundColor(String name) {
    // Generate a consistent color based on the username
    final colors = [
      Colors.red[400]!,
      Colors.pink[400]!,
      Colors.purple[400]!,
      Colors.deepPurple[400]!,
      Colors.indigo[400]!,
      Colors.blue[400]!,
      Colors.lightBlue[400]!,
      Colors.cyan[400]!,
      Colors.teal[400]!,
      Colors.green[400]!,
      Colors.lightGreen[400]!,
      Colors.lime[400]!,
      Colors.yellow[400]!,
      Colors.amber[400]!,
      Colors.orange[400]!,
      Colors.deepOrange[400]!,
    ];
    
    final hash = name.hashCode;
    return colors[hash.abs() % colors.length];
  }
}

// Helper widget for creating avatar groups
class AvatarGroup extends StatelessWidget {
  final List<String> usernames;
  final List<String?> imageUrls;
  final double size;
  final int maxVisible;
  final VoidCallback? onTap;

  const AvatarGroup({
    super.key,
    required this.usernames,
    this.imageUrls = const [],
    this.size = 32,
    this.maxVisible = 3,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visibleCount = usernames.length > maxVisible ? maxVisible : usernames.length;
    final remainingCount = usernames.length - maxVisible;
    
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size + (visibleCount - 1) * (size * 0.7),
        height: size,
        child: Stack(
          children: [
            // Visible avatars
            ...List.generate(visibleCount, (index) {
              final username = usernames[index];
              final imageUrl = index < imageUrls.length ? imageUrls[index] : null;
              
              return Positioned(
                left: index * (size * 0.7),
                child: UserAvatar(
                  username: username,
                  imageUrl: imageUrl,
                  size: size,
                ),
              );
            }),
            
            // Remaining count indicator
            if (remainingCount > 0)
              Positioned(
                left: visibleCount * (size * 0.7),
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[600],
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '+$remainingCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: size * 0.3,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}