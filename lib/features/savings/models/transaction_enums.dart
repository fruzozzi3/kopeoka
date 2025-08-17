// lib/features/savings/models/transaction_enums.dart

enum TransactionType {
  income,
  expense,
}

enum TransactionCategory {
  cash,
  card,
  bankTransfer,
  other,
}

extension TransactionCategoryExtension on TransactionCategory {
  String get displayName {
    switch (this) {
      case TransactionCategory.cash:
        return 'Наличные';
      case TransactionCategory.card:
        return 'Карта';
      case TransactionCategory.bankTransfer:
        return 'Банковский перевод';
      case TransactionCategory.other:
        return 'Другое';
    }
  }
}
