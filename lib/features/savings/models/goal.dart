// lib/features/savings/models/goal.dart

import 'package:my_kopilka/features/savings/models/transaction.dart';
import 'package:my_kopilka/features/savings/models/transaction_enums.dart';

class Goal {
  final int? id;
  final String name;
  final int targetAmount;
  final int currentAmount;
  final DateTime createdAt;
  final DateTime? targetDate;
  final String category;
  final String? description;
  final List<Transaction>? transactions;

  double get progress => (currentAmount / targetAmount).clamp(0.0, 1.0);
  bool get isCompleted => currentAmount >= targetAmount;

  const Goal({
    this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.createdAt,
    this.targetDate,
    required this.category,
    this.description,
    this.transactions,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'target_amount': targetAmount,
    'current_amount': currentAmount,
    'created_at': createdAt.millisecondsSinceEpoch,
    'target_date': targetDate?.millisecondsSinceEpoch,
    'category': category,
    'description': description,
  };

  factory Goal.fromMap(Map<String, dynamic> map) => Goal(
    id: map['id'] as int?,
    name: map['name'] as String,
    targetAmount: map['target_amount'] as int,
    currentAmount: map['current_amount'] as int,
    createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    targetDate: map['target_date'] != null
        ? DateTime.fromMillisecondsSinceEpoch(map['target_date'] as int)
        : null,
    category: map['category'] as String,
    description: map['description'] as String?,
  );

  Goal copyWith({
    int? id,
    String? name,
    int? targetAmount,
    int? currentAmount,
    DateTime? createdAt,
    DateTime? targetDate,
    String? category,
    String? description,
    List<Transaction>? transactions,
  }) {
    return Goal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      createdAt: createdAt ?? this.createdAt,
      targetDate: targetDate ?? this.targetDate,
      category: category ?? this.category,
      description: description ?? this.description,
      transactions: transactions ?? this.transactions,
    );
  }
}

extension GoalListExtension on List<Goal> {
  List<Goal> sortedByProgress() {
    return List.from(this)..sort((a, b) => b.progress.compareTo(a.progress));
  }
}
