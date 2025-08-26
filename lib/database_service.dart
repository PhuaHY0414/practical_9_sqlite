import 'dart:developer';
import 'package:practical_9_sqlite/mood_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService{
  static final DatabaseService _databaseService = DatabaseService._internal();
  factory DatabaseService() => _databaseService;
  DatabaseService._internal();
  static Database? _database;

  //Get an instance of database
  Future<Database> get database async {
    if(_database != null) return _database!;
    _database = await initDatabase();
    return _database!;

  }

  Future<Database> initDatabase() async {
    final getDirectory =  await getApplicationDocumentsDirectory();
    String path = '${getDirectory.path}/moods.db';
    log(path);
    return await openDatabase(path, onCreate: _onCreate, version: 1);
  }

  void _onCreate(Database db, int version) async {
    await db.execute(
      'CREATE TABLE Moods('
          'id INTEGER PRIMARY KEY AUTOINCREMENT,'
          'scale INTEGER, '
          'description TEXT, '
          'createdOn DATeTIME DEFAULT CURRENT_TIMESTAMP)'
    );
    log('Table Created');
  }

  Future<List<MoodModel>> getMood() async{
    final db = await _databaseService.database;
    var data = await db.query('Moods');
    List<MoodModel> moods =
        List.generate(data.length, (index) => MoodModel.fromJson(data[index]));
    print(moods.length);
    return moods;
  }

  Future<void> insertMood(MoodModel mood) async {
    final db = await _databaseService.database;
    var data = await db.rawInsert(
        'INSERT INTO Moods(scale, description) VALUES(?,?)',
        [mood.scale, mood.description]
    );
    log('inserted $data');
  }

  Future<void> editMood(MoodModel mood) async {
    final db = await _databaseService.database;
    var data = await db.update(
      'Moods',
      mood.toMap(),
      where: 'id = ?',
      whereArgs: [mood.id],
    );
    log('updated $data');
  }

  Future<void> deleteMood(int id) async {
    final db = await _databaseService.database;
    var data = await db.delete(
      'Moods',
      where: 'id = ?',
      whereArgs: [id],
        );
    log('deleted $data');
  }
}