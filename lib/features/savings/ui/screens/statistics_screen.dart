// lib/features/savings/ui/screens/statistics_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_kopilka/features/savings/viewmodels/savings_view_model.dart';
import 'package:my_kopilka/theme/color.dart';
import 'package:provider/provider.dart';

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
    final activeGoals = vm.goals.where((g) => !g.isCompleted && !g.isArchived).length;
    final averageProgress = vm.goals.isNotEmpty 
        ? vm.goals.fold(0.0, (sum, goal) => sum + goal.progress) / vm.goals.length
        : 0.0;

    // Анализ по категориям
    final categoryStats = <String, Map<String, dynamic>>{};
    for (final goal in vm.goals) {
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

    // Самая успешная копилка
    final mostSuccessfulGoal = vm.goals.isNotEmpty 
        ? vm.goals.reduce((a, b) => a.progress > b.progress ? a : b)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Статистика'),
        actions: [
          PopupMenuButton<String>(
            initialValue: _selectedPeriod,
            onSelected: (value) => setState(() => _selectedPeriod = value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'week', child: Text('За неделю')),
              const PopupMenuItem(value: 'month', child: Text('За месяц')),
              const PopupMenuItem(value: 'year', child: Text('За год')),
              const PopupMenuItem(value: 'all', child: Text('За все время')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Общая статистика
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: isDark ? kPrimaryGradientDark : kPrimaryGradientLight,
                borderRadius: BorderRadius.circular(20),
                boxShadow: kSoftShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.analytics, color: Colors.white, size: 28),
                      SizedBox(width: 12),
                      Text(
                        'Общая статистика',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Накоплено',
                          currencyFormat.format(totalSaved),
                          Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'Цель',
                          currencyFormat.format(totalTarget),
                          Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Завершено',
                          '$completedGoals/${vm.goals.length}',
                          Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'Прогресс',
                          '${(averageProgress * 100).toStringAsFixed(1)}%',
                          Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Достижения
            if (completedGoals > 0 || mostSuccessfulGoal != null) ...[
              Text('Достижения', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              
              if (completedGoals > 0)
                _buildAchievementCard(
                  context,
                  Icons.emoji_events,
                  'Целеустремленный',
                  'Завершено целей: $completedGoals',
                  kSuccessGradient,
                ),
              
              if (mostSuccessfulGoal != null && mostSuccessfulGoal.progress > 0.5)
                _buildAchievementCard(
                  context,
                  Icons.trending_up,
                  'На пути к цели',
                  '${mostSuccessfulGoal.name}: ${(mostSuccessfulGoal.progress * 100).toStringAsFixed(1)}%',
                  isDark ? kPrimaryGradientDark : kPrimaryGradientLight,
                ),

              if (totalSaved >= 10000)
                _buildAchievementCard(
                  context,
                  Icons.account_balance_wallet,
                  'Накопитель',
                  'Накоплено более 10,000 ₽',
                  const LinearGradient(colors: [Color(0xFFFF6B6B), Color(0xFFEE5A24)]),
                ),

              const SizedBox(height: 24),
            ],

            // Статистика по категориям
            if (categoryStats.isNotEmpty) ...[
              Text('По категориям', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              
              ...categoryStats.entries.map((entry) {
                final data = entry.value;
                final progress = data['target'] > 0 
                    ? (data['saved'] / data['target']).clamp(0.0, 1.0)
                    : 0.0;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: kSoftShadow,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: (isDark ? kPrimaryDark : kPrimaryLight).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getCategoryIcon(entry.key),
                          color: isDark ? kPrimaryDark : kPrimaryLight,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['name'],
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              '${data['count']} ${_getGoalWord(data['count'])}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.grey.withOpacity(0.2),
                              valueColor: AlwaysStoppedAnimation(
                                isDark ? kPrimaryDark : kPrimaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            currencyFormat.format(data['saved']),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            '/ ${currencyFormat.format(data['target'])}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 24),
            ],

            // Мотивационные советы
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: kSoftShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: isDark ? kWarningDark : kWarningLight,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Советы по накоплению',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  if (activeGoals == 0)
                    _buildTip('Создайте новую цель для накоплений')
                  else if (averageProgress < 0.3)
                    _buildTip('Попробуйте откладывать небольшие суммы ежедневно')
                  else if (averageProgress > 0.8)
                    _buildTip('Отлично! Вы близки к достижению целей')
                  else
                    _buildTip('Регулярность - ключ к успешным накоплениям'),

                  _buildTip('Считайте мелочь - она быстро накапливается'),
                  _buildTip('Ведите учет всех пополнений копилки'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: textColor.withOpacity(0.9),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementCard(
    BuildContext context,
    IconData icon,
    String title,
    String description,
    LinearGradient gradient,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: kSoftShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: gradient.colors.first, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryName(String category) {
    switch (category) {
      case 'travel': return 'Путешествия';
      case 'electronics': return 'Техника';
      case 'education': return 'Образование';
      case 'home': return 'Дом';
      case 'car': return 'Автомобиль';
      case 'gift': return 'Подарки';
      case 'emergency': return 'Аварийный фонд';
      default: return 'Общие';
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'travel': return Icons.flight;
      case 'electronics': return Icons.phone_android;
      case 'education': return Icons.school;
      case 'home': return Icons.home;
      case 'car': return Icons.directions_car;
      case 'gift': return Icons.card_giftcard;
      case 'emergency': return Icons.emergency;
      default: return Icons.savings;
    }
  }

  String _getGoalWord(int count) {
    if (count == 1) return 'цель';
    if (count >= 2 && count <= 4) return 'цели';
    return 'целей';
  }
}