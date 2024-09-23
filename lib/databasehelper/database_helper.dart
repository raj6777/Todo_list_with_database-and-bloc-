import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final path = await getDatabasesPath();
    final dbPath = join(path, 'todo.db');

    return await openDatabase(
      dbPath,
      version: 1, // Increment version number
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE todos (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          description TEXT,
          date TEXT,
          isChecked INTEGER DEFAULT 0
        )
        ''');
      },
    );
  }

  Future<int> addTodo(
      String title, String description, String date, bool isChecked) async {
    final db = await database;
    return await db.insert(
      'todos',
      {
        'title': title,
        'description': description,
        'date': date,
        'isChecked': isChecked ? 1 : 0
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deleteTodo(int id) async {
    final db = await database;
    return await db.delete(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getTodos() async {
    final db = await database;
    return await db.query('todos');
  }

  Future<Map<String, dynamic>> getTodoById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return result.first;
    } else {
      throw Exception('Todo not found');
    }
  }

  Future<int> updateTodo(int id, String title, String description, String date,
      int isChecked) async {
    final db = await database;
    return await db.update(
      'todos',
      {
        'title': title,
        'description': description,
        'date': date,
        'isChecked': isChecked
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
