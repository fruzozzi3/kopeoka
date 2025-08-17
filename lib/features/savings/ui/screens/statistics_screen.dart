// lib/features/savings/ui/screens/statistics_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_kopilka/features/savings/viewmodels/savings_view_model.dart';
import 'package:my_kopilka/theme/color.dart';
import 'package:provider/provider.dart';
import 'package:my_kopilka/features/savings/models/goal.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String _selectedPeriod = 'month'; // week, month, year, all

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SavingsViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(locale: 'ru_RU', symbol: '₽', decimalDigits: 0);

    // Подсчет статистики
    final totalSaved = vm.goals.fold(0, (sum, goal) => sum + goal.currentAmount);
    final totalTarget = vm.goals.fold(0, (sum, goal) => sum + goal.targetAmount);
    final completedGoals = vm.goals.where((g) => g.isCompleted).length;
    final activeGoals = vm.goals.where((g) => !g.isCompleted).length;
    final averageProgress = vm.goals.isNotEmpty 
        ? vm.goals.fold(0.0, (sum, goal) => sum + goal.progress) / vm.goals.length
        : 0.0;

    // Анализ по категориям
    final categoryStats = vm.getGoalsByCategory();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Аналитика'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Общая статистика
              _buildSectionTitle(context, 'Общая статистика'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildStatRow(
                        context, 
                        'Всего накоплено', 
                        currencyFormat.format(totalSaved), 
                        isDark ? kSuccessDark : kSuccessLight
                      ),
                      _buildStatRow(
                        context, 
                        'Общая цель', 
                        currencyFormat.format(totalTarget), 
                        isDark ? kInfoDark : kInfoLight
                      ),
                      _buildStatRow(
                        context, 
                        'Завершено целей', 
                        completedGoals.toString(), 
                        isDark ? kPrimaryDark : kPrimaryLight
                      ),
                      _buildStatRow(
                        context, 
                        'Активных целей', 
                        activeGoals.toString(), 
                        isDark ? kPrimaryDark : kPrimaryLight
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Топ копилок
              _buildSectionTitle(context, 'Топ-3 копилки'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: vm.goals
                        .sortedByProgress()
                        .take(3)
                        .map((goal) => _buildGoalProgressRow(context, goal, currencyFormat))
                        .toList(),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              
              // Статистика по категориям
              _buildSectionTitle(context, 'По категориям'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: categoryStats.entries.map((entry) {
                      final categoryName = entry.value['name'] as String;
                      final savedAmount = entry.value['saved'] as int;
                      final targetAmount = entry.value['target'] as int;
                      final progress = targetAmount > 0 ? savedAmount / targetAmount : 0.0;
                      return _buildCategoryProgressRow(
                        context,
                        categoryName,
                        progress,
                        currencyFormat.format(savedAmount),
                        currencyFormat.format(targetAmount),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String title, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodyMedium),
          Text(value, style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: color)),
        ],
      ),
    );
  }

  Widget _buildGoalProgressRow(BuildContext context, Goal goal, NumberFormat currencyFormat) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                goal.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                '${(goal.progress * 100).toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: goal.isCompleted
                      ? (isDark ? kSuccessDark : kSuccessLight)
                      : (isDark ? kPrimaryDark : kPrimaryLight),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: goal.progress,
            backgroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation(
              goal.isCompleted 
                  ? (isDark ? kSuccessDark : kSuccessLight)
                  : (isDark ? kPrimaryDark : kPrimaryLight),
            ),
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryProgressRow(BuildContext context, String categoryName, double progress, String savedAmount, String targetAmount) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                categoryName,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                '${(progress * 100).toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: progress >= 1.0 
                      ? (isDark ? kSuccessDark : kSuccessLight) 
                      : (isDark ? kPrimaryDark : kPrimaryLight),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$savedAmount из $targetAmount',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation(
              progress >= 1.0 
                  ? (isDark ? kSuccessDark : kSuccessLight) 
                  : (isDark ? kPrimaryDark : kPrimaryLight),
            ),
            minHeight: 8,
          ),
        ],
      ),
    );
  }
}
