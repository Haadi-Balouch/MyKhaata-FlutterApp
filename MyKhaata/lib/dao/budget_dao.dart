import '../db/app_database.dart';
import '../models/budget_item.dart';
import 'package:sqflite/sqflite.dart';


class BudgetDAO {
  final db = AppDatabase.instance;

  Future<List<BudgetItem>> getBudgetsByMonth(int year, int month) async {
    final database = await db.database;
    final result = await database.query(
      'budgets',
      where: 'year = ? AND month = ?',
      whereArgs: [year, month],
    );
    return result.map((e) => BudgetItem.fromMap(e)).toList();
  }

  Future<void> insert(BudgetItem budget) async {
    final database = await db.database;
    await database.insert(
      'budgets',
      budget.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> update(int id, double newLimit) async {
    final database = await db.database;
    await database.update(
      'budgets',
      {'limit_amount': newLimit},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  Future<void> deleteAll() async {
    final database = await db.database;
    await database.delete('budgets');
  }
  Future<void> delete(int id) async {
    final database = await db.database;
    await database.delete(
      'budgets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}