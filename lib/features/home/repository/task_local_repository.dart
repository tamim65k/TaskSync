import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:task_offline_first/models/task_model.dart';
import 'package:task_offline_first/models/user_model.dart';

class TaskLocalRepository {
  String tableName = "tasks";

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
    final path = join(dbPath, "tasks.db");
    return openDatabase(
      path,
      version: 3,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE $tableName ADD COLUMN uid TEXT NOT NULL DEFAULT ""',
          );
        }
        if (oldVersion < 3) {
          await db.execute(
            'ALTER TABLE $tableName ADD COLUMN hexColor TEXT NOT NULL DEFAULT ""',
          );
          await db.execute(
            'ALTER TABLE $tableName ADD COLUMN isSynced INTEGER NOT NULL DEFAULT 0',
          );
        }
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName(
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            uid TEXT NOT NULL,
            dueAt TEXT NOT NULL,
            hexColor TEXT NOT NULL,
            createdAt TEXT NOT NULL,
            updatedAt TEXT NOT NULL,
            isSynced INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> insertTask(TaskModel taskModel) async {
    final db = await database; // call the db getter, not initDB
    await db.delete(tableName, where: 'id = ?', whereArgs: [taskModel.id]);
    await db.insert(tableName, taskModel.toMap());
  }

  Future<void> insertTasks(List<TaskModel> taskModel) async {
    final db = await database; // call the db getter, not initDB

    final batch = db.batch();
    for (final task in taskModel) {
      batch.insert(
        tableName,
        task.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<List<TaskModel>> getTasks() async {
    final db = await database;

    final result = await db.query(tableName);
    if (result.isNotEmpty) {
      List<TaskModel> tasks = [];
      for (final task in result) {
        tasks.add(TaskModel.fromMap(task));
      }
      return tasks;
    }

    return [];
  }

  Future<List<TaskModel>> getUnsyncedTasks() async {
    final db = await database;
    final result = await db.query(
      tableName,
      where: 'isSynced = ?',
      whereArgs: [0],
    );

    if (result.isNotEmpty) {
      List<TaskModel> tasks = [];
      for (final task in result) {
        tasks.add(TaskModel.fromMap(task));
      }
      return tasks;
    }
    return [];
  }

  Future<void> updateSyncedTasks(String id, int newValue) async {
    final db = await database;
    await db.update(
      tableName,
      {"isSynced": newValue},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
