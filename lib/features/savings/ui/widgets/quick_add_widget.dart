// lib/features/savings/ui/widgets/quick_add_widget.dart

import 'package:flutter/material.dart';
import 'package:my_kopilka/features/savings/viewmodels/savings_view_model.dart';
import 'package:my_kopilka/theme/color.dart';
import 'package:provider/provider.dart';

class QuickAddWidget extends StatelessWidget {
  const QuickAddWidget({super.key});

  void _showQuickAddDialog(BuildContext context) {
    final vm = context.read<SavingsViewModel>();
    
    if (vm.goals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Сначала создайте копилку')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
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
              'Быстрое пополнение',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            
            // Монеты
            Text('Монеты', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _CoinButton(value: 1, onTap: () => _addMoney(context, 1)),
                _CoinButton(value: 2, onTap: () => _addMoney(context, 2)),
                _CoinButton(value: 5, onTap: () => _addMoney(context, 5)),
                _CoinButton(value: 10, onTap: () => _addMoney(context, 10)),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Банкноты
            Text('Банкноты', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _BillButton(value: 50, onTap: () => _addMoney(context, 50)),
                _BillButton(value: 100, onTap: () => _addMoney(context, 100)),
                _BillButton(value: 200, onTap: () => _addMoney(context, 200)),
                _BillButton(value: 500, onTap: () => _addMoney(context, 500)),
                _BillButton(value: 1000, onTap: () => _addMoney(context, 1000)),
                _BillButton(value: 2000, onTap: () => _addMoney(context, 2000)),
                _BillButton(value: 5000, onTap: () => _addMoney(context, 5000)),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Свободная сумма
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _showCustomAmountDialog(context);
              },
              icon: const Icon(Icons.edit),
              label: const Text('Другая сумма'),
            ),
            
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _addMoney(BuildContext context, int amount) {
    final vm = context.read<SavingsViewModel>();
    
    if (vm.goals.length == 1) {
      // Если копилка одна, добавляем сразу
      vm.addTransaction(vm.goals.first.id!, amount, 
          notes: 'Быстрое пополнение: $amount ₽');
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Добавлено $amount ₽ в ${vm.goals.first.name}'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } else {
      // Если копилок несколько, показываем выбор
      Navigator.pop(context);
      _showGoalSelectionDialog(context, amount);
    }
  }

  void _showGoalSelectionDialog(BuildContext context, int amount) {
    final vm = context.read<SavingsViewModel>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Добавить $amount ₽'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('В какую копилку добавить?'),
            const SizedBox(height: 16),
            ...vm.goals.where((g) => !g.isCompleted && !g.isArchived).map((goal) =>
              ListTile(
                leading: CircleAvatar(
                  child: Text('${goal.progress * 100 ~/ 1}%'),
                ),
                title: Text(goal.name),
                subtitle: Text('${goal.currentAmount} / ${goal.targetAmount} ₽'),
                onTap: () {
                  vm.addTransaction(goal.id!, amount,
                      notes: 'Быстрое пополнение: $amount ₽');
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Добавлено $amount ₽ в ${goal.name}'),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final amount = int.parse(controller.text);
                Navigator.pop(context);
                _addMoney(context, amount);
              }
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
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
                Icons.add_circle_outline,
                color: isDark ? kPrimaryDark : kPrimaryLight,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Быстрое пополнение',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Добавьте деньги, которые положили в копилку',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showQuickAddDialog(context),
              icon: const Icon(Icons.monetization_on),
              label: const Text('Пополнить копилку'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoinButton extends StatelessWidget {
  final int value;
  final VoidCallback onTap;

  const _CoinButton({required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFDAA520)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            '$value₽',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

class _BillButton extends StatelessWidget {
  final int value;
  final VoidCallback onTap;

  const _BillButton({required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    Color getBillColor() {
      switch (value) {
        case 50: return const Color(0xFF8B4513);
        case 100: return const Color(0xFF006400);
        case 200: return const Color(0xFF4169E1);
        case 500: return const Color(0xFF800080);
        case 1000: return const Color(0xFF228B22);
        case 2000: return const Color(0xFF4169E1);
        case 5000: return const Color(0xFFDC143C);
        default: return Colors.grey;
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 50,
        decoration: BoxDecoration(
          color: getBillColor(),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: getBillColor().withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            '$value₽',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
          ),
        ],
      ),
    );
  }

  void _showCustomAmountDialog(BuildContext context) {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Свободная сумма'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Введите сумму',
              suffixText: '₽',
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Введите сумму';
              final amount = int.tryParse(value!);
              if (amount == null || amount <= 0) return 'Некорректная сумма';
              return null;
            },
            autofocus: true,
          ),
        ),
actions: [
  TextButton(
    onPressed: () => Navigator.pop(context),
    child: const Text('Отмена'),
  ),
],
