import 'screen_type.dart';

// Panel configuration class
class PanelConfig {
  final String id;
  ScreenType? screenType; // Allow null for empty slots
  List<ScreenType> screens; // Multiple screens for tabbed interface
  int activeScreenIndex; // Index of currently active screen
  double width; // As percentage of screen width (0.0 to 1.0)
  double height; // As percentage of screen height (0.0 to 1.0)
  bool isVisible;

  // Resize constraints
  double minWidth; // Minimum width in pixels
  double minHeight; // Minimum height in pixels
  double maxWidth; // Maximum width in pixels
  double maxHeight; // Maximum height in pixels

  // Current actual size in pixels
  double currentWidth;
  double currentHeight;

  // Resize capabilities
  bool enableHorizontalResize;
  bool enableVerticalResize;

  PanelConfig({
    required this.id,
    this.screenType,
    this.screens = const [],
    this.activeScreenIndex = 0,
    required this.width,
    required this.height,
    this.isVisible = true,
    this.minWidth = 150.0,
    this.minHeight = 150.0,
    this.maxWidth = double.infinity,
    this.maxHeight = double.infinity,
    this.currentWidth = 0.0,
    this.currentHeight = 0.0,
    this.enableHorizontalResize = true,
    this.enableVerticalResize = true,
  });

  PanelConfig copyWith({
    String? id,
    ScreenType? screenType,
    List<ScreenType>? screens,
    int? activeScreenIndex,
    double? width,
    double? height,
    bool? isVisible,
    double? minWidth,
    double? minHeight,
    double? maxWidth,
    double? maxHeight,
    double? currentWidth,
    double? currentHeight,
    bool? enableHorizontalResize,
    bool? enableVerticalResize,
  }) {
    return PanelConfig(
      id: id ?? this.id,
      screenType: screenType ?? this.screenType,
      screens: screens ?? this.screens,
      activeScreenIndex: activeScreenIndex ?? this.activeScreenIndex,
      width: width ?? this.width,
      height: height ?? this.height,
      isVisible: isVisible ?? this.isVisible,
      minWidth: minWidth ?? this.minWidth,
      minHeight: minHeight ?? this.minHeight,
      maxWidth: maxWidth ?? this.maxWidth,
      maxHeight: maxHeight ?? this.maxHeight,
      currentWidth: currentWidth ?? this.currentWidth,
      currentHeight: currentHeight ?? this.currentHeight,
      enableHorizontalResize:
          enableHorizontalResize ?? this.enableHorizontalResize,
      enableVerticalResize: enableVerticalResize ?? this.enableVerticalResize,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'screenType': screenType?.name,
      'screens': screens.map((s) => s.name).toList(),
      'activeScreenIndex': activeScreenIndex,
      'width': width,
      'height': height,
      'isVisible': isVisible,
      'minWidth': minWidth,
      'minHeight': minHeight,
      'maxWidth': maxWidth.isFinite
          ? maxWidth
          : 999999.0, // Convert infinity to a large number
      'maxHeight': maxHeight.isFinite
          ? maxHeight
          : 999999.0, // Convert infinity to a large number
      'currentWidth': currentWidth,
      'currentHeight': currentHeight,
      'enableHorizontalResize': enableHorizontalResize,
      'enableVerticalResize': enableVerticalResize,
    };
  }

  factory PanelConfig.fromJson(Map<String, dynamic> json) {
    return PanelConfig(
      id: json['id'],
      screenType: json['screenType'] != null
          ? ScreenType.values.firstWhere((e) => e.name == json['screenType'])
          : null,
      screens: (json['screens'] as List<dynamic>? ?? [])
          .map((s) => ScreenType.values.firstWhere((e) => e.name == s))
          .toList(),
      activeScreenIndex: json['activeScreenIndex'] ?? 0,
      width: json['width'].toDouble(),
      height: json['height']?.toDouble() ?? 0.5,
      isVisible: json['isVisible'] ?? true,
      minWidth: json['minWidth']?.toDouble() ?? 150.0,
      minHeight: json['minHeight']?.toDouble() ?? 150.0,
      maxWidth: (json['maxWidth']?.toDouble() ?? 999999.0) >= 999999.0
          ? double.infinity
          : json['maxWidth']?.toDouble() ?? double.infinity,
      maxHeight: (json['maxHeight']?.toDouble() ?? 999999.0) >= 999999.0
          ? double.infinity
          : json['maxHeight']?.toDouble() ?? double.infinity,
      currentWidth: json['currentWidth']?.toDouble() ?? 0.0,
      currentHeight: json['currentHeight']?.toDouble() ?? 0.0,
      enableHorizontalResize: json['enableHorizontalResize'] ?? true,
      enableVerticalResize: json['enableVerticalResize'] ?? true,
    );
  }
}
