import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('alarms.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 3, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE alarms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        time TEXT,
        amPm TEXT,
        days TEXT NOT NULL,
        isActive INTEGER NOT NULL,
        ringtone TEXT NOT NULL,
        isLocation INTEGER NOT NULL DEFAULT 0, -- 0 لمنبه الوقت، 1 لمنبه الموقع
        latitude REAL, -- خط الطول (للموقع فقط)
        longitude REAL, -- دائرة العرض (للموقع فقط)
        radius REAL -- نصف قطر الدائرة (للموقع فقط)
      )
    ''');
  }

  Future<int> insertAlarm(Map<String, dynamic> alarm) async {
    final db = await instance.database;
    return await db.insert('alarms', alarm);
  }

  Future<List<Map<String, dynamic>>> getTimeAlarms() async {
    final db = await instance.database;
    return await db.query('alarms', where: 'isLocation = ?', whereArgs: [0], orderBy: 'id DESC');
  }

  Future<List<Map<String, dynamic>>> getLocationAlarms() async {
    final db = await instance.database;
    return await db.query('alarms', where: 'isLocation = ?', whereArgs: [1], orderBy: 'id DESC');
  }

  Future<int> updateAlarmStatus(int id, int isActive) async {
    final db = await instance.database;
    return await db.update('alarms', {'isActive': isActive}, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteAlarm(int id) async {
    final db = await instance.database;
    return await db.delete('alarms', where: 'id = ?', whereArgs: [id]);
  }
}