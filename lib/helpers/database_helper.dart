import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/movie.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('filmes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE movies (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        urlImage TEXT,
        title TEXT,
        genre TEXT,
        ageRating TEXT,
        duration TEXT,
        score REAL,
        description TEXT,
        year INTEGER
      )
    ''');
  }

  Future<int> create(Movie movie) async {
    final db = await instance.database;
    return await db.insert('movies', movie.toMap());
  }

  Future<List<Movie>> readAllMovies() async {
    final db = await instance.database;
    final result = await db.query('movies');

    return result.map((json) => Movie.fromMap(json)).toList();
  }

  Future<int> update(Movie movie) async {
    final db = await instance.database;
    return db.update(
      'movies',
      movie.toMap(),
      where: 'id = ?',
      whereArgs: [movie.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      'movies',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}