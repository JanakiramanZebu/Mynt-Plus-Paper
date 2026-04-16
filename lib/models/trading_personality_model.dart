import 'package:flutter/material.dart';

enum TradingPersonalityType {
  inferno,
  tsunami,
  quake,
  cyclone,
  blizzard,
  ember,
  volt,
  stonewall,
  aurora,
  meteor,
  tornado,
  crystal,
  shadow,
  nova,
  eclipse,
}

class TradingPersonality {
  final TradingPersonalityType type;
  final String name;
  final String emoji;
  final String description;
  final String tradingStyle;
  final Color primaryColor;
  final Color secondaryColor;
  final String riskLevel; // Low, Medium, High, Extreme
  final String timeHorizon; // Short-term, Medium-term, Long-term

  const TradingPersonality({
    required this.type,
    required this.name,
    required this.emoji,
    required this.description,
    required this.tradingStyle,
    required this.primaryColor,
    required this.secondaryColor,
    required this.riskLevel,
    required this.timeHorizon,
  });
}

class TradingPersonalities {
  static const List<TradingPersonality> personalities = [
    // High-Energy Traders
 TradingPersonality(
  type: TradingPersonalityType.inferno,
  name: 'Comet',
  emoji: '☄️',
  description: 'A blazing force in the market, thrives in volatility and strikes fast.',
  tradingStyle: 'Aggressive scalping with high volatility',
  primaryColor: Color(0xFF7F00FF), // deep violet
  secondaryColor: Color(0xFFFF5F6D), // neon pink/orange glow
  riskLevel: 'Extreme',
  timeHorizon: 'Ultra Short-term',
),


    TradingPersonality(
      type: TradingPersonalityType.tsunami,
      name: 'Tsunami',
      emoji: '🌊',
      description: 'Momentum trader, rides big waves',
      tradingStyle: 'Momentum trading, riding market waves',
      primaryColor: Color(0xFF1E90FF),
      secondaryColor: Color(0xFF87CEEB),
      riskLevel: 'High',
      timeHorizon: 'Short-term',
    ),
   TradingPersonality(
  type: TradingPersonalityType.volt,
  name: 'Volt',
  emoji: '⚡',
  description: 'Sharp and explosive, thrives on sudden breakouts.',
  tradingStyle: 'Breakout strategy with fast entries',
  primaryColor: Color(0xFF0066FF), // electric blue
  secondaryColor: Color(0xFF33CCFF), // cyan glow
  riskLevel: 'High',
  timeHorizon: 'Short-term',
),

    TradingPersonality(
      type: TradingPersonalityType.meteor,
      name: 'shooting star',
      emoji: '🌠',
      description: 'Fast, impact trades',
      tradingStyle: 'Fast impact trading for quick gains',
      primaryColor: Color(0xFF8B4513),
      secondaryColor: Color(0xFFCD853F),
      riskLevel: 'Extreme',
      timeHorizon: 'Short-term',
    ),
    TradingPersonality(
      type: TradingPersonalityType.tornado,
      name: 'Tornado',
      emoji: '🌀',
      description: 'Chaotic, risk-taker',
      tradingStyle: 'Chaotic trading with high risk tolerance',
      primaryColor: Color(0xFF9370DB),
      secondaryColor: Color(0xFFDDA0DD),
      riskLevel: 'Extreme',
      timeHorizon: 'Short-term',
    ),
    TradingPersonality(
      type: TradingPersonalityType.nova,
      name: 'Nova',
      emoji: '🌟',
      description: 'Explosive, big event trader',
      tradingStyle: 'Event-driven trading for explosive moves',
      primaryColor: Color(0xFFFF69B4),
      secondaryColor: Color(0xFFFFB6C1),
      riskLevel: 'High',
      timeHorizon: 'Medium-term',
    ),

    // Strategic Traders
    TradingPersonality(
      type: TradingPersonalityType.quake,
      name: 'Quake',
      emoji: '🌍',
      description: 'Disruptive, contrarian trader',
      tradingStyle: 'Contrarian trading, disrupting market norms',
      primaryColor: Color(0xFF8B4513),
      secondaryColor: Color(0xFFA0522D),
      riskLevel: 'High',
      timeHorizon: 'Medium-term',
    ),
    TradingPersonality(
      type: TradingPersonalityType.cyclone,
      name: 'Cyclone',
      emoji: '🌪️',
      description: 'Quick in & out, whirlwind scalper',
      tradingStyle: 'Quick in-and-out scalping strategy',
      primaryColor: Color(0xFF708090),
      secondaryColor: Color(0xFFB0C4DE),
      riskLevel: 'High',
      timeHorizon: 'Short-term',
    ),
    TradingPersonality(
      type: TradingPersonalityType.shadow,
      name: 'Shadow',
      emoji: '🌑',
      description: 'Stealthy, low-profile contrarian',
      tradingStyle: 'Stealthy contrarian with low profile',
      primaryColor: Color(0xFF2F4F4F),
      secondaryColor: Color(0xFF708090),
      riskLevel: 'Medium',
      timeHorizon: 'Medium-term',
    ),
    TradingPersonality(
      type: TradingPersonalityType.eclipse,
      name: 'Eclipse',
      emoji: '🌒',
      description: 'Hidden moves, surprise entries',
      tradingStyle: 'Hidden moves with surprise entries',
      primaryColor: Color(0xFF483D8B),
      secondaryColor: Color(0xFF9370DB),
      riskLevel: 'Medium',
      timeHorizon: 'Medium-term',
    ),

    // Patient Traders
 TradingPersonality(
  type: TradingPersonalityType.blizzard,
  name: 'Blizzard',
  emoji: '❄️',
  description: 'Calm, patient, and steady in the market’s storms.',
  tradingStyle: 'Long-term, low-volatility strategies',
  primaryColor: Color(0xFF0099CC), // stronger icy blue
  secondaryColor: Color(0xFF00FFFF), // bright cyan glow
  riskLevel: 'Low',
  timeHorizon: 'Long-term',
),
   TradingPersonality(
  type: TradingPersonalityType.ember,
  name: 'Ember',
  emoji: '🪵',
  description: 'Slow and steady, building strength over time.',
  tradingStyle: 'Gradual growth and compounding strategy',
  primaryColor: Color(0xFFFFA500), // warm amber
  secondaryColor: Color(0xFFFFD580), // soft glow
  riskLevel: 'Low-Medium',
  timeHorizon: 'Medium-term',
),

    TradingPersonality(
      type: TradingPersonalityType.stonewall,
      name: 'Stonewall',
      emoji: '🧱',
      description: 'Defensive, capital protection',
      tradingStyle: 'Defensive strategy focused on capital protection',
      primaryColor: Color(0xFF696969),
      secondaryColor: Color(0xFFA9A9A9),
      riskLevel: 'Low',
      timeHorizon: 'Long-term',
    ),
   TradingPersonality(
  type: TradingPersonalityType.crystal,
  name: 'Crystal',
  emoji: '💎',
  description: 'Stable and resilient, shines through market fluctuations.',
  tradingStyle: 'Conservative, capital preservation strategies',
  primaryColor: Color(0xFF00BFA5), // darker teal
  secondaryColor: Color(0xFF66FFF0), // bright highlight
  riskLevel: 'Low-Medium',
  timeHorizon: 'Medium-term',
),

    // Visionary Traders
    TradingPersonality(
      type: TradingPersonalityType.aurora,
      name: 'Aurora',
      emoji: '✨',
      description: 'Visionary, futuristic bets',
      tradingStyle: 'Visionary trading with futuristic bets',
      primaryColor: Color(0xFF9370DB),
      secondaryColor: Color(0xFFDA70D6),
      riskLevel: 'High',
      timeHorizon: 'Long-term',
    ),
  ];

  static TradingPersonality getPersonality(TradingPersonalityType type) {
    return personalities.firstWhere((personality) => personality.type == type);
  }

  static TradingPersonality getDefaultPersonality() {
    return getPersonality(TradingPersonalityType.aurora); 
  }

  static TradingPersonality getRandomPersonality() {
    return personalities[(DateTime.now().millisecondsSinceEpoch % personalities.length)];
  }

  // Get personalities by risk level
  static List<TradingPersonality> getPersonalitiesByRiskLevel(String riskLevel) {
    return personalities.where((p) => p.riskLevel == riskLevel).toList();
  }

  // Get personalities by time horizon
  static List<TradingPersonality> getPersonalitiesByTimeHorizon(String timeHorizon) {
    return personalities.where((p) => p.timeHorizon == timeHorizon).toList();
  }

  // Get personality by name (case insensitive)
  static TradingPersonality? getPersonalityByName(String name) {
    try {
      return personalities.firstWhere(
        (p) => p.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }
}
