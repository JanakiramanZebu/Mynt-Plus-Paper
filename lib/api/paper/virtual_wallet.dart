import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Virtual wallet for paper trading.
/// Manages a simulated cash balance persisted in SharedPreferences.
class VirtualWallet {
  static const String _balanceKey = 'paper_wallet_balance';
  static const String _transactionsKey = 'paper_wallet_transactions';
  static const double defaultBalance = 1000000.0; // 10,00,000

  static VirtualWallet? _instance;
  static VirtualWallet get instance {
    _instance ??= VirtualWallet._();
    return _instance!;
  }

  VirtualWallet._();

  double _balance = defaultBalance;
  double get balance => _balance;

  final List<WalletTransaction> _transactions = [];
  List<WalletTransaction> get transactions => List.unmodifiable(_transactions);

  /// Initialize wallet from SharedPreferences.
  /// Call once at startup after SharedPreferences is ready.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _balance = prefs.getDouble(_balanceKey) ?? defaultBalance;

    final txJson = prefs.getString(_transactionsKey);
    if (txJson != null) {
      final List list = jsonDecode(txJson);
      _transactions.clear();
      for (final item in list) {
        _transactions.add(WalletTransaction.fromJson(item));
      }
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_balanceKey, _balance);
    // Keep last 500 transactions only
    if (_transactions.length > 500) {
      _transactions.removeRange(0, _transactions.length - 500);
    }
    await prefs.setString(
        _transactionsKey, jsonEncode(_transactions.map((e) => e.toJson()).toList()));
  }

  /// Deduct amount on BUY. Returns true if sufficient balance.
  Future<bool> debit(double amount, String description) async {
    if (amount <= 0) return false;
    if (_balance < amount) return false;
    _balance -= amount;
    _transactions.add(WalletTransaction(
      type: 'DEBIT',
      amount: amount,
      balance: _balance,
      description: description,
      timestamp: DateTime.now(),
    ));
    await _save();
    return true;
  }

  /// Add amount on SELL.
  Future<void> credit(double amount, String description) async {
    if (amount <= 0) return;
    _balance += amount;
    _transactions.add(WalletTransaction(
      type: 'CREDIT',
      amount: amount,
      balance: _balance,
      description: description,
      timestamp: DateTime.now(),
    ));
    await _save();
  }

  /// Check if enough balance exists for a trade.
  bool hasSufficientBalance(double amount) => _balance >= amount;

  /// Reset wallet to default balance and clear history.
  Future<void> reset() async {
    _balance = defaultBalance;
    _transactions.clear();
    await _save();
  }
}

class WalletTransaction {
  final String type; // DEBIT or CREDIT
  final double amount;
  final double balance;
  final String description;
  final DateTime timestamp;

  WalletTransaction({
    required this.type,
    required this.amount,
    required this.balance,
    required this.description,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        'amount': amount,
        'balance': balance,
        'description': description,
        'timestamp': timestamp.toIso8601String(),
      };

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      type: json['type'] ?? 'DEBIT',
      amount: (json['amount'] as num).toDouble(),
      balance: (json['balance'] as num).toDouble(),
      description: json['description'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
