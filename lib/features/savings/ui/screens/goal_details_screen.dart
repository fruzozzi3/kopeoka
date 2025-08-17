// lib/features/savings/ui/screens/goal_details_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_kopilka/features/savings/models/transaction.dart' as model;
import 'package:my_kopilka/features/savings/viewmodels/savings_view_model.dart';
import 'package:my_kopilka/theme/color.dart';
import 'package:provider/provider.dart';
import 'package:my_kopilka/features/savings/models/transaction_enums.dart';

class GoalDetailsScreen extends StatefulWidget {
  final int goalId;
  const GoalDetailsScreen({super.key, required this.goalId});

  @override
  State<GoalDetailsScreen> createState() => _GoalDetailsScreenState();
}

class _GoalDetailsScreenState extends State<GoalDetailsScreen> {
  late Future<List<model.Transaction>> _transactionsFuture;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }
  
  void _loadTransactions() {
    final vm = Provider.of<SavingsViewModel>(context, listen: false);
    setState(() {
      _transactionsFuture = vm.getTransactionsForGoal(widget.goalId);
    });
  }

  void _showAddTransactionDialog(BuildContext context, {required bool isWithdrawal}) {
    final vm = context.read<SavingsViewModel>();
    final amountController = TextEditingController();
    final notesController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    TransactionCategory selectedCategory = TransactionCategory.cash;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    isWithdrawal ? 'Снять средства' : 'Пополнить копилку',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Сумма',
                      suffixText: '₽',
                      prefixIcon: Icon(isWithdrawal ? Icons.remove : Icons.add),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите сумму';
                      }
                      final amount = int.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return 'Некорректная сумма';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'Заметки (необязательно)',
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLength: 100,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Категория:', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<TransactionCategory>(
                          value: selectedCategory,
                          items: TransactionCategory.values.map((category) {
                            return DropdownMenuItem<TransactionCategory>(
                              value: category,
                              child: Text(_getCategoryName(category)),
                            );
                          }).toList(),
                          onChanged: (category) {
                            if (category != null) {
                              setState(() {
                                selectedCategory = category;
                              });
                            }
                          },
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        final amount = int.parse(amountController.text);
                        vm.addTransaction(
                          widget.goalId, 
                          isWithdrawal ? -amount : amount,
                          type: isWithdrawal ? TransactionType.outcome : TransactionType.income,
                          category: selectedCategory,
                          notes: notesController.text.isNotEmpty ? notesController.text : null,
                        );
                        _loadTransactions();
                        Navigator.pop(context);
                      }
                    },
                    child: Text(isWithdrawal ? 'Снять' : 'Добавить'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getCategoryName(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.cash: return 'Наличные';
      case TransactionCategory.card: return 'Карта';
      case TransactionCategory.bankTransfer: return 'Банковский перевод';
      case TransactionCategory.other: return 'Другое';
    }
  }

  String _getGoalCategoryName(String category) {
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

  IconData _getGoalCategoryIcon(String category) {
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

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SavingsViewModel>();
    final goal = vm.getGoalById(widget.goalId);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(locale: 'ru_RU', symbol: '₽', decimalDigits: 0);

    if (goal == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Копилка не найдена')),
        body: const Center(child: Text('Копилка не найдена')),
      );
    }

    final daysLeft = goal.targetDate != null
        ? goal.targetDate!.difference(DateTime.now()).inDays
        : null;

    final dailySavingsNeeded = goal.targetDate != null && daysLeft != null && daysLeft > 0
        ? (goal.targetAmount - goal.currentAmount) / daysLeft
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(goal.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditGoalDialog(context, goal, vm),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteGoalDialog(context, goal, vm),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Общая информация
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: kSoftShadow,
                      ),
                      child: Icon(_getGoalCategoryIcon(goal.category), size: 36, color: Theme.of(context).colorScheme.primary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getGoalCategoryName(goal.category),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            currencyFormat.format(goal.currentAmount),
                            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
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
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${(goal.progress * 100).toStringAsFixed(1)}%',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                'Цель: ${currencyFormat.format(goal.targetAmount)}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Дополнительная информация
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoRow(
                      context,
                      'Дата создания',
                      DateFormat('dd.MM.yyyy').format(goal.createdAt),
                      Icons.calendar_today,
                      isDark,
                    ),
                    if (goal.targetDate != null)
                      _buildInfoRow(
                        context,
                        'Дата завершения',
                        DateFormat('dd.MM.yyyy').format(goal.targetDate!),
                        Icons.calendar_month,
                        isDark,
                      ),
                    if (dailySavingsNeeded != null)
                      _buildInfoRow(
                        context,
                        'В день нужно',
                        '${currencyFormat.format(dailySavingsNeeded.round())} ₽',
                        Icons.trending_up,
                        isDark,
                      ),
                    if (goal.description != null && goal.description!.isNotEmpty)
                      _buildInfoRow(
                        context,
                        'Описание',
                        goal.description!,
                        Icons.notes,
                        isDark,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Список транзакций
            Text('История операций', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            FutureBuilder<List<model.Transaction>>(
              future: _transactionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Ошибка: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Пока нет операций.'));
                } else {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final transaction = snapshot.data![index];
                      return Dismissible(
                        key: Key(transaction.id.toString()),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          vm.deleteTransaction(transaction.id!, widget.goalId);
                          _loadTransactions();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Операция удалена')),
                          );
                        },
                        background: Container(
                          color: Theme.of(context).colorScheme.error,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: Icon(
                              transaction.amount > 0 ? Icons.add : Icons.remove,
                              color: transaction.amount > 0
                                ? (isDark ? kSuccessDark : kSuccessLight)
                                : (isDark ? kErrorDark : kErrorLight),
                            ),
                            title: Text(
                              currencyFormat.format(transaction.amount),
                              style: TextStyle(
                                color: transaction.amount > 0
                                  ? (isDark ? kSuccessDark : kSuccessLight)
                                  : (isDark ? kErrorDark : kErrorLight),
                              ),
                            ),
                            subtitle: Text(
                              '${DateFormat('dd.MM.yyyy').format(transaction.createdAt)}',
                            ),
                            trailing: Text(
                              transaction.notes ?? '',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildActionButtons(context, goal, isDark, vm),
    );
  }

  void _showEditGoalDialog(BuildContext context, Goal goal, SavingsViewModel vm) {
    // Реализация диалога редактирования
  }

  void _showDeleteGoalDialog(BuildContext context, Goal goal, SavingsViewModel vm) {
    // Реализация диалога удаления
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: isDark ? kPrimaryDark : kPrimaryLight,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Goal goal, bool isDark, SavingsViewModel vm) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: goal.currentAmount > 0
                      ? () => _showAddTransactionDialog(context, isWithdrawal: true)
                      : null,
                  icon: const Icon(Icons.remove),
                  label: const Text('Снять'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: isDark ? kErrorDark : kErrorLight),
                    foregroundColor: isDark ? kErrorDark : kErrorLight,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showAddTransactionDialog(context, isWithdrawal: false),
                  icon: const Icon(Icons.add),
                  label: const Text('Пополнить'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: isDark ? kSuccessDark : kSuccessLight,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
