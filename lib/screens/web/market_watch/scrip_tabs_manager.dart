import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mynt_plus/models/marketwatch_model/get_quotes.dart';
// import 'scrip_depth_info_web.dart';
import 'chart_with_depth_web.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/res/global_state_text.dart';
import 'package:mynt_plus/res/web_colors.dart';
import 'package:mynt_plus/res/global_font_web.dart';
import 'package:mynt_plus/provider/thems.dart';

class ScripTabsManager extends ConsumerStatefulWidget {
  const ScripTabsManager({super.key});

  @override
  ConsumerState<ScripTabsManager> createState() => _ScripTabsManagerState();
}

class _ScripTabsManagerState extends ConsumerState<ScripTabsManager>
    with TickerProviderStateMixin {
  late TabController _tabController;
  VoidCallback? _tabControllerListener; // Store listener reference for proper cleanup

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 0, vsync: this);
    
    // Store listener reference for proper cleanup
    _tabControllerListener = () {
      if (_tabController.indexIsChanging && mounted) {
        ref.read(scripTabsProvider.notifier).setCurrentTabIndex(_tabController.index);
      }
    };
    _tabController.addListener(_tabControllerListener!);
  }

  @override
  void dispose() {
    // Remove listener before disposing to prevent memory leaks
    if (_tabControllerListener != null) {
      _tabController.removeListener(_tabControllerListener!);
      _tabControllerListener = null;
    }
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Listen to provider state changes and update tab controller
    final scripTabsState = ref.watch(scripTabsProvider);
    _updateTabController(scripTabsState);
  }

  @override
  void didUpdateWidget(ScripTabsManager oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Force update when widget updates
    final scripTabsState = ref.watch(scripTabsProvider);
    _updateTabController(scripTabsState);
  }

  void _updateTabController(ScripTabsState state) {
    // Check for range errors and empty state
    if (state.openScrips.isEmpty) return;
    
    // Ensure currentTabIndex is within bounds
    int safeCurrentIndex = state.currentTabIndex;
    if (safeCurrentIndex >= state.openScrips.length) {
      safeCurrentIndex = state.openScrips.length - 1;
    }
    if (safeCurrentIndex < 0) {
      safeCurrentIndex = 0;
    }
    
    if (_tabController.length != state.openScrips.length) {
      // Remove old listener before disposing to prevent memory leaks
      if (_tabControllerListener != null) {
        _tabController.removeListener(_tabControllerListener!);
        _tabControllerListener = null;
      }
      _tabController.dispose();
      _tabController = TabController(
        length: state.openScrips.length,
        vsync: this,
        initialIndex: safeCurrentIndex,
      );
      
      // Store listener reference for proper cleanup
      _tabControllerListener = () {
        if (_tabController.indexIsChanging && mounted) {
          ref.read(scripTabsProvider.notifier).setCurrentTabIndex(_tabController.index);
        }
      };
      _tabController.addListener(_tabControllerListener!);
      
      // Force immediate update after creating new controller
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {});
        }
      });
    } else if (_tabController.index != safeCurrentIndex) {
      // Immediately update the tab index for immediate response
      if (mounted && 
          safeCurrentIndex < state.openScrips.length && 
          _tabController.index != safeCurrentIndex) {
        // Use immediate update instead of animation for better responsiveness
        _tabController.index = safeCurrentIndex;
      }
    }
  }

  void addScrip(DepthInputArgs scripData) {
    ref.read(scripTabsProvider.notifier).addScrip(scripData);
  }

  void removeScrip(int index) {
    ref.read(scripTabsProvider.notifier).removeScrip(index);
  }

  void closeAllScrips() {
    ref.read(scripTabsProvider.notifier).closeAllScrips();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final scripTabsState = ref.watch(scripTabsProvider);
    
    // Listen to state changes for immediate updates
    ref.listen(scripTabsProvider, (previous, next) {
      if (mounted && previous != next) {
        _updateTabController(next);
      }
    });
    
    if (scripTabsState.openScrips.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.trending_up,
                size: 64,
                color: theme.isDarkMode 
                    ? colors.textSecondaryDark 
                    : colors.textSecondaryLight,
              ),
              const SizedBox(height: 16),
                TextWidget.titleText(
                text: 'Select a scrip from the watchlist to view details',
                theme: theme.isDarkMode,
                color: theme.isDarkMode 
                    ? colors.textSecondaryDark 
                    : colors.textSecondaryLight,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Tab bar
        Container(
          decoration: const BoxDecoration(
            // color: theme.isDarkMode 
            //     ? WebDarkColors.surfaceVariant 
            //     : WebColors.surfaceVariant,
            // border: Border(
            //   bottom: BorderSide(
            //     color: theme.isDarkMode 
            //         ? WebDarkColors.border
            //         : WebColors.border,
            //     width: 1,
            //   ),
            // ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  indicatorColor: theme.isDarkMode 
                      ? WebDarkColors.primary 
                      : WebColors.primary,
                  labelColor: theme.isDarkMode 
                      ? WebDarkColors.textPrimary 
                      : WebColors.textPrimary,
                  unselectedLabelColor: theme.isDarkMode 
                      ? WebDarkColors.textSecondary 
                      : WebColors.textSecondary,
                  onTap: (index) {
                    ref.read(scripTabsProvider.notifier).setCurrentTabIndex(index);
                  },
                  tabs: scripTabsState.openScrips.map((scrip) {
                    return Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            scrip.symbol,
                            style: WebTextStyles.para(
                              isDarkTheme: theme.isDarkMode,
                              color: theme.isDarkMode 
                                  ? WebDarkColors.textPrimary 
                                  : WebColors.textPrimary,
                              fontWeight: WebFonts.medium,
                              letterSpacing: 0.0,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => removeScrip(scripTabsState.openScrips.indexOf(scrip)),
                            child: Icon(
                              Icons.close,
                              size: 16,
                              color: theme.isDarkMode 
                                  ? WebDarkColors.iconSecondary 
                                  : WebColors.iconSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              // Close all button
              // if (scripTabsState.openScrips.length > 1)
              //   IconButton(
              //     onPressed: closeAllScrips,
              //     icon: Icon(
              //       Icons.close,
              //       color: theme.isDarkMode 
              //           ? WebDarkColors.iconSecondary 
              //           : WebColors.iconSecondary,
              //     ),
              //     tooltip: 'Close all tabs',
              //   ),
            ],
          ),
        ),
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: scripTabsState.openScrips.map((scrip) {
              return ChartWithDepthWeb(
                wlValue: scrip,
                isBasket: '',
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// Provider to manage scrip tabs globally
final scripTabsProvider = StateNotifierProvider<ScripTabsNotifier, ScripTabsState>((ref) {
  return ScripTabsNotifier();
});

class ScripTabsState {
  final List<DepthInputArgs> openScrips;
  final int currentTabIndex;

  ScripTabsState({
    this.openScrips = const [],
    this.currentTabIndex = 0,
  });

  ScripTabsState copyWith({
    List<DepthInputArgs>? openScrips,
    int? currentTabIndex,
  }) {
    return ScripTabsState(
      openScrips: openScrips ?? this.openScrips,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
    );
  }
}

class ScripTabsNotifier extends StateNotifier<ScripTabsState> {
  ScripTabsNotifier() : super(ScripTabsState());

  void addScrip(DepthInputArgs scripData) {
    // Check if scrip already exists
    final existingIndex = state.openScrips.indexWhere(
      (scrip) => scrip.token == scripData.token && scrip.exch == scripData.exch,
    );
    
    if (existingIndex != -1) {
      // Scrip already exists, switch to that tab
      if (existingIndex >= 0 && existingIndex < state.openScrips.length) {
        state = state.copyWith(currentTabIndex: existingIndex);
      }
    } else {
      // Add new scrip
      final newScrips = [...state.openScrips, scripData];
      final newIndex = newScrips.length - 1;
      
      // Ensure the new index is valid
      if (newIndex >= 0 && newIndex < newScrips.length) {
        state = state.copyWith(
          openScrips: newScrips,
          currentTabIndex: newIndex,
        );
      }
    }
  }

  // Check if a scrip already exists
  bool hasScrip(DepthInputArgs scripData) {
    return state.openScrips.any(
      (scrip) => scrip.token == scripData.token && scrip.exch == scripData.exch,
    );
  }

  // Get existing scrip index
  int getScripIndex(DepthInputArgs scripData) {
    return state.openScrips.indexWhere(
      (scrip) => scrip.token == scripData.token && scrip.exch == scripData.exch,
    );
  }

  void removeScrip(int index) {
    if (state.openScrips.length <= 1) return; // Don't remove if only one tab
    if (index < 0 || index >= state.openScrips.length) return; // Invalid index
    
    final newScrips = List<DepthInputArgs>.from(state.openScrips);
    newScrips.removeAt(index);
    
    // Adjust current tab index
    int newCurrentIndex = state.currentTabIndex;
    if (newCurrentIndex >= newScrips.length) {
      newCurrentIndex = newScrips.length - 1;
    }
    if (newCurrentIndex < 0) {
      newCurrentIndex = 0;
    }
    
    state = state.copyWith(
      openScrips: newScrips,
      currentTabIndex: newCurrentIndex,
    );
  }

  void closeAllScrips() {
    state = ScripTabsState();
  }

  void setCurrentTabIndex(int index) {
    if (state.openScrips.isEmpty) return;
    
    // Ensure index is within bounds
    int safeIndex = index;
    if (safeIndex >= state.openScrips.length) {
      safeIndex = state.openScrips.length - 1;
    }
    if (safeIndex < 0) {
      safeIndex = 0;
    }
    
    if (state.currentTabIndex != safeIndex) {
      state = state.copyWith(currentTabIndex: safeIndex);
    }
  }
}
