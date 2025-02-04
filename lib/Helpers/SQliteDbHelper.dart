import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../Models/CourseModel.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'courses_database.db');
    
    // حذف قاعدة البيانات القديمة
    await deleteDatabase(path);
    
    return await openDatabase(
      path,
      version: 2, // زيادة رقم الإصدار
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE courses(
        id INTEGER PRIMARY KEY,
        owner TEXT,
        title TEXT,
        subject TEXT,
        overview TEXT,
        photo TEXT,
        total_students INTEGER,
        total_modules INTEGER,
        created TEXT
      )
    ''');
  }

  Future<List<CourseModel>> getCourses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('courses');
    return List.generate(maps.length, (i) => CourseModel.fromMap(maps[i]));
  }

  Future<void> insertCourse(CourseModel course) async {
    final db = await database;
    await db.insert(
      'courses',
      course.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateCourse(CourseModel course) async {
    final db = await database;
    await db.update(
      'courses',
      course.toMap(),
      where: 'id = ?',
      whereArgs: [course.id],
    );
  }

  Future<void> deleteCourse(int id) async {
    final db = await database;
    await db.delete(
      'courses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}