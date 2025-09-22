import 'dart:io';
import 'package:dio/dio.dart';
import 'package:leafwise/features/plant_community/models/plant_community_models.dart';
import 'package:leafwise/core/services/api_service.dart';
import 'package:leafwise/core/services/storage_service.dart';

class PlantCommunityService {
  final ApiService _apiService;
  final StorageService _storageService;

  PlantCommunityService(this._apiService, this._storageService);

  // Questions
  Future<List<PlantQuestion>> getQuestions({
    int page = 1,
    int limit = 20,
    String? category,
    String? search,
    String? sortBy,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'limit': limit,
        if (category != null) 'category': category,
        if (search != null) 'search': search,
        if (sortBy != null) 'sort_by': sortBy,
      };

      final response = await _apiService.get(
        '/plant-questions',
        queryParameters: queryParams,
      );

      final List<dynamic> questionsJson = response.data['questions'] ?? [];
      return questionsJson.map((json) => PlantQuestion.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load questions: $e');
    }
  }

  Future<PlantQuestion> getQuestion(String questionId) async {
    try {
      final response = await _apiService.get('/plant-questions/$questionId');
      return PlantQuestion.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load question: $e');
    }
  }

  Future<PlantQuestion> createQuestion(
    PlantQuestionRequest request, {
    File? imageFile,
  }) async {
    try {
      String? imageUrl;

      // Upload image if provided
      if (imageFile != null) {
        imageUrl = await _uploadImage(imageFile, 'questions');
      }

      final requestData = {
        ...request.toJson(),
        if (imageUrl != null) 'image_url': imageUrl,
      };

      final response = await _apiService.post(
        '/plant-questions',
        data: requestData,
      );

      return PlantQuestion.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create question: $e');
    }
  }

  Future<PlantQuestion> updateQuestion(
    String questionId,
    PlantQuestionRequest request, {
    File? imageFile,
  }) async {
    try {
      String? imageUrl;

      // Upload image if provided
      if (imageFile != null) {
        imageUrl = await _uploadImage(imageFile, 'questions');
      }

      final requestData = {
        ...request.toJson(),
        if (imageUrl != null) 'image_url': imageUrl,
      };

      final response = await _apiService.put(
        '/plant-questions/$questionId',
        data: requestData,
      );

      return PlantQuestion.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update question: $e');
    }
  }

  Future<void> deleteQuestion(String questionId) async {
    try {
      await _apiService.delete('/plant-questions/$questionId');
    } catch (e) {
      throw Exception('Failed to delete question: $e');
    }
  }

  Future<PlantQuestion> voteQuestion(String questionId, String voteType) async {
    try {
      final response = await _apiService.post(
        '/plant-questions/$questionId/vote',
        data: {'vote_type': voteType},
      );

      return PlantQuestion.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to vote on question: $e');
    }
  }

  Future<PlantQuestion> bookmarkQuestion(String questionId) async {
    try {
      final response = await _apiService.post(
        '/plant-questions/$questionId/bookmark',
      );

      return PlantQuestion.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to bookmark question: $e');
    }
  }

  Future<PlantQuestion> markQuestionSolved(
    String questionId,
    String acceptedAnswerId,
  ) async {
    try {
      final response = await _apiService.post(
        '/plant-questions/$questionId/solve',
        data: {'accepted_answer_id': acceptedAnswerId},
      );

      return PlantQuestion.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to mark question as solved: $e');
    }
  }

  // Answers
  Future<List<PlantAnswer>> getAnswers(
    String questionId, {
    int page = 1,
    int limit = 20,
    String? sortBy,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'limit': limit,
        if (sortBy != null) 'sort_by': sortBy,
      };

      final response = await _apiService.get(
        '/plant-questions/$questionId/answers',
        queryParameters: queryParams,
      );

      final List<dynamic> answersJson = response.data['answers'] ?? [];
      return answersJson.map((json) => PlantAnswer.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load answers: $e');
    }
  }

  Future<PlantAnswer> createAnswer(
    String questionId,
    PlantAnswerRequest request, {
    File? imageFile,
  }) async {
    try {
      String? imageUrl;

      // Upload image if provided
      if (imageFile != null) {
        imageUrl = await _uploadImage(imageFile, 'answers');
      }

      final requestData = {
        ...request.toJson(),
        if (imageUrl != null) 'image_url': imageUrl,
      };

      final response = await _apiService.post(
        '/plant-questions/$questionId/answers',
        data: requestData,
      );

      return PlantAnswer.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create answer: $e');
    }
  }

  Future<PlantAnswer> updateAnswer(
    String answerId,
    PlantAnswerRequest request, {
    File? imageFile,
  }) async {
    try {
      String? imageUrl;

      // Upload image if provided
      if (imageFile != null) {
        imageUrl = await _uploadImage(imageFile, 'answers');
      }

      final requestData = {
        ...request.toJson(),
        if (imageUrl != null) 'image_url': imageUrl,
      };

      final response = await _apiService.put(
        '/plant-answers/$answerId',
        data: requestData,
      );

      return PlantAnswer.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update answer: $e');
    }
  }

  Future<void> deleteAnswer(String answerId) async {
    try {
      await _apiService.delete('/plant-answers/$answerId');
    } catch (e) {
      throw Exception('Failed to delete answer: $e');
    }
  }

