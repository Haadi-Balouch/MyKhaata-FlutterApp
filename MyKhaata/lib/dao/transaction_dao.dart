import '../db/app_database.dart';
import '../models/transaction_item.dart';

class TransactionDAO {
  final db = AppDatabase.instance;

  Future<List<TransactionItem>> getAll() async {
    final database = await db.database;
    final result = await database.query('transactions', orderBy: 'timestamp DESC');
    return result.map((e) => TransactionItem.fromMap(e)).toList();
  }

  Future<List<TransactionItem>> getTransactionsByMonth(int year, int month) async {
    final database = await db.database;
    final result = await database.query(
      'transactions',
      orderBy: 'timestamp DESC',
    );

    return result
        .map((e) => TransactionItem.fromMap(e))
        .where((t) => t.timestamp.year == year && t.timestamp.month == month)
        .toList();
  }

  Future<void> insert(TransactionItem transaction) async {
    final database = await db.database;
    await database.insert('transactions', transaction.toMap());
  }

  Future<void> delete(int id) async {
    final database = await db.database;
    await database.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  Future<void> update(TransactionItem transaction) async {
    final database = await db.database;
    await database.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }
  Future<void> deleteAll() async {
    final database = await db.database;
    await database.delete('transactions');
  }

}