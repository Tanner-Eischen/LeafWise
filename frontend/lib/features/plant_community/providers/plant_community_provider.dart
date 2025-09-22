import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leafwise/features/plant_community/models/plant_community_models.dart';
import 'package:leafwise/features/plant_community/services/plant_community_service.dart';
import 'package:leafwise/core/providers/api_provider.dart';
import 'package:leafwise/core/providers/storage_provider.dart';

// Service provider
final plantCommunityServiceProvider = Provider<PlantCommunityService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final storageService = ref.watch(storageServiceProvider);
  return PlantCommunityService(apiService, storageService);
});

// State notifier for plant community
class PlantCommunityNotifier extends StateNotifier<PlantCommunityState> {
  final PlantCommunityService _service;

  PlantCommunityNotifier(this._service) : super(const PlantCommunityState());

  // Questions
  Future<void> loadQuestions({
    bool refresh = false,
    String? category,
    String? search,
    String? sortBy,
  }) async {
    if (refresh) {
      state = state.copyWith(
        currentQuestionPage: 1,
        questions: [],
        hasMoreQuestions: true,
      );
    }

    if (state.isLoading) return;

    state = state.copyWith(
      isLoading: true,
      error: null,
      selectedCategory: category,
      searchQuery: search,
      sortBy: sortBy,
    );

    try {
      final questions = await _service.getQuestions(
        page: state.currentQuestionPage,
        category: category,
        search: search,
        sortBy: sortBy,
      );

      final updatedQuestions = refresh
          ? questions
          : [...state.questions, ...questions];

      state = state.copyWith(
        isLoading: false,
        questions: updatedQuestions,
        hasMoreQuestions: questions.length >= 20,
        currentQuestionPage: state.currentQuestionPage + 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<PlantQuestion?> getQuestion(String questionId) async {
    try {
      return await _service.getQuestion(questionId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<PlantQuestion?> createQuestion(
    PlantQuestionRequest request, {
    File? imageFile,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final question = await _service.createQuestion(
        request,
        imageFile: imageFile,
      );

      // Add to the beginning of the list
      state = state.copyWith(
        isLoading: false,
        questions: [question, ...state.questions],
      );

      return question;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  Future<PlantQuestion?> updateQuestion(
    String questionId,
    PlantQuestionRequest request, {
    File? imageFile,
  }) async {
    try {
      final updatedQuestion = await _service.updateQuestion(
        questionId,
        request,
        imageFile: imageFile,
      );

      // Update in the list
      final updatedQuestions = state.questions.map((q) {
        return q.id == questionId ? updatedQuestion : q;
      }).toList();

      state = state.copyWith(questions: updatedQuestions);
      return updatedQuestion;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<bool> deleteQuestion(String questionId) async {
    try {
      await _service.deleteQuestion(questionId);

      // Remove from the list
      final updatedQuestions = state.questions
          .where((q) => q.id != questionId)
          .toList();

      state = state.copyWith(questions: updatedQuestions);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<void> voteQuestion(String questionId, String voteType) async {
    try {
      final updatedQuestion = await _service.voteQuestion(questionId, voteType);

      // Update in the list
      final updatedQuestions = state.questions.map((q) {
        return q.id == questionId ? updatedQuestion : q;
      }).toList();

      state = state.copyWith(questions: updatedQuestions);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> bookmarkQuestion(String questionId) async {
    try {
      final updatedQuestion = await _service.bookmarkQuestion(questionId);

      // Update in the list
      final updatedQuestions = state.questions.map((q) {
        return q.id == questionId ? updatedQuestion : q;
      }).toList();

      state = state.copyWith(questions: updatedQuestions);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> markQuestionSolved(
    String questionId,
    String acceptedAnswerId,
  ) async {
    try {
      final updatedQuestion = await _service.markQuestionSolved(
        questionId,
        acceptedAnswerId,
      );

      // Update in the list
      final updatedQuestions = state.questions.map((q) {
        return q.id == questionId ? updatedQuestion : q;
      }).toList();

      state = state.copyWith(questions: updatedQuestions);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Answers
  Future<List<PlantAnswer>?> getAnswers(
    String questionId, {
    String? sortBy,
  }) async {
    try {
      return await _service.getAnswers(questionId, sortBy: sortBy);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<PlantAnswer?> createAnswer(
    String questionId,
    PlantAnswerRequest request, {
    File? imageFile,
  }) async {
    try {
      final answer = await _service.createAnswer(
        questionId,
        request,
        imageFile: imageFile,
      );

      // Update question answer count
      final updatedQuestions = state.questions.map((q) {
        if (q.id == questionId) {
          return q.copyWith(answerCount: q.answerCount + 1);
        }
        return q;
      }).toList();

      state = state.copyWith(questions: updatedQuestions);
      return answer;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<PlantAnswer?> updateAnswer(
    String answerId,
    PlantAnswerRequest request, {
    File? imageFile,
  }) async {
    try {
      return await _service.updateAnswer(
        answerId,
        request,
        imageFile: imageFile,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<bool> deleteAnswer(String answerId, String questionId) async {
    try {
      await _service.deleteAnswer(answerId);

      // Update question answer count
      final updatedQuestions = state.questions.map((q) {
        if (q.id == questionId) {
          return q.copyWith(answerCount: q.answerCount - 1);
        }
        return q;
      }).toList();

      state = state.copyWith(questions: updatedQuestions);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<PlantAnswer?> voteAnswer(String answerId, String voteType) async {
    try {
      return await _service.voteAnswer(answerId, voteType);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  // Trades
  Future<void> loadTrades({
    bool refresh = false,
    String? tradeType,
    String? location,
    String? search,
    String? sortBy,
  }) async {
    if (refresh) {
      state = state.copyWith(
        currentTradePage: 1,
        trades: [],
        hasMoreTrades: true,
      );
    }

    if (state.isLoading) return;

    state = state.copyWith(
      isLoading: true,
      error: null,
      searchQuery: search,
      sortBy: sortBy,
    );

    try {
      final trades = await _service.getTrades(
        page: state.currentTradePage,
        tradeType: tradeType,
        location: location,
        search: search,
        sortBy: sortBy,
      );

      final updatedTrades = refresh ? trades : [...state.trades, ...trades];

      state = state.copyWith(
        isLoading: false,
        trades: updatedTrades,
        hasMoreTrades: trades.length >= 20,
        currentTradePage: state.currentTradePage + 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<PlantTrade?> getTrade(String tradeId) async {
    try {
      return await _service.getTrade(tradeId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<PlantTrade?> createTrade(
    PlantTradeRequest request, {
    List<File>? imageFiles,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final trade = await _service.createTrade(request, imageFiles: imageFiles);

      // Add to the beginning of the list
      state = state.copyWith(
        isLoading: false,
        trades: [trade, ...state.trades],
      );

      return trade;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  Future<PlantTrade?> updateTrade(
    String tradeId,
    PlantTradeRequest request, {
    List<File>? imageFiles,
  }) async {
    try {
      final updatedTrade = await _service.updateTrade(
        tradeId,
        request,
        imageFiles: imageFiles,
      );

      // Update in the list
      final updatedTrades = state.trades.map((t) {
        return t.id == tradeId ? updatedTrade : t;
      }).toList();

      state = state.copyWith(trades: updatedTrades);
      return updatedTrade;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<bool> deleteTrade(String tradeId) async {
    try {
      await _service.deleteTrade(tradeId);

      // Remove from the list
      final updatedTrades = state.trades.where((t) => t.id != tradeId).toList();

      state = state.copyWith(trades: updatedTrades);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<void> bookmarkTrade(String tradeId) async {
    try {
      final updatedTrade = await _service.bookmarkTrade(tradeId);

      // Update in the list
      final updatedTrades = state.trades.map((t) {
        return t.id == tradeId ? updatedTrade : t;
      }).toList();

      state = state.copyWith(trades: updatedTrades);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> expressInterest(String tradeId) async {
    try {
      final updatedTrade = await _service.expressInterest(tradeId);

      // Update in the list
      final updatedTrades = state.trades.map((t) {
        return t.id == tradeId ? updatedTrade : t;
      }).toList();

      state = state.copyWith(trades: updatedTrades);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateTradeStatus(String tradeId, String status) async {
    try {
      final updatedTrade = await _service.updateTradeStatus(tradeId, status);

      // Update in the list
      final updatedTrades = state.trades.map((t) {
        return t.id == tradeId ? updatedTrade : t;
      }).toList();

      state = state.copyWith(trades: updatedTrades);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Clear state
  void clearState() {
    state = const PlantCommunityState();
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Main provider
final plantCommunityProvider =
    StateNotifierProvider<PlantCommunityNotifier, PlantCommunityState>((ref) {
      final service = ref.watch(plantCommunityServiceProvider);
      return PlantCommunityNotifier(service);
    });

// Individual providers for specific use cases
final questionsProvider = Provider<List<PlantQuestion>>((ref) {
  return ref.watch(plantCommunityProvider).questions;
});

final tradesProvider = Provider<List<PlantTrade>>((ref) {
  return ref.watch(plantCommunityProvider).trades;
});

final questionProvider = FutureProvider.family<PlantQuestion?, String>((
  ref,
  questionId,
) async {
  final notifier = ref.read(plantCommunityProvider.notifier);
  return await notifier.getQuestion(questionId);
});

final tradeProvider = FutureProvider.family<PlantTrade?, String>((
  ref,
  tradeId,
) async {
  final notifier = ref.read(plantCommunityProvider.notifier);
  return await notifier.getTrade(tradeId);
});

final answersProvider = FutureProvider.family<List<PlantAnswer>?, String>((
  ref,
  questionId,
) async {
  final notifier = ref.read(plantCommunityProvider.notifier);
  return await notifier.getAnswers(questionId);
});

// User content providers
final userQuestionsProvider =
    FutureProvider.family<List<PlantQuestion>, String>((ref, userId) async {
      final service = ref.watch(plantCommunityServiceProvider);
      return await service.getUserQuestions(userId);
    });

final userAnswersProvider = FutureProvider.family<List<PlantAnswer>, String>((
  ref,
  userId,
) async {
  final service = ref.watch(plantCommunityServiceProvider);
  return await service.getUserAnswers(userId);
});

final userTradesProvider = FutureProvider.family<List<PlantTrade>, String>((
  ref,
  userId,
) async {
  final service = ref.watch(plantCommunityServiceProvider);
  return await service.getUserTrades(userId);
});

// Bookmark providers
final bookmarkedQuestionsProvider = FutureProvider<List<PlantQuestion>>((
  ref,
) async {
  final service = ref.watch(plantCommunityServiceProvider);
  return await service.getBookmarkedQuestions();
});

final bookmarkedTradesProvider = FutureProvider<List<PlantTrade>>((ref) async {
  final service = ref.watch(plantCommunityServiceProvider);
  return await service.getBookmarkedTrades();
});