  Future<PlantAnswer> voteAnswer(String answerId, String voteType) async {
    try {
      final response = await _apiService.post(
        '/plant-answers/$answerId/vote',
        data: {'vote_type': voteType},
      );

      return PlantAnswer.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to vote on answer: $e');
    }
  }

  // Trades
  Future<List<PlantTrade>> getTrades({
    int page = 1,
    int limit = 20,
    String? tradeType,
    String? location,
    String? search,
    String? sortBy,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'limit': limit,
        if (tradeType != null) 'trade_type': tradeType,
        if (location != null) 'location': location,
        if (search != null) 'search': search,
        if (sortBy != null) 'sort_by': sortBy,
      };

      final response = await _apiService.get(
        '/plant-trades',
        queryParameters: queryParams,
      );

      final List<dynamic> tradesJson = response.data['trades'] ?? [];
      return tradesJson.map((json) => PlantTrade.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load trades: $e');
    }
  }

  Future<PlantTrade> getTrade(String tradeId) async {
    try {
      final response = await _apiService.get('/plant-trades/$tradeId');
      return PlantTrade.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load trade: $e');
    }
  }

  Future<PlantTrade> createTrade(
    PlantTradeRequest request, {
    List<File>? imageFiles,
  }) async {
    try {
      List<String> imageUrls = [];

      // Upload images if provided
      if (imageFiles != null && imageFiles.isNotEmpty) {
        for (final imageFile in imageFiles) {
          final imageUrl = await _uploadImage(imageFile, 'trades');
          imageUrls.add(imageUrl);
        }
      }

      final requestData = {...request.toJson(), 'image_urls': imageUrls};

      final response = await _apiService.post(
        '/plant-trades',
        data: requestData,
      );

      return PlantTrade.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create trade: $e');
    }
  }

  Future<PlantTrade> updateTrade(
    String tradeId,
    PlantTradeRequest request, {
    List<File>? imageFiles,
  }) async {
    try {
      List<String> imageUrls = [];

      // Upload images if provided
      if (imageFiles != null && imageFiles.isNotEmpty) {
        for (final imageFile in imageFiles) {
          final imageUrl = await _uploadImage(imageFile, 'trades');
          imageUrls.add(imageUrl);
        }
      }

      final requestData = {
        ...request.toJson(),
        if (imageUrls.isNotEmpty) 'image_urls': imageUrls,
      };

      final response = await _apiService.put(
        '/plant-trades/$tradeId',
        data: requestData,
      );

      return PlantTrade.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update trade: $e');
    }
  }

  Future<void> deleteTrade(String tradeId) async {
    try {
      await _apiService.delete('/plant-trades/$tradeId');
    } catch (e) {
      throw Exception('Failed to delete trade: $e');
    }
  }

  Future<PlantTrade> bookmarkTrade(String tradeId) async {
    try {
      final response = await _apiService.post(
        '/plant-trades/$tradeId/bookmark',
      );

      return PlantTrade.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to bookmark trade: $e');
    }
  }

  Future<PlantTrade> expressInterest(String tradeId) async {
    try {
      final response = await _apiService.post(
        '/plant-trades/$tradeId/interest',
      );

      return PlantTrade.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to express interest: $e');
    }
  }

  Future<PlantTrade> updateTradeStatus(String tradeId, String status) async {
    try {
      final response = await _apiService.put(
        '/plant-trades/$tradeId/status',
        data: {'status': status},
      );

      return PlantTrade.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update trade status: $e');
    }
  }

  // User's content
  Future<List<PlantQuestion>> getUserQuestions(
    String userId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiService.get(
        '/users/$userId/questions',
        queryParameters: {'page': page, 'limit': limit},
      );

      final List<dynamic> questionsJson = response.data['questions'] ?? [];
      return questionsJson.map((json) => PlantQuestion.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load user questions: $e');
    }
  }

  Future<List<PlantAnswer>> getUserAnswers(
    String userId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiService.get(
        '/users/$userId/answers',
        queryParameters: {'page': page, 'limit': limit},
      );

      final List<dynamic> answersJson = response.data['answers'] ?? [];
      return answersJson.map((json) => PlantAnswer.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load user answers: $e');
    }
  }

  Future<List<PlantTrade>> getUserTrades(
    String userId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiService.get(
        '/users/$userId/trades',
        queryParameters: {'page': page, 'limit': limit},
      );

      final List<dynamic> tradesJson = response.data['trades'] ?? [];
      return tradesJson.map((json) => PlantTrade.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load user trades: $e');
    }
  }

  // Bookmarks
  Future<List<PlantQuestion>> getBookmarkedQuestions({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiService.get(
        '/bookmarks/questions',
        queryParameters: {'page': page, 'limit': limit},
      );

      final List<dynamic> questionsJson = response.data['questions'] ?? [];
      return questionsJson.map((json) => PlantQuestion.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load bookmarked questions: $e');
    }
  }

  Future<List<PlantTrade>> getBookmarkedTrades({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiService.get(
        '/bookmarks/trades',
        queryParameters: {'page': page, 'limit': limit},
      );

      final List<dynamic> tradesJson = response.data['trades'] ?? [];
      return tradesJson.map((json) => PlantTrade.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load bookmarked trades: $e');
    }
  }

  // Helper method for image upload
  Future<String> _uploadImage(File imageFile, String category) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
        'category': category,
      });

      final response = await _apiService.post('/upload/image', data: formData);

      return response.data['url'];
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }
}
