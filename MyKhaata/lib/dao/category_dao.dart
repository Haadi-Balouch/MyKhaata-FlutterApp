  import '../db/app_database.dart';
  import '../models/category_item.dart';

  class CategoryDAO {
    final db = AppDatabase.instance;

    // Get all categories filtered by type (income/expense)
    Future<List<CategoryItem>> getAll(bool isExpense) async {
      final database = await db.database;
      final result = await database.query(
        'categories',
        where: 'is_expense = ?',
        whereArgs: [isExpense ? 1 : 0],
        orderBy: 'name ASC',
      );
      return result.map((e) => CategoryItem.fromMap(e)).toList();
    }

    // Get all categories (both income and expense)
    Future<List<CategoryItem>> getAllCategories() async {
      final database = await db.database;
      final result = await database.query(
        'categories',
        orderBy: 'name ASC',
      );
      return result.map((e) => CategoryItem.fromMap(e)).toList();
    }

    // Get category by ID
    Future<CategoryItem?> getById(int id) async {
      final database = await db.database;
      final result = await database.query(
        'categories',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (result.isEmpty) return null;
      return CategoryItem.fromMap(result.first);
    }

    // Get category by name
    Future<CategoryItem?> getByName(String name, bool isExpense) async {
      final database = await db.database;
      final result = await database.query(
        'categories',
        where: 'name = ? AND is_expense = ?',
        whereArgs: [name, isExpense ? 1 : 0],
      );
      if (result.isEmpty) return null;
      return CategoryItem.fromMap(result.first);
    }

    // Check if categories table is empty
    Future<bool> isEmpty() async {
      final database = await db.database;
      final result = await database.query('categories');
      return result.isEmpty;
    }

    // Count categories by type
    Future<int> count(bool isExpense) async {
      final database = await db.database;
      final result = await database.rawQuery(
        'SELECT COUNT(*) as count FROM categories WHERE is_expense = ?',
        [isExpense ? 1 : 0],
      );
      return result.first['count'] as int;
    }

    // Insert new category
    Future<int> insert(CategoryItem category) async {
      final database = await db.database;
      return await database.insert(
        'categories',
        category.toMap(),
      );
    }

    // Update existing category
    Future<int> update(CategoryItem category) async {
      final database = await db.database;
      return await database.update(
        'categories',
        category.toMap(),
        where: 'id = ?',
        whereArgs: [category.id],
      );
    }

    // Delete category by ID
    Future<int> delete(int id) async {
      final database = await db.database;
      return await database.delete(
        'categories',
        where: 'id = ?',
        whereArgs: [id],
      );
    }

    // Delete all categories
    Future<int> deleteAll() async {
      final database = await db.database;
      return await database.delete('categories');
    }

    // Check if category name already exists
    Future<bool> nameExists(String name, bool isExpense, {int? excludeId}) async {
      final database = await db.database;
      String whereClause = 'name = ? AND is_expense = ?';
      List<dynamic> whereArgs = [name, isExpense ? 1 : 0];

      if (excludeId != null) {
        whereClause += ' AND id != ?';
        whereArgs.add(excludeId);
      }

      final result = await database.query(
        'categories',
        where: whereClause,
        whereArgs: whereArgs,
      );
      return result.isNotEmpty;
    }

    // Search categories by name
    Future<List<CategoryItem>> search(String query, bool isExpense) async {
      final database = await db.database;
      final result = await database.query(
        'categories',
        where: 'name LIKE ? AND is_expense = ?',
        whereArgs: ['%$query%', isExpense ? 1 : 0],
        orderBy: 'name ASC',
      );
      return result.map((e) => CategoryItem.fromMap(e)).toList();
    }
  }