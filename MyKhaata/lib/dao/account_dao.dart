import '../db/app_database.dart';
import '../models/account_item.dart';

class AccountDAO {
  final db = AppDatabase.instance;

  // Get all accounts
  Future<List<AccountItem>> getAll() async {
    final database = await db.database;
    final result = await database.query(
      'accounts',
      orderBy: 'name ASC',
    );
    return result.map((e) => AccountItem.fromMap(e)).toList();
  }

  // Get account by ID
  Future<AccountItem?> getById(int id) async {
    final database = await db.database;
    final result = await database.query(
      'accounts',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return AccountItem.fromMap(result.first);
  }

  // Get account by name
  Future<AccountItem?> getByName(String name) async {
    final database = await db.database;
    final result = await database.query(
      'accounts',
      where: 'name = ?',
      whereArgs: [name],
    );
    if (result.isEmpty) return null;
    return AccountItem.fromMap(result.first);
  }

  // Check if accounts table is empty
  Future<bool> isEmpty() async {
    final database = await db.database;
    final result = await database.query('accounts');
    return result.isEmpty;
  }

  // Count total accounts
  Future<int> count() async {
    final database = await db.database;
    final result = await database.rawQuery(
      'SELECT COUNT(*) as count FROM accounts',
    );
    return result.first['count'] as int;
  }

  // Insert new account
  Future<int> insert(AccountItem account) async {
    final database = await db.database;
    return await database.insert(
      'accounts',
      account.toMap(),
    );
  }

  // Update existing account
  Future<int> update(AccountItem account) async {
    final database = await db.database;
    return await database.update(
      'accounts',
      account.toMap(),
      where: 'id = ?',
      whereArgs: [account.id],
    );
  }

  // Delete account by ID
  Future<int> delete(int id) async {
    final database = await db.database;
    return await database.delete(
      'accounts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete all accounts
  Future<int> deleteAll() async {
    final database = await db.database;
    return await database.delete('accounts');
  }

  // Check if account name already exists
  Future<bool> nameExists(String name, {int? excludeId}) async {
    final database = await db.database;
    String whereClause = 'name = ?';
    List<dynamic> whereArgs = [name];

    if (excludeId != null) {
      whereClause += ' AND id != ?';
      whereArgs.add(excludeId);
    }

    final result = await database.query(
      'accounts',
      where: whereClause,
      whereArgs: whereArgs,
    );
    return result.isNotEmpty;
  }

  // Search accounts by name
  Future<List<AccountItem>> search(String query) async {
    final database = await db.database;
    final result = await database.query(
      'accounts',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'name ASC',
    );
    return result.map((e) => AccountItem.fromMap(e)).toList();
  }

  // Batch insert multiple accounts
  Future<void> insertBatch(List<AccountItem> accounts) async {
    final database = await db.database;
    final batch = database.batch();

    for (var account in accounts) {
      batch.insert('accounts', account.toMap());
    }

    await batch.commit(noResult: true);
  }

  // Get accounts with custom sorting
  Future<List<AccountItem>> getAllSorted({bool ascending = true}) async {
    final database = await db.database;
    final result = await database.query(
      'accounts',
      orderBy: 'name ${ascending ? 'ASC' : 'DESC'}',
    );
    return result.map((e) => AccountItem.fromMap(e)).toList();
  }
}