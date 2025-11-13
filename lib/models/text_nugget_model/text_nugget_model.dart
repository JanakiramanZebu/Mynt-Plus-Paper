class TextNuggetModel {
  final String id;
  final String content;
  final TextNuggetScreenType screenName;
  final bool isActive;
  final String? actionUrl;

  TextNuggetModel({
    required this.id,
    required this.content,
    required this.screenName,
    required this.isActive,
    this.actionUrl,
  });

  factory TextNuggetModel.fromJson(Map<String, dynamic> json) {
    return TextNuggetModel(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      screenName: TextNuggetScreenType.fromString(json['screen_name'] ?? ''),
      isActive: json['is_active'] ?? false,
      actionUrl: json['action_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'screen_name': screenName.value,
      'is_active': isActive,
      'action_url': actionUrl,
    };
  }

  bool get shouldDisplay {
    return isActive;
  }

  TextNuggetModel copyWith({
    String? id,
    String? content,
    TextNuggetScreenType? screenName,
    bool? isActive,
    String? actionUrl,
  }) {
    return TextNuggetModel(
      id: id ?? this.id,
      content: content ?? this.content,
      screenName: screenName ?? this.screenName,
      isActive: isActive ?? this.isActive,
      actionUrl: actionUrl ?? this.actionUrl,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TextNuggetModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

enum TextNuggetScreenType {
  homescreen('homescreen'),
  holdings('holdings'),
  positions('positions'),
  watchlist('watchlist'),
  optionchain('optionchain');

  const TextNuggetScreenType(this.value);
  final String value;

  static TextNuggetScreenType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'homescreen':
      case 'home':
        return TextNuggetScreenType.homescreen;
      case 'holdings':
        return TextNuggetScreenType.holdings;
      case 'positions':
        return TextNuggetScreenType.positions;
      case 'watchlist':
        return TextNuggetScreenType.watchlist;
      case 'optionchain':
      case 'option_chain':
        return TextNuggetScreenType.optionchain;
      default:
        return TextNuggetScreenType.homescreen;
    }
  }
}

class ScreenTextNuggets {
  final List<TextNuggetModel> texts;
  final int count;

  ScreenTextNuggets({
    required this.texts,
    required this.count,
  });

  factory ScreenTextNuggets.fromJson(Map<String, dynamic> json) {
    return ScreenTextNuggets(
      texts: (json['texts'] as List<dynamic>?)
              ?.map((text) => TextNuggetModel.fromJson(text))
              .toList() ??
          [],
      count: json['count'] ?? 0,
    );
  }
}

class TextNuggetResponse {
  final Map<String, ScreenTextNuggets> screens;
  final bool success;
  final String? message;

  TextNuggetResponse({
    required this.screens,
    required this.success,
    this.message,
  });

  factory TextNuggetResponse.fromJson(Map<String, dynamic> json) {
    Map<String, ScreenTextNuggets> screensMap = {};

    if (json['screens'] != null) {
      final screens = json['screens'] as Map<String, dynamic>;
      screens.forEach((screenName, screenData) {
        screensMap[screenName] = ScreenTextNuggets.fromJson(screenData);
      });
    }

    return TextNuggetResponse(
      screens: screensMap,
      success: json['success'] ?? false,
      message: json['message'],
    );
  }

  // Helper method to get text nuggets for a specific screen
  List<TextNuggetModel> getTextsForScreen(String screenName) {
    return screens[screenName]?.texts ?? [];
  }

  // Helper method to get all text nuggets from all screens
  List<TextNuggetModel> get allTexts {
    List<TextNuggetModel> all = [];
    for (final screenTexts in screens.values) {
      all.addAll(screenTexts.texts);
    }
    return all;
  }
}
