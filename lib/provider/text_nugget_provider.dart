import 'dart:async';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/core/api_export.dart';
import '../locator/locator.dart';
import '../locator/preference.dart';
import '../models/text_nugget_model/text_nugget_model.dart';
import 'core/default_change_notifier.dart';

final textNuggetProvider = ChangeNotifierProvider((ref) => TextNuggetProvider(ref));

class TextNuggetProvider extends DefaultChangeNotifier {
  final api = locator<ApiExporter>();
  final Preferences pref = locator<Preferences>();
  final Ref ref;

  TextNuggetProvider(this.ref);

  List<TextNuggetModel> _textNuggets = [];
  final List<String> _shownTextIds = [];
  final Map<TextNuggetScreenType, List<TextNuggetModel>> _textsByScreen = {};

  List<TextNuggetModel> get textNuggets => _textNuggets;
  List<String> get shownTextIds => _shownTextIds;

  Future<void> loadTextNuggets() async {
    try {
      log('Starting to load text nuggets...');
      toggleLoadingOn(true);
      setErrorMessage('');

      log('Calling API to fetch text nuggets...');
      var response = await api.fetchTextNuggets();

      if (response != null) {
        log('API response received - Success: ${response.success}');

        if (response.success) {
          // Get all text nuggets from all screens
          var allActiveTexts = response.allTexts
              .where((text) => text.shouldDisplay)
              .toList();

          log('Found ${allActiveTexts.length} active text nuggets from all screens');

          // Filter out seen text nuggets
          final userId = pref.clientId ?? '';
          var unseenTexts = allActiveTexts
              .where((text) => !pref.isTextNuggetSeen(userId, text.id))
              .toList();

          log('Filtered to ${unseenTexts.length} unseen text nuggets (${allActiveTexts.length - unseenTexts.length} already seen)');

          _textNuggets = unseenTexts;

          // Group text nuggets by screen
          _groupTextsByScreen();

          log('Text nuggets grouped by screen: ${_textsByScreen.keys}');
          for (var entry in _textsByScreen.entries) {
            log('Screen ${entry.key}: ${entry.value.length} text nuggets');
          }

          log('Successfully loaded ${_textNuggets.length} active text nuggets');
        } else {
          final errorMsg = response.message ?? 'API returned success=false';
          setErrorMessage(errorMsg);
          log('API returned failure: $errorMsg');
        }
      } else {
        const errorMsg = 'API response was null';
        setErrorMessage(errorMsg);
        log(errorMsg);
      }
    } catch (e, stackTrace) {
      final errorMsg = 'Exception loading text nuggets: $e';
      setErrorMessage(errorMsg);
      log(errorMsg);
      log('Stack trace: $stackTrace');
    } finally {
      toggleLoadingOn(false);
      log('Text nugget loading finished');
    }
  }

  List<TextNuggetModel> getTextsForScreen(TextNuggetScreenType screenType) {
    return _textsByScreen[screenType] ?? [];
  }

  TextNuggetModel? getNextTextForScreen(TextNuggetScreenType screenType) {
    final screenTexts = getTextsForScreen(screenType);
    final userId = pref.clientId ?? '';

    // Filter out seen text nuggets in real-time
    final unseenTexts = screenTexts
        .where((text) => !pref.isTextNuggetSeen(userId, text.id))
        .toList();

    log('getNextTextForScreen: ${screenTexts.length} total, ${unseenTexts.length} unseen for screen $screenType');

    // Return the first unseen text nugget
    return unseenTexts.isNotEmpty ? unseenTexts.first : null;
  }

  bool shouldShowText(String textId, TextNuggetScreenType screenType) {
    final userId = pref.clientId ?? '';

    // First check if text is seen
    if (pref.isTextNuggetSeen(userId, textId)) {
      return false;
    }

    // Check if text exists and is active
    final text = _textNuggets.firstWhere(
      (t) => t.id == textId,
      orElse: () => TextNuggetModel(
        id: '',
        content: '',
        screenName: screenType,
        isActive: false,
      ),
    );

    return text.shouldDisplay;
  }

  Future<void> markTextAsShown(String textId) async {
    try {
      final userId = pref.clientId ?? '';

      // Mark as seen locally first (immediate effect)
      await pref.setTextNuggetSeen(userId, textId);
      log('Marked text nugget as seen locally: $textId for user: $userId');

      // Add to shown list for current session
      if (!_shownTextIds.contains(textId)) {
        _shownTextIds.add(textId);
      }

      // Call API to mark as seen on backend
      final success = await api.markTextNuggetSeen(textId: textId);

      if (success) {
        log('Successfully marked text nugget as seen on backend: $textId');
      } else {
        log('Failed to mark text nugget as seen on backend: $textId (local tracking still active)');
      }

      // Trigger UI rebuild so text widgets can update immediately
      notifyListeners();
    } catch (e) {
      log('Error marking text nugget as shown: $e');
    }
  }

  Future<void> refreshTextNuggets() async {
    await loadTextNuggets();
  }

  void clearShownTexts() {
    _shownTextIds.clear();
    notifyListeners();
  }

  // Seen text management methods
  Future<void> clearSeenTexts() async {
    final userId = pref.clientId ?? '';
    await pref.clearSeenTextNuggets(userId);
    log('Cleared seen text nuggets for user: $userId');
    // Reload text nuggets to show previously seen ones
    await loadTextNuggets();
  }

  Future<List<String>> getSeenTextIds() async {
    final userId = pref.clientId ?? '';
    return await pref.getSeenTextNuggetIds(userId);
  }

  // Logout cleanup method
  Future<void> onUserLogout() async {
    try {
      final userId = pref.clientId ?? '';

      // Clear seen text nuggets for the logging out user
      await pref.clearSeenTextNuggets(userId);
      log('Cleared seen text nuggets for logged out user: $userId');

      // Clear current session data
      _textNuggets.clear();
      _shownTextIds.clear();
      _textsByScreen.clear();

      log('Cleared text nugget provider session data on logout');
      notifyListeners();
    } catch (e) {
      log('Error during text nugget logout cleanup: $e');
    }
  }

  // Private methods
  void _groupTextsByScreen() {
    _textsByScreen.clear();

    for (final text in _textNuggets) {
      if (!_textsByScreen.containsKey(text.screenName)) {
        _textsByScreen[text.screenName] = [];
      }
      _textsByScreen[text.screenName]!.add(text);
    }
  }
}
