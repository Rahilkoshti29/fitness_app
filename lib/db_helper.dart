import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:fitness_app/models.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _db;
  DBHelper._init();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB('fitness.db');
    return _db!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE workouts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        type TEXT NOT NULL,
        duration INTEGER NOT NULL,
        calories INTEGER NOT NULL,
        steps INTEGER NOT NULL DEFAULT 0,
        notes TEXT DEFAULT ''
      )
    ''');
    await db.execute('''
      CREATE TABLE nutrition (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        meal TEXT NOT NULL,
        food TEXT NOT NULL,
        calories INTEGER NOT NULL,
        protein REAL DEFAULT 0,
        carbs REAL DEFAULT 0,
        fat REAL DEFAULT 0
      )
    ''');

    // Seed sample data for the past 7 days
    final now = DateTime.now();
    final types = ['Running', 'Cycling', 'HIIT', 'Yoga', 'Walking', 'Weightlifting'];
    for (int i = 6; i >= 1; i--) {
      final d = now.subtract(Duration(days: i));
      final dateStr =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      await db.insert('workouts', {
        'date': dateStr,
        'type': types[i % types.length],
        'duration': 20 + i * 5,
        'calories': 150 + i * 40,
        'steps': 3000 + i * 900,
        'notes': '',
      });
    }
  }

  // ── WORKOUTS ──────────────────────────────────────────────
  Future<List<WorkoutLog>> getAllWorkouts() async {
    final db = await database;
    final maps = await db.query('workouts', orderBy: 'date DESC, id DESC');
    return maps.map(WorkoutLog.fromMap).toList();
  }

  Future<List<WorkoutLog>> getWorkoutsByDate(String date) async {
    final db = await database;
    final maps =
    await db.query('workouts', where: 'date = ?', whereArgs: [date]);
    return maps.map(WorkoutLog.fromMap).toList();
  }

  Future<List<WorkoutLog>> getWorkoutsLastNDays(int n) async {
    final db = await database;
    final cutoff = DateTime.now().subtract(Duration(days: n));
    final cutoffStr =
        '${cutoff.year}-${cutoff.month.toString().padLeft(2, '0')}-${cutoff.day.toString().padLeft(2, '0')}';
    final maps = await db.query('workouts',
        where: 'date >= ?', whereArgs: [cutoffStr], orderBy: 'date ASC');
    return maps.map(WorkoutLog.fromMap).toList();
  }

  Future<int> insertWorkout(WorkoutLog w) async {
    final db = await database;
    return await db.insert('workouts', w.toMap());
  }

  Future<void> deleteWorkout(int id) async {
    final db = await database;
    await db.delete('workouts', where: 'id = ?', whereArgs: [id]);
  }

  // ── NUTRITION ─────────────────────────────────────────────
  Future<List<NutritionLog>> getNutritionByDate(String date) async {
    final db = await database;
    final maps =
    await db.query('nutrition', where: 'date = ?', whereArgs: [date]);
    return maps.map(NutritionLog.fromMap).toList();
  }

  Future<int> insertNutrition(NutritionLog n) async {
    final db = await database;
    return await db.insert('nutrition', n.toMap());
  }

  Future<void> deleteNutrition(int id) async {
    final db = await database;
    await db.delete('nutrition', where: 'id = ?', whereArgs: [id]);
  }
}