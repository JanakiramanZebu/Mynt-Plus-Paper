import 'package:flutter/material.dart';
import '../models/screen_type.dart';

class ScreenUtils {
  // Get screen title from type
  static String getScreenTitle(ScreenType type) {
    switch (type) {
      case ScreenType.dashboard:
        return 'Dashboard';
      case ScreenType.watchlist:
        return 'Watchlist';
      case ScreenType.holdings:
        return 'Holdings';
      case ScreenType.positions:
        return 'Positions';
      case ScreenType.orderBook:
        return 'Order Book';
      case ScreenType.funds:
        return 'Funds';
      case ScreenType.mutualFund:
        return 'Mutual Fund';
      case ScreenType.ipo:
        return 'IPO';
      case ScreenType.bond:
        return 'Bonds';
      case ScreenType.scripDepthInfo:
        return 'Chart View';
      case ScreenType.optionChain:
        return 'Option Chain';
      case ScreenType.pledgeUnpledge:
        return 'Pledge/Unpledge';
      case ScreenType.corporateActions:
        return 'Corporate Actions';
      case ScreenType.reports:
        return 'Reports';
      case ScreenType.settings:
        return 'Settings';
      case ScreenType.tradeAction:
        return 'Trade Action';
    }
  }

  // Get icon for screen type
  static IconData getIconForScreenType(ScreenType type) {
    switch (type) {
      case ScreenType.dashboard:
        return Icons.dashboard;
      case ScreenType.watchlist:
        return Icons.list;
      case ScreenType.holdings:
        return Icons.inventory;
      case ScreenType.positions:
        return Icons.trending_up;
      case ScreenType.orderBook:
        return Icons.receipt;
      case ScreenType.funds:
        return Icons.account_balance;
      case ScreenType.mutualFund:
        return Icons.trending_up;
      case ScreenType.ipo:
        return Icons.public;
      case ScreenType.bond:
        return Icons.account_balance;
      case ScreenType.scripDepthInfo:
        return Icons.analytics;
      case ScreenType.optionChain:
        return Icons.table_chart;
      case ScreenType.pledgeUnpledge:
        return Icons.security;
      case ScreenType.corporateActions:
        return Icons.business;
      case ScreenType.reports:
        return Icons.assessment;
      case ScreenType.settings:
        return Icons.settings;
      case ScreenType.tradeAction:
        return Icons.trending_up;
    }
  }

  // Get screen title with null safety
  static String getScreenTitleNullable(ScreenType? type) {
    if (type == null) return 'Empty';
    return getScreenTitle(type);
  }

  // Get icon with null safety
  static IconData getIconForScreenTypeNullable(ScreenType? type) {
    if (type == null) return Icons.add;
    return getIconForScreenType(type);
  }
}
