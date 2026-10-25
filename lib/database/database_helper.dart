import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
CREATE TABLE users(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  password TEXT NOT NULL
)
''');

    await db.execute('''
CREATE TABLE scores(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT NOT NULL,
  score INTEGER NOT NULL,
  wave INTEGER NOT NULL,
  created_at TEXT NOT NULL
)
''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
CREATE TABLE IF NOT EXISTS scores(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT NOT NULL,
  score INTEGER NOT NULL,
  wave INTEGER NOT NULL,
  created_at TEXT NOT NULL
)
''');
    }
  }

  Future<int> registerUser(
    String username,
    String email,
    String password,
  ) async {
    final db = await instance.database;

    return await db.insert('users', {
      'username': username,
      'email': email,
      'password': password,
    });
  }

  Future<Map<String, dynamic>?> loginUser(
    String email,
    String password,
  ) async {
    final db = await instance.database;

    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (result.isNotEmpty) {
      return result.first;
    }

    return null;
  }

  Future<int> saveScore({
    required String username,
    required int score,
    required int wave,
  }) async {
    final db = await instance.database;

    return await db.insert('scores', {
      'username': username,
      'score': score,
      'wave': wave,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getTopScores() async {
    final db = await instance.database;

    return await db.query(
      'scores',
      orderBy: 'score DESC',
      limit: 10,
    );
  }
}