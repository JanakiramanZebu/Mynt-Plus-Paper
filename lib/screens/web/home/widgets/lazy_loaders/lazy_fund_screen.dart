import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/provider/fund_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/res/web_colors.dart';
import 'package:mynt_plus/sharedWidget/splash_loader.dart';
import 'package:mynt_plus/screens/web/funds/secure_fund_web.dart';

// Lazy loading wrapper for SecureFundWeb to prevent blocking UI
class LazyFundScreen extends ConsumerStatefulWidget {
  const LazyFundScreen({super.key});

  @override
  ConsumerState<LazyFundScreen> createState() => _LazyFundScreenState();
}

class _LazyFundScreenState extends ConsumerState<LazyFundScreen> {
  bool _shouldLoad = false;

  @override
  void initState() {
    super.initState();
    // Defer widget creation using microtask to allow UI to render first
    Future.microtask(() {
      if (mounted) {
        setState(() {
          _shouldLoad = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final fund = ref.watch(fundProvider);

    // Show loader if widget not loaded yet or if fund data is not available
    if (!_shouldLoad || fund.fundDetailModel == null) {
      return _buildFundLoadingIndicator(theme.isDarkMode);
    }
    return const SecureFundWeb();
  }

  Widget _buildFundLoadingIndicator(bool isDarkMode) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: isDarkMode ? WebDarkColors.background : Colors.white,
      child: const CircularLoaderImage(),
    );
  }
}
