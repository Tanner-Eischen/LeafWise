import 'package:freezed_annotation/freezed_annotation.dart';

part 'plant_community_models.freezed.dart';
part 'plant_community_models.g.dart';

@freezed
class PlantQuestion with _$PlantQuestion {
  const factory PlantQuestion({
    required String id,
    required String userId,
    required String title,
    required String content,
    String? imageUrl,
    String? plantSpeciesId,
    @Default([]) List<String> tags,
    @Default(0) int upvotes,
    @Default(0) int downvotes,
    @Default(0) int answerCount,
    @Default(false) bool isSolved,
    String? acceptedAnswerId,
    required DateTime createdAt,
    DateTime? updatedAt,
    
    // User info
    String? userDisplayName,
    String? userAvatarUrl,
    
    // Plant species info
    String? speciesCommonName,
    String? speciesScientificName,
    
    // User interaction
    String? userVote, // 'up', 'down', or null
    @Default(false) bool isBookmarked,
  }) = _PlantQuestion;

  factory PlantQuestion.fromJson(Map<String, dynamic> json) =>
      _$PlantQuestionFromJson(json);
}

@freezed
class PlantAnswer with _$PlantAnswer {
  const factory PlantAnswer({
    required String id,
    required String questionId,
    required String userId,
    required String content,
    String? imageUrl,
    @Default(0) int upvotes,
    @Default(0) int downvotes,
    @Default(false) bool isAccepted,
    required DateTime createdAt,
    DateTime? updatedAt,
    
    // User info
    String? userDisplayName,
    String? userAvatarUrl,
    
    // User interaction
    String? userVote, // 'up', 'down', or null
  }) = _PlantAnswer;

  factory PlantAnswer.fromJson(Map<String, dynamic> json) =>
      _$PlantAnswerFromJson(json);
}

@freezed
class PlantTrade with _$PlantTrade {
  const factory PlantTrade({
    required String id,
    required String userId,
    required String title,
    required String description,
    required String tradeType, // 'trade', 'sell', 'give_away'
    String? price,
    @Default([]) List<String> imageUrls,
    required String location,
    String? plantSpeciesId,
    @Default([]) List<String> tags,
    @Default('active') String status, // 'active', 'completed', 'cancelled'
    @Default(0) int viewCount,
    @Default(0) int interestedCount,
    required DateTime createdAt,
    DateTime? updatedAt,
    
    // User info
    String? userDisplayName,
    String? userAvatarUrl,
    
    // Plant species info
    String? speciesCommonName,
    String? speciesScientificName,
    
    // User interaction
    @Default(false) bool isBookmarked,
    @Default(false) bool hasExpressedInterest,
  }) = _PlantTrade;

  factory PlantTrade.fromJson(Map<String, dynamic> json) =>
      _$PlantTradeFromJson(json);
}

@freezed
class PlantQuestionRequest with _$PlantQuestionRequest {
  const factory PlantQuestionRequest({
    required String title,
    required String content,
    String? imageUrl,
    String? plantSpeciesId,
    @Default([]) List<String> tags,
  }) = _PlantQuestionRequest;

  factory PlantQuestionRequest.fromJson(Map<String, dynamic> json) =>
      _$PlantQuestionRequestFromJson(json);
}

@freezed
class PlantAnswerRequest with _$PlantAnswerRequest {
  const factory PlantAnswerRequest({
    required String content,
    String? imageUrl,
  }) = _PlantAnswerRequest;

  factory PlantAnswerRequest.fromJson(Map<String, dynamic> json) =>
      _$PlantAnswerRequestFromJson(json);
}

@freezed
class PlantTradeRequest with _$PlantTradeRequest {
  const factory PlantTradeRequest({
    required String title,
    required String description,
    required String tradeType,
    String? price,
    @Default([]) List<String> imageUrls,
    required String location,
    String? plantSpeciesId,
    @Default([]) List<String> tags,
  }) = _PlantTradeRequest;

  factory PlantTradeRequest.fromJson(Map<String, dynamic> json) =>
      _$PlantTradeRequestFromJson(json);
}

@freezed
class PlantCommunityState with _$PlantCommunityState {
  const factory PlantCommunityState({
    @Default(false) bool isLoading,
    @Default([]) List<PlantQuestion> questions,
    @Default([]) List<PlantAnswer> answers,
    @Default([]) List<PlantTrade> trades,
    String? error,
    
    // Pagination
    @Default(false) bool hasMoreQuestions,
    @Default(false) bool hasMoreTrades,
    @Default(1) int currentQuestionPage,
    @Default(1) int currentTradePage,
    
    // Filters
    String? selectedCategory,
    String? searchQuery,
    String? sortBy,
  }) = _PlantCommunityState;

  factory PlantCommunityState.fromJson(Map<String, dynamic> json) =>
      _$PlantCommunityStateFromJson(json);
}

// Constants
class TradeType {
  static const String trade = 'trade';
  static const String sell = 'sell';
  static const String giveAway = 'give_away';
  
  static const List<String> all = [trade, sell, giveAway];
  
  static String getDisplayName(String type) {
    switch (type) {
      case trade:
        return 'Trade';
      case sell:
        return 'Sell';
      case giveAway:
        return 'Give Away';
      default:
        return type;
    }
  }
}

class QuestionCategory {
  static const String general = 'general';
  static const String care = 'care';
  static const String identification = 'identification';
  static const String pests = 'pests';
  static const String diseases = 'diseases';
  static const String propagation = 'propagation';
  static const String troubleshooting = 'troubleshooting';
  
  static const List<String> all = [
    general,
    care,
    identification,
    pests,
    diseases,
    propagation,
    troubleshooting,
  ];
  
  static String getDisplayName(String category) {
    switch (category) {
      case general:
        return 'General';
      case care:
        return 'Plant Care';
      case identification:
        return 'Plant ID';
      case pests:
        return 'Pests';
      case diseases:
        return 'Diseases';
      case propagation:
        return 'Propagation';
      case troubleshooting:
        return 'Troubleshooting';
      default:
        return category;
    }
  }
  
  static String getIcon(String category) {
    switch (category) {
      case general:
        return '💬';
      case care:
        return '🌱';
      case identification:
        return '🔍';
      case pests:
        return '🐛';
      case diseases:
        return '🦠';
      case propagation:
        return '🌿';
      case troubleshooting:
        return '🔧';
      default:
        return '❓';
    }
  }
}

class SortOption {
  static const String newest = 'newest';
  static const String oldest = 'oldest';
  static const String mostUpvoted = 'most_upvoted';
  static const String mostAnswered = 'most_answered';
  static const String unsolved = 'unsolved';
  
  static const List<String> questionSortOptions = [
    newest,
    oldest,
    mostUpvoted,
    mostAnswered,
    unsolved,
  ];
  
  static const List<String> tradeSortOptions = [
    newest,
    oldest,
  ];
  
  static String getDisplayName(String option) {
    switch (option) {
      case newest:
        return 'Newest';
      case oldest:
        return 'Oldest';
      case mostUpvoted:
        return 'Most Upvoted';
      case mostAnswered:
        return 'Most Answered';
      case unsolved:
        return 'Unsolved';
      default:
        return option;
    }
  }
}