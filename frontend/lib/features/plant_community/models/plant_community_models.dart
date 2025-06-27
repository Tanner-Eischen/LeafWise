import 'package:json_annotation/json_annotation.dart';

part 'plant_community_models.g.dart';

@JsonSerializable()
class PlantQuestion {
  final String id;
  final String userId;
  final String title;
  final String content;
  final String? imageUrl;
  final String? plantSpeciesId;
  final List<String> tags;
  final int upvotes;
  final int downvotes;
  final int answerCount;
  final bool isSolved;
  final String? acceptedAnswerId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  // User info
  final String? userDisplayName;
  final String? userAvatarUrl;
  
  // Plant species info
  final String? speciesCommonName;
  final String? speciesScientificName;
  
  // User interaction
  final String? userVote; // 'up', 'down', or null
  final bool isBookmarked;

  const PlantQuestion({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    this.imageUrl,
    this.plantSpeciesId,
    this.tags = const [],
    this.upvotes = 0,
    this.downvotes = 0,
    this.answerCount = 0,
    this.isSolved = false,
    this.acceptedAnswerId,
    required this.createdAt,
    this.updatedAt,
    this.userDisplayName,
    this.userAvatarUrl,
    this.speciesCommonName,
    this.speciesScientificName,
    this.userVote,
    this.isBookmarked = false,
  });

