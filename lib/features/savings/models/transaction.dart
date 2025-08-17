// lib/features/savings/models/transaction.dart

import 'package:my_kopilka/features/savings/models/transaction_enums.dart';

class Transaction {
  final int? id;
  final int goalId;
  final int amount; // Положительное - пополнение, отрицательное - снятие
  final String? notes;
  final DateTime createdAt;
  final TransactionType type;
  final TransactionCategory category;

  Transaction({
    this.id,
    required this.goalId,
    required this.amount,
    this.notes,
    required this.createdAt,
    required this.type,
    required this.category,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'goal_id': goalId,
    'amount': amount,
    'notes': notes,
    'created_at': createdAt.millisecondsSinceEpoch,
    'type': type.index,
    'category': category.index,
  };

  factory Transaction.fromMap(Map<String, dynamic> map) => Transaction(
    id: map['id'] as int?,
    goalId: map['goal_id'] as int,
    amount: map['amount'] as int,
    notes: map['notes'] as String?,
    createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    type: TransactionType.values[map['type'] as int],
    category: TransactionCategory.values[map['category'] as int],
  );
}
