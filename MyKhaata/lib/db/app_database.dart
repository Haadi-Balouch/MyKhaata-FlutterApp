import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._();
  static Database? _database;

  AppDatabase._();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'mykhaata.db');

    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          await db.execute('ALTER TABLE accounts ADD COLUMN balance REAL NOT NULL DEFAULT 0.0');
        }
      },
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon_code INTEGER NOT NULL,
        color_value INTEGER NOT NULL,
        is_expense INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE accounts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
         name TEXT NOT NULL,
         icon_code INTEGER NOT NULL,
         color_value INTEGER NOT NULL,
         balance REAL NOT NULL DEFAULT 0.0
      )
    ''');
    await db.execute('''
    CREATE TABLE transactions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      amount REAL,
      note TEXT,
      category_name TEXT,
      category_icon_code INTEGER,
      category_color_value INTEGER,
      account_name TEXT,
      account_icon_code INTEGER,
      account_color_value INTEGER,
      date TEXT,
      time TEXT,
      is_expense INTEGER,
      timestamp TEXT
    )
  ''');

    await db.execute('''
    CREATE TABLE budgets (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      category_name TEXT,
      limit_amount REAL,
      month INTEGER,
      year INTEGER,
      UNIQUE(category_name, month, year)
    )
  ''');

  }
}