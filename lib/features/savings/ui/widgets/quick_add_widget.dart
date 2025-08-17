// lib/features/savings/ui/widgets/quick_add_widget.dart

import 'package:flutter/material.dart';
import 'package:my_kopilka/features/savings/viewmodels/savings_view_model.dart';
import 'package:my_kopilka/theme/color.dart';
import 'package:provider/provider.dart';
import 'package:my_kopilka/features/savings/models/transaction_enums.dart';

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
            GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildBill(context, 100),
                _buildBill(context, 200),
                _buildBill(context, 500),
                _buildBill(context, 1000),
                _buildBill(context, 2000),
                _buildBill(context, 5000),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
                _showCustomAmountDialog(context);
              },
              child: const Text('Своя сумма'),
            ),
          ],
        ),
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
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final vm = context.read<SavingsViewModel>();
                final amount = int.parse(controller.text);
                vm.addTransaction(
                  vm.goals.first.id!, 
                  amount,
                  type: TransactionType.income,
                  category: TransactionCategory.cash
                );
                Navigator.pop(context); // Закрыть диалог
                Navigator.pop(context); // Закрыть BottomSheet
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Добавлено $amount₽')),
                );
              }
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }

  Color getBillColor() {
    // Временно, чтобы избежать ошибки
    return kPrimary;
  }

  Widget _buildBill(BuildContext context, int value) {
    return InkWell(
      onTap: () {
        final vm = context.read<SavingsViewModel>();
        vm.addTransaction(
          vm.goals.first.id!, 
          value,
          type: TransactionType.income,
          category: TransactionCategory.cash
        );
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Добавлено $value₽')),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: getBillColor(),
          borderRadius: BorderRadius.circular(16),
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