  factory PlantQuestion.fromJson(Map<String, dynamic> json) {
    return PlantQuestion(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      imageUrl: json['imageUrl'] as String?,
      plantSpeciesId: json['plantSpeciesId'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      upvotes: json['upvotes'] as int? ?? 0,
      downvotes: json['downvotes'] as int? ?? 0,
      answerCount: json['answerCount'] as int? ?? 0,
      isSolved: json['isSolved'] as bool? ?? false,
      acceptedAnswerId: json['acceptedAnswerId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
      userDisplayName: json['userDisplayName'] as String?,
      userAvatarUrl: json['userAvatarUrl'] as String?,
      speciesCommonName: json['speciesCommonName'] as String?,
      speciesScientificName: json['speciesScientificName'] as String?,
      userVote: json['userVote'] as String?,
      isBookmarked: json['isBookmarked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'plantSpeciesId': plantSpeciesId,
      'tags': tags,
      'upvotes': upvotes,
      'downvotes': downvotes,
      'answerCount': answerCount,
      'isSolved': isSolved,
      'acceptedAnswerId': acceptedAnswerId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'userDisplayName': userDisplayName,
      'userAvatarUrl': userAvatarUrl,
      'speciesCommonName': speciesCommonName,
      'speciesScientificName': speciesScientificName,
      'userVote': userVote,
      'isBookmarked': isBookmarked,
    };
  }

  PlantQuestion copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    String? imageUrl,
    String? plantSpeciesId,
    List<String>? tags,
    int? upvotes,
    int? downvotes,
    int? answerCount,
    bool? isSolved,
    String? acceptedAnswerId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userDisplayName,
    String? userAvatarUrl,
    String? speciesCommonName,
    String? speciesScientificName,
    String? userVote,
    bool? isBookmarked,
  }) {
    return PlantQuestion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      plantSpeciesId: plantSpeciesId ?? this.plantSpeciesId,
      tags: tags ?? this.tags,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      answerCount: answerCount ?? this.answerCount,
      isSolved: isSolved ?? this.isSolved,
      acceptedAnswerId: acceptedAnswerId ?? this.acceptedAnswerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userDisplayName: userDisplayName ?? this.userDisplayName,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      speciesCommonName: speciesCommonName ?? this.speciesCommonName,
      speciesScientificName: speciesScientificName ?? this.speciesScientificName,
      userVote: userVote ?? this.userVote,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
}

@JsonSerializable()
class PlantAnswer {
  final String id;
  final String questionId;
  final String userId;
  final String content;
  final String? imageUrl;
  final int upvotes;
  final int downvotes;
  final bool isAccepted;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  // User info
  final String? userDisplayName;
  final String? userAvatarUrl;
  
  // User interaction
  final String? userVote; // 'up', 'down', or null

  const PlantAnswer({
    required this.id,
    required this.questionId,
    required this.userId,
    required this.content,
    this.imageUrl,
    this.upvotes = 0,
    this.downvotes = 0,
    this.isAccepted = false,
    required this.createdAt,
    this.updatedAt,
    this.userDisplayName,
    this.userAvatarUrl,
    this.userVote,
  });

  factory PlantAnswer.fromJson(Map<String, dynamic> json) {
    return PlantAnswer(
      id: json['id'] as String,
      questionId: json['questionId'] as String,
      userId: json['userId'] as String,
      content: json['content'] as String,
      imageUrl: json['imageUrl'] as String?,
      upvotes: json['upvotes'] as int? ?? 0,
      downvotes: json['downvotes'] as int? ?? 0,
      isAccepted: json['isAccepted'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
      userDisplayName: json['userDisplayName'] as String?,
      userAvatarUrl: json['userAvatarUrl'] as String?,
      userVote: json['userVote'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionId': questionId,
      'userId': userId,
      'content': content,
      'imageUrl': imageUrl,
      'upvotes': upvotes,
      'downvotes': downvotes,
      'isAccepted': isAccepted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'userDisplayName': userDisplayName,
      'userAvatarUrl': userAvatarUrl,
      'userVote': userVote,
    };
  }
}

@JsonSerializable()
class PlantTrade {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String tradeType; // 'trade', 'sell', 'give_away'
  final String? price;
  final List<String> imageUrls;
  final String location;
  final String? plantSpeciesId;
  final List<String> tags;
  final String status; // 'active', 'completed', 'cancelled'
  final int viewCount;
  final int interestedCount;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  // User info
  final String? userDisplayName;
  final String? userAvatarUrl;
  
  // Plant species info
  final String? speciesCommonName;
  final String? speciesScientificName;
  
  // User interaction
  final bool isBookmarked;
  final bool hasExpressedInterest;

  const PlantTrade({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.tradeType,
    this.price,
    this.imageUrls = const [],
    required this.location,
    this.plantSpeciesId,
    this.tags = const [],
    this.status = 'active',
    this.viewCount = 0,
    this.interestedCount = 0,
    required this.createdAt,
    this.updatedAt,
    this.userDisplayName,
    this.userAvatarUrl,
    this.speciesCommonName,
    this.speciesScientificName,
    this.isBookmarked = false,
    this.hasExpressedInterest = false,
  });

  factory PlantTrade.fromJson(Map<String, dynamic> json) {
    return PlantTrade(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      tradeType: json['tradeType'] as String,
      price: json['price'] as String?,
      imageUrls: (json['imageUrls'] as List<dynamic>?)?.cast<String>() ?? [],
      location: json['location'] as String,
      plantSpeciesId: json['plantSpeciesId'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      status: json['status'] as String? ?? 'active',
      viewCount: json['viewCount'] as int? ?? 0,
      interestedCount: json['interestedCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
      userDisplayName: json['userDisplayName'] as String?,
      userAvatarUrl: json['userAvatarUrl'] as String?,
      speciesCommonName: json['speciesCommonName'] as String?,
      speciesScientificName: json['speciesScientificName'] as String?,
      isBookmarked: json['isBookmarked'] as bool? ?? false,
      hasExpressedInterest: json['hasExpressedInterest'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'tradeType': tradeType,
      'price': price,
      'imageUrls': imageUrls,
      'location': location,
      'plantSpeciesId': plantSpeciesId,
      'tags': tags,
      'status': status,
      'viewCount': viewCount,
      'interestedCount': interestedCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'userDisplayName': userDisplayName,
      'userAvatarUrl': userAvatarUrl,
      'speciesCommonName': speciesCommonName,
      'speciesScientificName': speciesScientificName,
      'isBookmarked': isBookmarked,
      'hasExpressedInterest': hasExpressedInterest,
    };
  }
}

@JsonSerializable()
class PlantQuestionRequest {
  final String title;
  final String content;
  final String? imageUrl;
  final String? plantSpeciesId;
  final List<String> tags;

  const PlantQuestionRequest({
    required this.title,
    required this.content,
    this.imageUrl,
    this.plantSpeciesId,
    this.tags = const [],
  });

  factory PlantQuestionRequest.fromJson(Map<String, dynamic> json) {
    return PlantQuestionRequest(
      title: json['title'] as String,
      content: json['content'] as String,
      imageUrl: json['imageUrl'] as String?,
      plantSpeciesId: json['plantSpeciesId'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'plantSpeciesId': plantSpeciesId,
      'tags': tags,
    };
  }
}

@JsonSerializable()
class PlantAnswerRequest {
  final String content;
  final String? imageUrl;

  const PlantAnswerRequest({
    required this.content,
    this.imageUrl,
  });

  factory PlantAnswerRequest.fromJson(Map<String, dynamic> json) {
    return PlantAnswerRequest(
      content: json['content'] as String,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'imageUrl': imageUrl,
    };
  }
}

@JsonSerializable()
class PlantTradeRequest {
  final String title;
  final String description;
  final String tradeType;
  final String? price;
  final List<String> imageUrls;
  final String location;
  final String? plantSpeciesId;
  final List<String> tags;

  const PlantTradeRequest({
    required this.title,
    required this.description,
    required this.tradeType,
    this.price,
    this.imageUrls = const [],
    required this.location,
    this.plantSpeciesId,
    this.tags = const [],
  });

  factory PlantTradeRequest.fromJson(Map<String, dynamic> json) {
    return PlantTradeRequest(
      title: json['title'] as String,
      description: json['description'] as String,
      tradeType: json['tradeType'] as String,
      price: json['price'] as String?,
      imageUrls: (json['imageUrls'] as List<dynamic>?)?.cast<String>() ?? [],
      location: json['location'] as String,
      plantSpeciesId: json['plantSpeciesId'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'tradeType': tradeType,
      'price': price,
      'imageUrls': imageUrls,
      'location': location,
      'plantSpeciesId': plantSpeciesId,
      'tags': tags,
    };
  }

  factory PlantTradeRequest.fromJson(Map<String, dynamic> json) =>
      _$PlantTradeRequestFromJson(json);
}

@JsonSerializable()
class PlantCommunityState {
  final bool isLoading;
  final List<PlantQuestion> questions;
  final List<PlantAnswer> answers;
  final List<PlantTrade> trades;
  final String? error;
  
  // Pagination
  final bool hasMoreQuestions;
  final bool hasMoreTrades;
  final int currentQuestionPage;
  final int currentTradePage;
  
  // Filters
  final String? selectedCategory;
  final String? searchQuery;
  final String? sortBy;

  const PlantCommunityState({
    this.isLoading = false,
    this.questions = const [],
    this.answers = const [],
    this.trades = const [],
    this.error,
    this.hasMoreQuestions = false,
    this.hasMoreTrades = false,
    this.currentQuestionPage = 1,
    this.currentTradePage = 1,
    this.selectedCategory,
    this.searchQuery,
    this.sortBy,
  });

  factory PlantCommunityState.fromJson(Map<String, dynamic> json) {
    return PlantCommunityState(
      isLoading: json['isLoading'] as bool? ?? false,
      questions: (json['questions'] as List<dynamic>?)?.map((e) => PlantQuestion.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      answers: (json['answers'] as List<dynamic>?)?.map((e) => PlantAnswer.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      trades: (json['trades'] as List<dynamic>?)?.map((e) => PlantTrade.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      error: json['error'] as String?,
      hasMoreQuestions: json['hasMoreQuestions'] as bool? ?? false,
      hasMoreTrades: json['hasMoreTrades'] as bool? ?? false,
      currentQuestionPage: json['currentQuestionPage'] as int? ?? 1,
      currentTradePage: json['currentTradePage'] as int? ?? 1,
      selectedCategory: json['selectedCategory'] as String?,
      searchQuery: json['searchQuery'] as String?,
      sortBy: json['sortBy'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isLoading': isLoading,
      'questions': questions.map((e) => e.toJson()).toList(),
      'answers': answers.map((e) => e.toJson()).toList(),
      'trades': trades.map((e) => e.toJson()).toList(),
      'error': error,
      'hasMoreQuestions': hasMoreQuestions,
      'hasMoreTrades': hasMoreTrades,
      'currentQuestionPage': currentQuestionPage,
      'currentTradePage': currentTradePage,
      'selectedCategory': selectedCategory,
      'searchQuery': searchQuery,
      'sortBy': sortBy,
    };
  }

  PlantCommunityState copyWith({
    bool? isLoading,
    List<PlantQuestion>? questions,
    List<PlantAnswer>? answers,
    List<PlantTrade>? trades,
    String? error,
    bool? hasMoreQuestions,
    bool? hasMoreTrades,
    int? currentQuestionPage,
    int? currentTradePage,
    String? selectedCategory,
    String? searchQuery,
    String? sortBy,
  }) {
    return PlantCommunityState(
      isLoading: isLoading ?? this.isLoading,
      questions: questions ?? this.questions,
      answers: answers ?? this.answers,
      trades: trades ?? this.trades,
      error: error ?? this.error,
      hasMoreQuestions: hasMoreQuestions ?? this.hasMoreQuestions,
      hasMoreTrades: hasMoreTrades ?? this.hasMoreTrades,
      currentQuestionPage: currentQuestionPage ?? this.currentQuestionPage,
      currentTradePage: currentTradePage ?? this.currentTradePage,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
    );
  }
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