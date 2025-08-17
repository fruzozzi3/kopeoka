// lib/features/savings/models/goal.dart

import 'package:intl/intl.dart';

class Goal {
  final int? id;
  final String name;
  final int targetAmount;
  final DateTime createdAt;
  final DateTime? targetDate;
  final String description;
  final String category;
  int currentAmount;
  bool isArchived;

  Goal({
    this.id,
    required this.name,
    required this.targetAmount,
    required this.createdAt,
    this.currentAmount = 0,
    this.targetDate,
    this.description = '',
    this.category = 'general',
    this.isArchived = false,
  });

  // Вычисляемые геттеры
  double get progress => currentAmount / targetAmount;
  bool get isCompleted => currentAmount >= targetAmount;
  String get formattedDate => DateFormat('d MMM yyyy').format(createdAt);
  String get formattedTargetDate => targetDate != null ? DateFormat('d MMM yyyy').format(targetDate!) : '';
  int get daysUntilTarget {
    if (targetDate == null) return 0;
    final now = DateTime.now();
    final difference = targetDate!.difference(now);
    return difference.inDays + 1;
  }
  double get remainingAmount => (targetAmount - currentAmount).toDouble();
  double? get dailySavingsNeeded {
    if (remainingAmount <= 0) return 0;
    if (daysUntilTarget <= 0) return remainingAmount;
    return remainingAmount / daysUntilTarget;
  }

  // Метод для создания копии объекта с измененными полями
  Goal copyWith({
    int? id,
    String? name,
    int? targetAmount,
    DateTime? createdAt,
    int? currentAmount,
    DateTime? targetDate,
    String? description,
    String? category,
    bool? isArchived,
  }) {
    return Goal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      createdAt: createdAt ?? this.createdAt,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
      description: description ?? this.description,
      category: category ?? this.category,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'target_amount': targetAmount,
    'created_at': createdAt.millisecondsSinceEpoch,
    'current_amount': currentAmount,
    'target_date': targetDate?.millisecondsSinceEpoch,
    'description': description,
    'category': category,
    'is_archived': isArchived ? 1 : 0,
  };

  factory Goal.fromMap(Map<String, dynamic> map) => Goal(
    id: map['id'] as int?,
    name: map['name'] as String,
    targetAmount: map['target_amount'] as int,
    createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    currentAmount: (map['current_amount'] ?? 0) as int,
    targetDate: map['target_date'] != null ? DateTime.fromMillisecondsSinceEpoch(map['target_date'] as int) : null,
    description: (map['description'] ?? '') as String,
    category: (map['category'] ?? 'general') as String,
    isArchived: (map['is_archived'] ?? 0) == 1,
  );
}
