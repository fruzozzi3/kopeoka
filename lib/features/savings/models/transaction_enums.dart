enum TransactionType {
  income,
  expense,
}

enum TransactionCategory {
  cash,
  card,
  transfer,
  savings,
  investment,
  gift,
  other;
  
  String get displayName {
    switch (this) {
      case TransactionCategory.cash:
        return 'Наличные';
      case TransactionCategory.card:
        return 'Карта';
      case TransactionCategory.transfer:
        return 'Перевод';
      case TransactionCategory.savings:
        return 'Накопления';
      case TransactionCategory.investment:
        return 'Инвестиции';
      case TransactionCategory.gift:
        return 'Подарок';
      case TransactionCategory.other:
        return 'Другое';
    }
  }
}
