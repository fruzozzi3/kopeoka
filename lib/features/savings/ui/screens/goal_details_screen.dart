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
    model.TransactionCategory selectedCategory = model.TransactionCategory.cash;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          left: 24,
          right: 24,
          top: 24,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: StatefulBuilder(
          builder: (context, setState) => Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  isWithdrawal ? 'Снять из копилки' : 'Пополнить копилку',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                
                TextFormField(
                  controller: amountController,
                  decoration: InputDecoration(
                    labelText: 'Сумма',
                    prefixIcon: Icon(isWithdrawal ? Icons.remove : Icons.add),
                    suffixText: '₽',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) return 'Введите сумму';
                    if (int.tryParse(value) == null || int.parse(value) <= 0) {
                      return 'Сумма должна быть больше нуля';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: notesController,
                  decoration: InputDecoration(
                    labelText: isWithdrawal ? 'На что потратили' : 'Откуда деньги (необязательно)',
                    prefixIcon: const Icon(Icons.note),
                  ),
                  maxLines: 2,
                ),
                
                const SizedBox(height: 16),
                
                Text('Способ:', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: model.TransactionCategory.values.map((category) {
                    final isSelected = selectedCategory == category;
                    return FilterChip(
                      label: Text(category.displayName),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => selectedCategory = category);
                        }
                      },
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 24),
                
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      int amount = int.parse(amountController.text);
                      if (isWithdrawal) amount = -amount;
                      
                      final notes = notesController.text.isNotEmpty 
                          ? notesController.text 
                          : null;
                      
                      vm.addTransaction(
                        widget.goalId, 
                        amount,
                        notes: notes,
                        category: selectedCategory,
                      ).then((_) {
                        Navigator.of(context).pop();
                        _loadTransactions();
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isWithdrawal 
                                ? 'Снято ${amount.abs()} ₽' 
                                : 'Добавлено $amount ₽'),
                            backgroundColor: Theme.of(context).colorScheme.primary,
                          ),
                        );
                      });
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(isWithdrawal ? 'Снять' : 'Пополнить'),
                  ),
                ),
                
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showGoalOptionsDialog(BuildContext context) {
    final vm = context.read<SavingsViewModel>();
    final goal = vm.goals.firstWhere((g) => g.id == widget.goalId);
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Редактировать цель'),
              onTap: () {
                Navigator.pop(context);
                _showEditGoalDialog(context);
              },
            ),
            
            ListTile(
              leading: Icon(goal.isArchived ? Icons.unarchive : Icons.archive),
              title: Text(goal.isArchived ? 'Разархивировать' : 'Архивировать'),
              onTap: () {
                vm.archiveGoal(goal.id!, !goal.isArchived);
                Navigator.pop(context);
                Navigator.pop(context); // Возвращаемся на главный экран
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Удалить', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmDialog(context);
              },
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showEditGoalDialog(BuildContext context) {
    final vm = context.read<SavingsViewModel>();
    final goal = vm.goals.firstWhere((g) => g.id == widget.goalId);
    
    final nameController = TextEditingController(text: goal.name);
    final descriptionController = TextEditingController(text: goal.description ?? '');
    final amountController = TextEditingController(text: goal.targetAmount.toString());
    final formKey = GlobalKey<FormState>();
    DateTime? targetDate = goal.targetDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          left: 24,
          right: 24,
          top: 24,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: StatefulBuilder(
          builder: (context, setState) => Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                Text(
                  'Редактировать цель',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 24),
                
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Название',
                    prefixIcon: Icon(Icons.flag),
                  ),
                  validator: (value) => value!.isEmpty ? 'Введите название' : null,
                ),
                
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Описание',
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 2,
                ),
                
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Целевая сумма',
                    prefixIcon: Icon(Icons.monetization_on),
                    suffixText: '₽',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) return 'Введите сумму';
                    if (int.tryParse(value) == null || int.parse(value) <= 0) {
                      return 'Введите корректную сумму';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: targetDate ?? DateTime.now().add(const Duration(days: 30)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                    );
                    if (picked != null) {
                      setState(() => targetDate = picked);
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Дата цели',
                      prefixIcon: const Icon(Icons.calendar_today),
                      suffixIcon: targetDate != null 
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => setState(() => targetDate = null),
                            )
                          : null,
                    ),
                    child: Text(
                      targetDate != null 
                          ? DateFormat('dd.MM.yyyy').format(targetDate!)
                          : 'Выберите дату',
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final updatedGoal = goal.copyWith(
                        name: nameController.text,
                        description: descriptionController.text.isNotEmpty 
                            ? descriptionController.text 
                            : null,
                        targetAmount: int.parse(amountController.text),
                        targetDate: targetDate,
                      );
                      
                      vm.updateGoal(updatedGoal);
                      Navigator.pop(context);
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Text('Сохранить'),
                  ),
                ),
                
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context) {
    final vm = context.read<SavingsViewModel>();
    final goal = vm.goals.firstWhere((g) => g.id == widget.goalId);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить цель'),
        content: Text('Вы уверены, что хотите удалить "${goal.name}"? Все связанные транзакции также будут удалены.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              vm.deleteGoal(goal.id!);
              Navigator.pop(context); // Закрываем диалог
              Navigator.pop(context); // Возвращаемся на главный экран
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Цель "${goal.name}" удалена'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Удалить', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SavingsViewModel>();
    final goal = vm.goals.firstWhere((g) => g.id == widget.goalId);
    final currencyFormat = NumberFormat.currency(locale: 'ru_RU', symbol: '₽', decimalDigits: 0);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: goal.isCompleted 
                      ? kSuccessGradient 
                      : (isDark ? kPrimaryGradientDark : kPrimaryGradientLight),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                goal.isCompleted ? Icons.check : Icons.savings,
                                color: goal.isCompleted 
                                    ? (isDark ? kSuccessDark : kSuccessLight)
                                    : (isDark ? kPrimaryDark : kPrimaryLight),
                                size: 24,
                              ),
                            ),
                            const Spacer(),
                            if (goal.daysUntilTarget != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${goal.daysUntilTarget!} дней',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          goal.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (goal.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            goal.description!,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => _showGoalOptionsDialog(context),
                icon: const Icon(Icons.more_vert, color: Colors.white),
              ),
            ],
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Прогресс
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Накоплено',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              '${(goal.progress * 100).toStringAsFixed(1)}%',
                              style: TextStyle(
                                color: goal.isCompleted 
                                    ? (isDark ? kSuccessDark : kSuccessLight)
                                    : (isDark ? kPrimaryDark : kPrimaryLight),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              currencyFormat.format(goal.currentAmount),
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: goal.isCompleted 
                                    ? (isDark ? kSuccessDark : kSuccessLight)
                                    : Theme.of(context).textTheme.titleLarge?.color,
                              ),
                            ),
                            Text(
                              '/ ${currencyFormat.format(goal.targetAmount)}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: goal.progress,
                            minHeight: 12,
                            backgroundColor: (isDark ? kTextSecondaryDark : kTextSecondaryLight).withOpacity(0.2),
                            valueColor: AlwaysStoppedAnimation(
                              goal.isCompleted 
                                  ? (isDark ? kSuccessDark : kSuccessLight)
                                  : (isDark ? kPrimaryDark : kPrimaryLight),
                            ),
                          ),
                        ),
                        if (!goal.isCompleted) ...[
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Осталось: ${currencyFormat.format(goal.remainingAmount)}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              if (goal.dailySavingsNeeded != null)
                                Text(
                                  '~${currencyFormat.format(goal.dailySavingsNeeded!.round())}/день',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Text('История операций', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          
          SliverToBoxAdapter(
            child: FutureBuilder<List<model.Transaction>>(
              future: _transactionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(50),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Container(
                    height: 200,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: kSoftShadow,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 64,
                          color: (isDark ? kTextSecondaryDark : kTextSecondaryLight).withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Операций пока нет',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: isDark ? kTextSecondaryDark : kTextSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Начните пополнять копилку!',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                }
                
                final transactions = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    final isDeposit = tx.amount > 0;
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: kSoftShadow,
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: (isDeposit 
                                ? (isDark ? kSuccessDark : kSuccessLight)
                                : (isDark ? kErrorDark : kErrorLight)
                            ).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isDeposit ? Icons.add_circle : Icons.remove_circle,
                            color: isDeposit 
                                ? (isDark ? kSuccessDark : kSuccessLight)
                                : (isDark ? kErrorDark : kErrorLight),
                          ),
                        ),
                        title: Text(
                          currencyFormat.format(tx.amount.abs()),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isDeposit 
                                ? (isDark ? kSuccessDark : kSuccessLight)
                                : (isDark ? kErrorDark : kErrorLight),
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (tx.notes != null && tx.notes!.isNotEmpty) 
                              Text(tx.notes!),
                            Text(
                              '${DateFormat('dd.MM.yyyy HH:mm').format(tx.createdAt)} • ${tx.category.displayName}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        isThreeLine: tx.notes != null && tx.notes!.isNotEmpty,
                      ),
                    );
                  },
                );
              },
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
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
