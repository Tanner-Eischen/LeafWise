// Stories API service for backend integration
// Handles all story-related API calls including creation, retrieval, and viewing

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leafwise/core/network/api_client.dart';
import 'package:leafwise/features/stories/data/models/story_model.dart';

/// Service class for handling story-related API operations
class StoriesApiService {
  final ApiClient _apiClient;

  StoriesApiService(this._apiClient);

  /// Get stories for the current user's feed (following users)
  Future<StoriesResponse> getFollowingStories({
    String? cursor,
    int limit = 20,
  }) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/stories/following',
        queryParameters: {
          if (cursor != null) 'cursor': cursor,
          'limit': limit,
        },
      );

      return StoriesResponse.fromJson(response.data!);
    } catch (e) {
      throw _handleApiError(e);
    }
  }

  /// Get explore stories (public stories from all users)
  Future<StoriesResponse> getExploreStories({
    String? cursor,
    int limit = 20,
  }) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/stories/explore',
        queryParameters: {
          if (cursor != null) 'cursor': cursor,
          'limit': limit,
        },
      );

      return StoriesResponse.fromJson(response.data!);
    } catch (e) {
      throw _handleApiError(e);
    }
  }

  /// Get stories by a specific user
  Future<List<Story>> getUserStories(String userId) async {
    try {
      final response = await _apiClient.get<List<dynamic>>(
        '/stories/user/$userId',
      );

      return response.data!
          .map((json) => Story.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw _handleApiError(e);
    }
  }

  /// Get current user's own stories
  Future<List<Story>> getMyStories() async {
    try {
      final response = await _apiClient.get<List<dynamic>>(
        '/stories/me',
      );

      return response.data!
          .map((json) => Story.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw _handleApiError(e);
    }
  }

  /// Create a new story
  Future<Story> createStory(CreateStoryRequest request) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/stories',
        data: request.toJson(),
      );

      return Story.fromJson(response.data!);
    } catch (e) {
      throw _handleApiError(e);
    }
  }

  /// Upload story media file
  Future<String> uploadStoryMedia(String filePath) async {
    try {
      final response = await _apiClient.uploadFile<Map<String, dynamic>>(
        '/stories/upload',
        filePath,
        fileName: filePath.split('/').last,
      );

      return response.data!['url'] as String;
    } catch (e) {
      throw _handleApiError(e);
    }
  }

  /// Mark a story as viewed
  Future<void> viewStory(String storyId) async {
    try {
      await _apiClient.post<void>(
        '/stories/$storyId/view',
      );
    } catch (e) {
      throw _handleApiError(e);
    }
  }

  /// Delete a story (only owner can delete)
  Future<void> deleteStory(String storyId) async {
    try {
      await _apiClient.delete<void>('/stories/$storyId');
    } catch (e) {
      throw _handleApiError(e);
    }
  }

  /// Get story viewers (who viewed the story)
  Future<List<Map<String, dynamic>>> getStoryViewers(String storyId) async {
    try {
      final response = await _apiClient.get<List<dynamic>>(
        '/stories/$storyId/viewers',
      );

      return response.data!
          .map((viewer) => viewer as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw _handleApiError(e);
    }
  }

  /// Get archived stories for current user
  Future<List<Story>> getArchivedStories({
    String? cursor,
    int limit = 20,
  }) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/stories/archived',
        queryParameters: {
          if (cursor != null) 'cursor': cursor,
          'limit': limit,
        },
      );

      final storiesData = response.data!['stories'] as List<dynamic>;
      return storiesData
          .map((json) => Story.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw _handleApiError(e);
    }
  }

  /// Archive a story
  Future<void> archiveStory(String storyId) async {
    try {
      await _apiClient.patch<void>(
        '/stories/$storyId/archive',
      );
    } catch (e) {
      throw _handleApiError(e);
    }
  }

  /// Unarchive a story
  Future<void> unarchiveStory(String storyId) async {
    try {
      await _apiClient.patch<void>(
        '/stories/$storyId/unarchive',
      );
    } catch (e) {
      throw _handleApiError(e);
    }
  }

  /// Handle API errors and convert them to appropriate exceptions
  Exception _handleApiError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return Exception('Connection timeout. Please check your internet connection.');
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final message = error.response?.data?['message'] ?? 'Unknown error occurred';
          
          switch (statusCode) {
            case 400:
              return Exception('Bad request: $message');
            case 401:
              return Exception('Unauthorized. Please log in again.');
            case 403:
              return Exception('Forbidden: $message');
            case 404:
              return Exception('Story not found');
            case 413:
              return Exception('File too large. Please choose a smaller file.');
            case 500:
              return Exception('Server error. Please try again later.');
            default:
              return Exception('Error: $message');
          }
        case DioExceptionType.cancel:
          return Exception('Request was cancelled');
        case DioExceptionType.unknown:
          return Exception('Network error. Please check your connection.');
        default:
          return Exception('An unexpected error occurred');
      }
    }
    return Exception('An unexpected error occurred: $error');
  }
}

/// Provider for StoriesApiService
final storiesApiServiceProvider = Provider<StoriesApiService>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return StoriesApiService(apiClient);
});