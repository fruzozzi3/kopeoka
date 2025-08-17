// lib/features/savings/viewmodels/savings_view_model.dart

import 'package:flutter/material.dart';
import 'package:my_kopilka/features/savings/data/repository/savings_repository.dart';
import 'package:my_kopilka/features/savings/models/goal.dart';
import 'package:my_kopilka/features/savings/models/transaction.dart';
import 'package:my_kopilka/features/savings/models/transaction_enums.dart';

class SavingsViewModel with ChangeNotifier {
  final SavingsRepository _repository;
  List<Goal> _goals = [];
  List<Goal> get goals => _goals;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  SavingsViewModel(this._repository);

  Future<void> init() async {
    await loadGoals();
  }

  Future<void> loadGoals() async {
    _isLoading = true;
    notifyListeners();
    _goals = await _repository.getGoals();
    _goals.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addGoal({
    required String name,
    required int targetAmount,
    DateTime? targetDate,
    required String category,
    String? description,
  }) async {
    final newGoal = Goal(
      name: name,
      targetAmount: targetAmount,
      createdAt: DateTime.now(),
      targetDate: targetDate,
      category: category,
      description: description,
      currentAmount: 0,
    );
    await _repository.insertGoal(newGoal);
    await loadGoals();
  }

  Future<void> deleteGoal(int goalId) async {
    await _repository.deleteGoal(goalId);
    await loadGoals();
  }

  Future<void> updateGoal(Goal goal) async {
    await _repository.updateGoal(goal);
    await loadGoals();
  }

  Future<void> addTransaction(
    int goalId,
    int amount, {
    required TransactionType type,
    required TransactionCategory category,
    String? notes,
  }) async {
    final transaction = Transaction(
      goalId: goalId,
      amount: amount,
      notes: notes,
      createdAt: DateTime.now(),
      type: type,
      category: category,
    );
    await _repository.insertTransaction(transaction);
    await loadGoals(); // Перезагружаем цели, чтобы обновить текущую сумму
  }

  Future<void> deleteTransaction(int transactionId, int goalId) async {
    await _repository.deleteTransaction(transactionId);
    await loadGoals();
  }

  Future<List<Transaction>> getTransactionsForGoal(int goalId) async {
    return await _repository.getTransactionsForGoal(goalId);
  }

  Goal? getGoalById(int goalId) {
    try {
      return _goals.firstWhere((goal) => goal.id == goalId);
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> getGoalsByCategory() {
    final categoryStats = <String, Map<String, dynamic>>{};
    for (final goal in _goals) {
      if (!categoryStats.containsKey(goal.category)) {
        categoryStats[goal.category] = {
          'count': 0,
          'saved': 0,
          'target': 0,
          'name': _getCategoryName(goal.category),
        };
      }
      categoryStats[goal.category]!['count']++;
      categoryStats[goal.category]!['saved'] += goal.currentAmount;
      categoryStats[goal.category]!['target'] += goal.targetAmount;
    }
    return categoryStats;
  }
}

String _getCategoryName(String category) {
  switch (category) {
    case 'travel':
      return 'Путешествия';
    case 'electronics':
      return 'Техника';
    case 'education':
      return 'Образование';
    case 'home':
      return 'Дом';
    case 'car':
      return 'Автомобиль';
    case 'gift':
      return 'Подарки';
    case 'emergency':
      return 'Аварийный фонд';
    default:
      return 'Общие';
  }
}
