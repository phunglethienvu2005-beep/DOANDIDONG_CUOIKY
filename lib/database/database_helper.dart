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
      version: 3,
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

    await db.execute('''
CREATE TABLE run_history(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT NOT NULL,
  title TEXT NOT NULL,
  distance REAL NOT NULL,
  steps INTEGER NOT NULL,
  calories INTEGER NOT NULL,
  duration TEXT NOT NULL,
  avg_speed REAL NOT NULL,
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
    if (oldVersion < 3) {
      await db.execute('''
CREATE TABLE IF NOT EXISTS run_history(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT NOT NULL,
  title TEXT NOT NULL,
  distance REAL NOT NULL,
  steps INTEGER NOT NULL,
  calories INTEGER NOT NULL,
  duration TEXT NOT NULL,
  avg_speed REAL NOT NULL,
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

  // ── Lịch sử chạy (Run History) ─────────────────────────
  Future<int> insertRun({
    required String username,
    required String title,
    required double distance,
    required int steps,
    required int calories,
    required String duration,
    required double avgSpeed,
    String? createdAt,
  }) async {
    final db = await instance.database;

    return await db.insert('run_history', {
      'username': username,
      'title': title,
      'distance': distance,
      'steps': steps,
      'calories': calories,
      'duration': duration,
      'avg_speed': avgSpeed,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getRunHistory(String username) async {
    final db = await instance.database;

    final results = await db.query(
      'run_history',
      where: 'username = ?',
      whereArgs: [username],
      orderBy: 'created_at DESC',
    );

    // Nếu người dùng chưa có lịch sử chạy nào, khởi tạo sẵn vài dữ liệu mẫu thực tế
    if (results.isEmpty) {
      final now = DateTime.now();
      final sampleRuns = [
        {
          'username': username,
          'title': 'Chạy bộ buổi sáng 🌅',
          'distance': 3.45,
          'steps': 4310,
          'calories': 172,
          'duration': '25 phút',
          'avg_speed': 8.3,
          'created_at': now.subtract(const Duration(hours: 3)).toIso8601String(),
        },
        {
          'username': username,
          'title': 'Đi bộ công viên 🌳',
          'distance': 2.10,
          'steps': 2625,
          'calories': 105,
          'duration': '22 phút',
          'avg_speed': 5.7,
          'created_at': now.subtract(const Duration(days: 1, hours: 2)).toIso8601String(),
        },
        {
          'username': username,
          'title': 'Chạy bền rèn thể lực 🏃',
          'distance': 5.20,
          'steps': 6500,
          'calories': 260,
          'duration': '38 phút',
          'avg_speed': 8.2,
          'created_at': now.subtract(const Duration(days: 3, hours: 4)).toIso8601String(),
        },
        {
          'username': username,
          'title': 'Đi bộ chiều nhẹ nhàng 🚶',
          'distance': 1.50,
          'steps': 1875,
          'calories': 75,
          'duration': '18 phút',
          'avg_speed': 5.0,
          'created_at': now.subtract(const Duration(days: 5, hours: 1)).toIso8601String(),
        },
      ];

      for (final run in sampleRuns) {
        await db.insert('run_history', run);
      }

      return await db.query(
        'run_history',
        where: 'username = ?',
        whereArgs: [username],
        orderBy: 'created_at DESC',
      );
    }

    return results;
  }

  Future<int> deleteRun(int id) async {
    final db = await instance.database;
    return await db.delete('run_history', where: 'id = ?', whereArgs: [id]);
  }
}