import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:task_offline_first/models/user_model.dart';

class AuthLocalRepository {
  String tableName = "users";

  Database? _database;

  Future<Database> get database async {
    // DATABASE getter for initial database
    if (_database != null) {
      return _database!;
    }

    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, "auth.db");
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE $tableName(
          id TEXT PRIMARY KEY,
          email TEXT NOT NULL,
          token TEXT NOT NULL,
          name TEXT NOT NULL,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL
          )
''');
      },
    );
  }

  Future<void> insertUser(UserModel userModel) async {
    final db = await database; // call the db getter, not initDB

    await db.insert(
      tableName,
      userModel.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserModel?> getUser() async {
    final db = await database;

    final result = await db.query(tableName, limit: 1);
    if (result.isNotEmpty) {
      return UserModel.fromMap(result.first);
    }

    return null;
  }


}
