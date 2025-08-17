// lib/features/savings/viewmodels/savings_view_model.dart

import 'package:flutter/foundation.dart';
import 'package:my_kopilka/features/savings/data/repository/savings_repository.dart';
import 'package:my_kopilka/features/savings/models/goal.dart';
import 'package:my_kopilka/features/savings/models/transaction.dart';
import 'package:my_kopilka/features/savings/models/transaction_enums.dart';

class SavingsViewModel extends ChangeNotifier {
  final SavingsRepository _repository;
  SavingsViewModel(this._repository);

  List<Goal> _goals = [];
  List<Goal> get goals => _goals;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    await fetchGoals();
  }

  Future<void> fetchGoals() async {
    _isLoading = true;
    notifyListeners();

    try {
      final fetchedGoals = await _repository.getAllGoals();
      for (var goal in fetchedGoals) {
        goal.currentAmount = await _repository.getCurrentSumForGoal(goal.id!);
      }
      _goals = fetchedGoals;
    } catch (e) {
      debugPrint('Error fetching goals: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addGoal({
    required String name,
    String? description,
    required int targetAmount,
    DateTime? targetDate,
    String category = 'general',
  }) async {
    final newGoal = Goal(
      name: name,
      description: description,
      targetAmount: targetAmount,
      targetDate: targetDate,
      category: category,
      createdAt: DateTime.now(),
    );
    
    try {
      await _repository.addGoal(newGoal);
      await fetchGoals();
    } catch (e) {
      debugPrint('Error adding goal: $e');
    }
  }

  Future<void> updateGoal(Goal goal) async {
    try {
      await _repository.updateGoal(goal);
      await fetchGoals();
    } catch (e) {
      debugPrint('Error updating goal: $e');
    }
  }

  Future<void> deleteGoal(int goalId) async {
    try {
      await _repository.deleteGoal(goalId);
      await fetchGoals();
    } catch (e) {
      debugPrint('Error deleting goal: $e');
    }
  }

  Future<void> archiveGoal(int goalId, bool isArchived) async {
    try {
      final goal = _goals.firstWhere((g) => g.id == goalId);
      final updatedGoal = goal.copyWith(isArchived: isArchived);
      await _repository.updateGoal(updatedGoal);
      await fetchGoals();
    } catch (e) {
      debugPrint('Error archiving goal: $e');
    }
  }

  Future<void> addTransaction(
    int goalId, 
    int amount, {
    String? notes,
    TransactionType? type,
    TransactionCategory category = TransactionCategory.cash,
  }) async {
    final transaction = Transaction(
      goalId: goalId,
      amount: amount,
      notes: notes,
      type: type,
      category: category,
      createdAt: DateTime.now(),
    );
    
    try {
      await _repository.addTransaction(transaction);
      await fetchGoals(); // Обновляем цели, чтобы пересчитать суммы
    } catch (e) {
      debugPrint('Error adding transaction: $e');
    }
  }

  Future<List<Transaction>> getTransactionsForGoal(int goalId) {
    return _repository.getTransactionsForGoal(goalId);
  }

  Future<List<Transaction>> getAllTransactions({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _repository.getAllTransactions(
      startDate: startDate,
      endDate: endDate,
    );
  }

  // Быстрое добавление денег в активную цель
  Future<void> quickAdd(int amount) async {
    final activeGoals = _goals.where((g) => !g.isCompleted && !g.isArchived).toList();
    
    if (activeGoals.isEmpty) return;
    
    // Если активная цель одна, добавляем в нее
    if (activeGoals.length == 1) {
      await addTransaction(
        activeGoals.first.id!,
        amount,
        notes: 'Быстрое пополнение',
      );
      return;
    }
    
    // Если целей несколько, добавляем в ту, которая ближе к завершению
    activeGoals.sort((a, b) => b.progress.compareTo(a.progress));
    await addTransaction(
      activeGoals.first.id!,
      amount,
      notes: 'Быстрое пополнение',
    );
  }

  // Анализ накоплений
  Map<String, dynamic> getAnalytics() {
    final totalSaved = _goals.fold(0, (sum, goal) => sum + goal.currentAmount);
    final totalTarget = _goals.fold(0, (sum, goal) => sum + goal.targetAmount);
    final completedGoals = _goals.where((g) => g.isCompleted).length;
    final averageProgress = _goals.isNotEmpty 
        ? _goals.fold(0.0, (sum, goal) => sum + goal.progress) / _goals.length
        : 0.0;

    return {
      'totalSaved': totalSaved,
      'totalTarget': totalTarget,
      'completedGoals': completedGoals,
      'totalGoals': _goals.length,
      'averageProgress': averageProgress,
      'remainingToTarget': totalTarget - totalSaved,
    };
  }

  // Получить цели по категориям
  Map<String, List<Goal>> getGoalsByCategory() {
    final Map<String, List<Goal>> result = {};
    
    for (final goal in _goals) {
      if (!result.containsKey(goal.category)) {
        result[goal.category] = [];
      }
      result[goal.category]!.add(goal);
    }
    
    return result;
  }

  // Получить рекомендации
  List<String> getRecommendations() {
    final recommendations = <String>[];
    final analytics = getAnalytics();
    
    if (analytics['totalGoals'] == 0) {
      recommendations.add('Создайте свою первую цель накопления');
      return recommendations;
    }
    
    if (analytics['averageProgress'] < 0.2) {
      recommendations.add('Попробуйте откладывать небольшие суммы регулярно');
      recommendations.add('Собирайте мелочь - она быстро накапливается');
    }
    
    if (analytics['completedGoals'] == 0 && analytics['totalGoals'] > 0) {
      recommendations.add('Сосредоточьтесь на одной цели для быстрого результата');
    }
    
    final urgentGoals = _goals.where((g) => 
      g.targetDate != null && 
      g.daysUntilTarget != null && 
      g.daysUntilTarget! <= 30 && 
      !g.isCompleted
    ).toList();
    
    if (urgentGoals.isNotEmpty) {
      recommendations.add('У вас есть цели с приближающимся дедлайном');
    }
    
    if (recommendations.isEmpty) {
      recommendations.add('Отлично! Продолжайте в том же духе');
      recommendations.add('Рассмотрите возможность создания новых целей');
    }
    
    return recommendations;
  }

  // Поиск целей
  List<Goal> searchGoals(String query) {
    if (query.isEmpty) return _goals;
    
    final lowercaseQuery = query.toLowerCase();
    return _goals.where((goal) {
      return goal.name.toLowerCase().contains(lowercaseQuery) ||
             (goal.description?.toLowerCase().contains(lowercaseQuery) ?? false) ||
             goal.category.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Получить самую активную цель (с наибольшим количеством транзакций за последнее время)
  Future<Goal?> getMostActiveGoal() async {
    if (_goals.isEmpty) return null;
    
    final Map<int, int> transactionCounts = {};
    final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
    
    for (final goal in _goals) {
      final transactions = await getTransactionsForGoal(goal.id!);
      final recentTransactions = transactions.where((t) => t.createdAt.isAfter(oneWeekAgo));
      transactionCounts[goal.id!] = recentTransactions.length;
    }
    
    if (transactionCounts.isEmpty) return null;
    
    final mostActiveGoalId = transactionCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    
    return _goals.firstWhere((g) => g.id == mostActiveGoalId);
  }
}
