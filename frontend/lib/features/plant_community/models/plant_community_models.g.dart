// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plant_community_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlantQuestion _$PlantQuestionFromJson(Map<String, dynamic> json) =>
    PlantQuestion(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      imageUrl: json['imageUrl'] as String?,
      plantSpeciesId: json['plantSpeciesId'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      upvotes: (json['upvotes'] as num?)?.toInt() ?? 0,
      downvotes: (json['downvotes'] as num?)?.toInt() ?? 0,
      answerCount: (json['answerCount'] as num?)?.toInt() ?? 0,
      isSolved: json['isSolved'] as bool? ?? false,
      acceptedAnswerId: json['acceptedAnswerId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      userDisplayName: json['userDisplayName'] as String?,
      userAvatarUrl: json['userAvatarUrl'] as String?,
      speciesCommonName: json['speciesCommonName'] as String?,
      speciesScientificName: json['speciesScientificName'] as String?,
      userVote: json['userVote'] as String?,
      isBookmarked: json['isBookmarked'] as bool? ?? false,
    );

Map<String, dynamic> _$PlantQuestionToJson(PlantQuestion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'title': instance.title,
      'content': instance.content,
      'imageUrl': instance.imageUrl,
      'plantSpeciesId': instance.plantSpeciesId,
      'tags': instance.tags,
      'upvotes': instance.upvotes,
      'downvotes': instance.downvotes,
      'answerCount': instance.answerCount,
      'isSolved': instance.isSolved,
      'acceptedAnswerId': instance.acceptedAnswerId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'userDisplayName': instance.userDisplayName,
      'userAvatarUrl': instance.userAvatarUrl,
      'speciesCommonName': instance.speciesCommonName,
      'speciesScientificName': instance.speciesScientificName,
      'userVote': instance.userVote,
      'isBookmarked': instance.isBookmarked,
    };

PlantAnswer _$PlantAnswerFromJson(Map<String, dynamic> json) => PlantAnswer(
      id: json['id'] as String,
      questionId: json['questionId'] as String,
      userId: json['userId'] as String,
      content: json['content'] as String,
      imageUrl: json['imageUrl'] as String?,
      upvotes: (json['upvotes'] as num?)?.toInt() ?? 0,
      downvotes: (json['downvotes'] as num?)?.toInt() ?? 0,
      isAccepted: json['isAccepted'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      userDisplayName: json['userDisplayName'] as String?,
      userAvatarUrl: json['userAvatarUrl'] as String?,
      userVote: json['userVote'] as String?,
    );

Map<String, dynamic> _$PlantAnswerToJson(PlantAnswer instance) =>
    <String, dynamic>{
      'id': instance.id,
      'questionId': instance.questionId,
      'userId': instance.userId,
      'content': instance.content,
      'imageUrl': instance.imageUrl,
      'upvotes': instance.upvotes,
      'downvotes': instance.downvotes,
      'isAccepted': instance.isAccepted,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'userDisplayName': instance.userDisplayName,
      'userAvatarUrl': instance.userAvatarUrl,
      'userVote': instance.userVote,
    };

PlantTrade _$PlantTradeFromJson(Map<String, dynamic> json) => PlantTrade(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      tradeType: json['tradeType'] as String,
      price: json['price'] as String?,
      imageUrls: (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      location: json['location'] as String,
      plantSpeciesId: json['plantSpeciesId'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      status: json['status'] as String? ?? 'active',
      viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
      interestedCount: (json['interestedCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      userDisplayName: json['userDisplayName'] as String?,
      userAvatarUrl: json['userAvatarUrl'] as String?,
      speciesCommonName: json['speciesCommonName'] as String?,
      speciesScientificName: json['speciesScientificName'] as String?,
      isBookmarked: json['isBookmarked'] as bool? ?? false,
      hasExpressedInterest: json['hasExpressedInterest'] as bool? ?? false,
    );

Map<String, dynamic> _$PlantTradeToJson(PlantTrade instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'title': instance.title,
      'description': instance.description,
      'tradeType': instance.tradeType,
      'price': instance.price,
      'imageUrls': instance.imageUrls,
      'location': instance.location,
      'plantSpeciesId': instance.plantSpeciesId,
      'tags': instance.tags,
      'status': instance.status,
      'viewCount': instance.viewCount,
      'interestedCount': instance.interestedCount,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'userDisplayName': instance.userDisplayName,
      'userAvatarUrl': instance.userAvatarUrl,
      'speciesCommonName': instance.speciesCommonName,
      'speciesScientificName': instance.speciesScientificName,
      'isBookmarked': instance.isBookmarked,
      'hasExpressedInterest': instance.hasExpressedInterest,
    };

PlantQuestionRequest _$PlantQuestionRequestFromJson(
        Map<String, dynamic> json) =>
    PlantQuestionRequest(
      title: json['title'] as String,
      content: json['content'] as String,
      imageUrl: json['imageUrl'] as String?,
      plantSpeciesId: json['plantSpeciesId'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
    );

Map<String, dynamic> _$PlantQuestionRequestToJson(
        PlantQuestionRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'content': instance.content,
      'imageUrl': instance.imageUrl,
      'plantSpeciesId': instance.plantSpeciesId,
      'tags': instance.tags,
    };

PlantAnswerRequest _$PlantAnswerRequestFromJson(Map<String, dynamic> json) =>
    PlantAnswerRequest(
      content: json['content'] as String,
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$PlantAnswerRequestToJson(PlantAnswerRequest instance) =>
    <String, dynamic>{
      'content': instance.content,
      'imageUrl': instance.imageUrl,
    };

PlantTradeRequest _$PlantTradeRequestFromJson(Map<String, dynamic> json) =>
    PlantTradeRequest(
      title: json['title'] as String,
      description: json['description'] as String,
      tradeType: json['tradeType'] as String,
      price: json['price'] as String?,
      imageUrls: (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      location: json['location'] as String,
      plantSpeciesId: json['plantSpeciesId'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
    );

Map<String, dynamic> _$PlantTradeRequestToJson(PlantTradeRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'tradeType': instance.tradeType,
      'price': instance.price,
      'imageUrls': instance.imageUrls,
      'location': instance.location,
      'plantSpeciesId': instance.plantSpeciesId,
      'tags': instance.tags,
    };

PlantCommunityState _$PlantCommunityStateFromJson(Map<String, dynamic> json) =>
    PlantCommunityState(
      isLoading: json['isLoading'] as bool? ?? false,
      questions: (json['questions'] as List<dynamic>?)
              ?.map((e) => PlantQuestion.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      answers: (json['answers'] as List<dynamic>?)
              ?.map((e) => PlantAnswer.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      trades: (json['trades'] as List<dynamic>?)
              ?.map((e) => PlantTrade.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      error: json['error'] as String?,
      hasMoreQuestions: json['hasMoreQuestions'] as bool? ?? false,
      hasMoreTrades: json['hasMoreTrades'] as bool? ?? false,
      currentQuestionPage: (json['currentQuestionPage'] as num?)?.toInt() ?? 1,
      currentTradePage: (json['currentTradePage'] as num?)?.toInt() ?? 1,
      selectedCategory: json['selectedCategory'] as String?,
      searchQuery: json['searchQuery'] as String?,
      sortBy: json['sortBy'] as String?,
    );

Map<String, dynamic> _$PlantCommunityStateToJson(
        PlantCommunityState instance) =>
    <String, dynamic>{
      'isLoading': instance.isLoading,
      'questions': instance.questions,
      'answers': instance.answers,
      'trades': instance.trades,
      'error': instance.error,
      'hasMoreQuestions': instance.hasMoreQuestions,
      'hasMoreTrades': instance.hasMoreTrades,
      'currentQuestionPage': instance.currentQuestionPage,
      'currentTradePage': instance.currentTradePage,
      'selectedCategory': instance.selectedCategory,
      'searchQuery': instance.searchQuery,
      'sortBy': instance.sortBy,
    };
