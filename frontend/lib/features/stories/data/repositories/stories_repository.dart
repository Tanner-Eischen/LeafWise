// Stories repository for data management and state handling
// Provides a clean interface between UI and API service with caching and error handling

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leafwise/features/stories/data/models/story_model.dart';
import 'package:leafwise/features/stories/data/services/stories_api_service.dart';

/// Repository class for managing story data operations
class StoriesRepository {
  final StoriesApiService _apiService;

  StoriesRepository(this._apiService);

  /// Get stories for following users with caching
  Future<StoriesResponse> getFollowingStories({
    String? cursor,
    int limit = 20,
  }) async {
    try {
      return await _apiService.getFollowingStories(
        cursor: cursor,
        limit: limit,
      );
    } catch (e) {
      throw _handleRepositoryError(e);
    }
  }

  /// Get explore stories with caching
  Future<StoriesResponse> getExploreStories({
    String? cursor,
    int limit = 20,
  }) async {
    try {
      return await _apiService.getExploreStories(
        cursor: cursor,
        limit: limit,
      );
    } catch (e) {
      throw _handleRepositoryError(e);
    }
  }

  /// Get stories by user ID
  Future<List<Story>> getUserStories(String userId) async {
    try {
      return await _apiService.getUserStories(userId);
    } catch (e) {
      throw _handleRepositoryError(e);
    }
  }

  /// Get current user's stories
  Future<List<Story>> getMyStories() async {
    try {
      return await _apiService.getMyStories();
    } catch (e) {
      throw _handleRepositoryError(e);
    }
  }

  /// Create a new story with media upload
  Future<Story> createStory({
    required String filePath,
    required String mediaType,
    String? caption,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // First upload the media file
      final mediaUrl = await _apiService.uploadStoryMedia(filePath);

      // Then create the story with the uploaded media URL
      final request = CreateStoryRequest(
        mediaUrl: mediaUrl,
        mediaType: mediaType,
        caption: caption,
        metadata: metadata,
      );

      return await _apiService.createStory(request);
    } catch (e) {
      throw _handleRepositoryError(e);
    }
  }

  /// Mark story as viewed
  Future<void> viewStory(String storyId) async {
    try {
      await _apiService.viewStory(storyId);
    } catch (e) {
      throw _handleRepositoryError(e);
    }
  }

  /// Delete a story
  Future<void> deleteStory(String storyId) async {
    try {
      await _apiService.deleteStory(storyId);
    } catch (e) {
      throw _handleRepositoryError(e);
    }
  }

  /// Get story viewers
  Future<List<Map<String, dynamic>>> getStoryViewers(String storyId) async {
    try {
      return await _apiService.getStoryViewers(storyId);
    } catch (e) {
      throw _handleRepositoryError(e);
    }
  }

  /// Get archived stories
  Future<List<Story>> getArchivedStories({
    String? cursor,
    int limit = 20,
  }) async {
    try {
      return await _apiService.getArchivedStories(
        cursor: cursor,
        limit: limit,
      );
    } catch (e) {
      throw _handleRepositoryError(e);
    }
  }

  /// Archive a story
  Future<void> archiveStory(String storyId) async {
    try {
      await _apiService.archiveStory(storyId);
    } catch (e) {
      throw _handleRepositoryError(e);
    }
  }

  /// Unarchive a story
  Future<void> unarchiveStory(String storyId) async {
    try {
      await _apiService.unarchiveStory(storyId);
    } catch (e) {
      throw _handleRepositoryError(e);
    }
  }

  /// Group stories by user for better UI organization
  List<UserStoriesGroup> groupStoriesByUser(List<Story> stories) {
    final Map<String, List<Story>> groupedStories = {};

    for (final story in stories) {
      if (!groupedStories.containsKey(story.userId)) {
        groupedStories[story.userId] = [];
      }
      groupedStories[story.userId]!.add(story);
    }

    return groupedStories.entries.map((entry) {
      final userStories = entry.value;
      userStories.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      final hasUnviewedStories = userStories.any((story) => !story.isViewed);
      final lastStoryTime = userStories.isNotEmpty 
          ? userStories.first.createdAt 
          : null;

      return UserStoriesGroup(
        userId: entry.key,
        username: userStories.first.username,
        userProfilePicture: userStories.first.userProfilePicture,
        stories: userStories,
        hasUnviewedStories: hasUnviewedStories,
        lastStoryTime: lastStoryTime,
      );
    }).toList()
      ..sort((a, b) {
        // Sort by unviewed stories first, then by last story time
        if (a.hasUnviewedStories && !b.hasUnviewedStories) return -1;
        if (!a.hasUnviewedStories && b.hasUnviewedStories) return 1;
        
        if (a.lastStoryTime != null && b.lastStoryTime != null) {
          return b.lastStoryTime!.compareTo(a.lastStoryTime!);
        }
        
        return 0;
      });
  }

  /// Handle repository errors
  Exception _handleRepositoryError(dynamic error) {
    if (error is Exception) {
      return error;
    }
    return Exception('Repository error: $error');
  }
}

/// Provider for StoriesRepository
final storiesRepositoryProvider = Provider<StoriesRepository>((ref) {
  final apiService = ref.read(storiesApiServiceProvider);
  return StoriesRepository(apiService);
});

/// State notifier for managing stories state
class StoriesNotifier extends StateNotifier<AsyncValue<List<UserStoriesGroup>>> {
  final StoriesRepository _repository;
  
  StoriesNotifier(this._repository) : super(const AsyncValue.loading());

  /// Load following stories
  Future<void> loadFollowingStories({bool refresh = false}) async {
    if (refresh) {
      state = const AsyncValue.loading();
    }

    try {
      final response = await _repository.getFollowingStories();
      final groupedStories = _repository.groupStoriesByUser(response.stories);
      state = AsyncValue.data(groupedStories);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Load explore stories
  Future<void> loadExploreStories({bool refresh = false}) async {
    if (refresh) {
      state = const AsyncValue.loading();
    }

    try {
      final response = await _repository.getExploreStories();
      final groupedStories = _repository.groupStoriesByUser(response.stories);
      state = AsyncValue.data(groupedStories);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Mark story as viewed and update state
  Future<void> viewStory(String storyId) async {
    try {
      await _repository.viewStory(storyId);
      
      // Update local state to mark story as viewed
      state.whenData((groups) {
        final updatedGroups = groups.map((group) {
          final updatedStories = group.stories.map((story) {
            if (story.id == storyId) {
              return story.copyWith(isViewed: true);
            }
            return story;
          }).toList();

          final hasUnviewedStories = updatedStories.any((story) => !story.isViewed);

          return group.copyWith(
            stories: updatedStories,
            hasUnviewedStories: hasUnviewedStories,
          );
        }).toList();

        state = AsyncValue.data(updatedGroups);
      });
    } catch (error, stackTrace) {
      // Handle error but don't update state for view operations
      print('Error viewing story: $error');
    }
  }
}

/// Provider for following stories state
final followingStoriesProvider = StateNotifierProvider<StoriesNotifier, AsyncValue<List<UserStoriesGroup>>>((ref) {
  final repository = ref.read(storiesRepositoryProvider);
  return StoriesNotifier(repository);
});

/// Provider for explore stories state
final exploreStoriesProvider = StateNotifierProvider<StoriesNotifier, AsyncValue<List<UserStoriesGroup>>>((ref) {
  final repository = ref.read(storiesRepositoryProvider);
  return StoriesNotifier(repository);
});