// lib/features/savings/data/repository/savings_repository.dart

import 'package:my_kopilka/core/db/app_database.dart';
import 'package:my_kopilka/features/savings/models/goal.dart';
import 'package:my_kopilka/features/savings/models/transaction.dart';
import 'package:sqflite/sqflite.dart' hide Transaction;

class SavingsRepository {
  final AppDatabase _appDatabase = AppDatabase();

  // --- GOALS ---
  Future<int> addGoal(Goal goal) async {
    final db = await _appDatabase.database;
    return await db.insert('goals', goal.toMap());
  }

  Future<void> updateGoal(Goal goal) async {
    final db = await _appDatabase.database;
    await db.update('goals', goal.toMap(), where: 'id = ?', whereArgs: [goal.id]);
  }

  Future<void> deleteGoal(int id) async {
    final db = await _appDatabase.database;
    await db.delete('goals', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Goal>> getAllGoals() async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query('goals', orderBy: 'created_at DESC');
    return List.generate(maps.length, (i) => Goal.fromMap(maps[i]));
  }

  Future<List<Goal>> getGoalsByCategory(String category) async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'goals',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => Goal.fromMap(maps[i]));
  }

  Future<List<Goal>> getActiveGoals() async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'goals',
      where: 'is_archived = 0',
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => Goal.fromMap(maps[i]));
  }

  Future<List<Goal>> getCompletedGoals() async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT g.*, COALESCE(SUM(t.amount), 0) as current_amount
      FROM goals g
      LEFT JOIN transactions t ON g.id = t.goal_id
      GROUP BY g.id
      HAVING current_amount >= g.target_amount
      ORDER BY g.created_at DESC
    ''');
    return List.generate(maps.length, (i) => Goal.fromMap(maps[i]));
  }
  
  // --- TRANSACTIONS ---
  Future<void> addTransaction(Transaction transaction) async {
    final db = await _appDatabase.database;
    await db.insert('transactions', transaction.toMap());
  }

  Future<void> updateTransaction(Transaction transaction) async {
    final db = await _appDatabase.database;
    await db.update('transactions', transaction.toMap(), where: 'id = ?', whereArgs: [transaction.id]);
  }

  Future<void> deleteTransaction(int id) async {
    final db = await _appDatabase.database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Transaction>> getTransactionsForGoal(int goalId) async {
    final db = await _appDatabase.database;
    final res = await db.query(
      'transactions',
      where: 'goal_id = ?',
      whereArgs: [goalId],
      orderBy: 'created_at DESC',
    );
    return res.map((e) => Transaction.fromMap(e)).toList();
  }

  Future<List<Transaction>> getAllTransactions({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await _appDatabase.database;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (startDate != null) {
      whereClause += 'created_at >= ?';
      whereArgs.add(startDate.millisecondsSinceEpoch);
    }

    if (endDate != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'created_at <= ?';
      whereArgs.add(endDate.millisecondsSinceEpoch);
    }

    final res = await db.query(
      'transactions',
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'created_at DESC',
    );
    return res.map((e) => Transaction.fromMap(e)).toList();
  }

  Future<int> getCurrentSumForGoal(int goalId) async {
    final db = await _appDatabase.database;
    final res = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE goal_id = ?',
      [goalId],
    );
    final value = res.first['total'];
    if (value == null) return 0;
    return value is int ? value : (value as num).toInt();
  }

  // --- ANALYTICS ---
  Future<Map<String, dynamic>> getAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await _appDatabase.database;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (startDate != null || endDate != null) {
      whereClause = 'WHERE ';
      if (startDate != null) {
        whereClause += 't.created_at >= ?';
        whereArgs.add(startDate.millisecondsSinceEpoch);
      }
      if (endDate != null) {
        if (startDate != null) whereClause += ' AND ';
        whereClause += 't.created_at <= ?';
        whereArgs.add(endDate.millisecondsSinceEpoch);
      }
    }

    // Общая статистика
    final totalResult = await db.rawQuery('''
      SELECT 
        COUNT(DISTINCT g.id) as total_goals,
        COALESCE(SUM(CASE WHEN t.amount > 0 THEN t.amount ELSE 0 END), 0) as total_saved,
        COALESCE(SUM(CASE WHEN t.amount < 0 THEN ABS(t.amount) ELSE 0 END), 0) as total_withdrawn,
        COUNT(t.id) as total_transactions
      FROM goals g
      LEFT JOIN transactions t ON g.id = t.goal_id
      $whereClause
    ''', whereArgs);

    // Статистика по категориям
    final categoryResult = await db.rawQuery('''
      SELECT 
        g.category,
        COUNT(DISTINCT g.id) as goal_count,
        COALESCE(SUM(CASE WHEN t.amount > 0 THEN t.amount ELSE 0 END), 0) as saved,
        COALESCE(SUM(g.target_amount), 0) as target
      FROM goals g
      LEFT JOIN transactions t ON g.id = t.goal_id
      $whereClause
      GROUP BY g.category
    ''', whereArgs);

    // Статистика по типам транзакций
    final transactionTypeResult = await db.rawQuery('''
      SELECT 
        t.category,
        COUNT(*) as count,
        SUM(ABS(t.amount)) as total_amount
      FROM transactions t
      ${whereClause.replaceAll('g.', 't.')}
      GROUP BY t.category
      ORDER BY total_amount DESC
    ''', whereArgs);

    return {
      'total': totalResult.first,
      'categories': categoryResult,
      'transactionTypes': transactionTypeResult,
    };
  }

  Future<List<Map<String, dynamic>>> getDailyProgress({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = await _appDatabase.database;
    
    final result = await db.rawQuery('''
      SELECT 
        DATE(t.created_at / 1000, 'unixepoch') as date,
        SUM(CASE WHEN t.amount > 0 THEN t.amount ELSE 0 END) as deposits,
        SUM(CASE WHEN t.amount < 0 THEN ABS(t.amount) ELSE 0 END) as withdrawals,
        COUNT(*) as transaction_count
      FROM transactions t
      WHERE t.created_at >= ? AND t.created_at <= ?
      GROUP BY DATE(t.created_at / 1000, 'unixepoch')
      ORDER BY date
    ''', [startDate.millisecondsSinceEpoch, endDate.millisecondsSinceEpoch]);

    return result;
  }

  Future<List<Map<String, dynamic>>> getTopGoalsByProgress() async {
    final db = await _appDatabase.database;
    
    final result = await db.rawQuery('''
      SELECT 
        g.*,
        COALESCE(SUM(t.amount), 0) as current_amount,
        CASE 
          WHEN g.target_amount > 0 THEN CAST(COALESCE(SUM(t.amount), 0) AS REAL) / g.target_amount
          ELSE 0 
        END as progress
      FROM goals g
      LEFT JOIN transactions t ON g.id = t.goal_id
      WHERE g.is_archived = 0
      GROUP BY g.id
      ORDER BY progress DESC, g.created_at DESC
      LIMIT 10
    ''');

    return result;
  }

  // --- SEARCH ---
  Future<List<Goal>> searchGoals(String query) async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'goals',
      where: 'name LIKE ? OR description LIKE ? OR category LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => Goal.fromMap(maps[i]));
  }

  Future<List<Transaction>> searchTransactions(String query) async {
    final db = await _appDatabase.database;
    final res = await db.rawQuery('''
      SELECT t.* FROM transactions t
      JOIN goals g ON t.goal_id = g.id
      WHERE t.notes LIKE ? OR g.name LIKE ?
      ORDER BY t.created_at DESC
    ''', ['%$query%', '%$query%']);
    return res.map((e) => Transaction.fromMap(e)).toList();
  }

  // --- SETTINGS ---
  Future<void> setSetting(String key, String value) async {
    final db = await _appDatabase.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.insert(
      'settings',
      {
        'key': key,
        'value': value,
        'created_at': now,
        'updated_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getSetting(String key) async {
    final db = await _appDatabase.database;
    final result = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    
    if (result.isNotEmpty) {
      return result.first['value'] as String?;
    }
    return null;
  }

  Future<void> deleteSetting(String key) async {
    final db = await _appDatabase.database;
    await db.delete('settings', where: 'key = ?', whereArgs: [key]);
  }

  // --- BACKUP / EXPORT ---
  Future<Map<String, dynamic>> exportData() async {
    final goals = await getAllGoals();
    final transactions = await getAllTransactions();
    
    return {
      'version': '2.0.0',
      'export_date': DateTime.now().toIso8601String(),
      'goals': goals.map((g) => g.toMap()).toList(),
      'transactions': transactions.map((t) => t.toMap()).toList(),
    };
  }

  Future<void> importData(Map<String, dynamic> data) async {
    final db = await _appDatabase.database;
    
    // Начинаем транзакцию
    await db.transaction((txn) async {
      // Очищаем существующие данные
      await txn.delete('transactions');
      await txn.delete('goals');
      
      // Импортируем цели
      if (data['goals'] != null) {
        for (final goalData in data['goals']) {
          await txn.insert('goals', goalData);
        }
      }
      
      // Импортируем транзакции
      if (data['transactions'] != null) {
        for (final transactionData in data['transactions']) {
          await txn.insert('transactions', transactionData);
        }
      }
    });
  }
}
