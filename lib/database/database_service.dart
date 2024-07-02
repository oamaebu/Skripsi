import 'package:app/models/Anak.dart';
import 'package:app/models/isi_gambar.dart';
import 'package:app/models/tema.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._instance();
  static Database? _db;

  DatabaseHelper._instance();

  // ANAK Table
  String anakTable = 'Anak';
  String anakColId = 'id';
  String anakColNama = 'nama';
  String anakColUmur = 'umur';
  String anakColKelas = 'kelas';
  String anakColKelamin = 'kelamin';

  // GAME Table
  String gameTable = 'skema';
  String gameColId = 'id';
  String gameColNamaGame = 'namaskema';

  // GAME Table
  String TemaTable = 'Tema';
  String TemaColId = 'id';
  String TemaColInamaTema = 'namaTema';
   String TemaColStatus = 'status';

  // PUZZLE Table
  String puzzleTable = 'puzzle';
  String puzzleColId = 'id';
  String puzzleColLevel = 'level';
  String puzzleColKelas = 'kelas';
  String puzzleColIdGame = 'id_game';
  String puzzleColGambarBenar = 'GambarBenar';
  String puzzleColIdGambarSalah1 = 'GambarSalah1';
  String puzzleColIdGambarSalah2 = 'GambarSalah2';

  String gambarTable = 'IsiGambar';
  String gambarColId = 'id';
  String gambarColLIDtema = 'id_tema';
  String gambarColLabel = 'label';
  String gambarColTingkatKesulitan = 'TingkatKesulitan';
  String gambarColgambar1 = 'Gambar1';
  String gambarColgambar2 = 'Gambar2';
  String gambarColIdgambar3 = 'Gambar3';
  String gambarColIdSuara = 'suara';
  String gambarColIdStatus = 'Status';


  // GARIS Table
  String garisTable = 'garis';
  String garisColId = 'id';
  String garisColLevel = 'level';
  String garisColKelas = 'kelas';
  String garisColContent = 'content';
  String garisColIdGame = 'id_game';

  // GAME_STATE Table
  String gameStateTable = 'game_state';
  String gameStateColId = 'id';
  String gameStateColIdGame = 'id_game';
  String gameStateColIdAnak = 'id_anak';
  String gameStateColWaktu = 'waktu';
  String gameStateColTanggal = 'tanggal';
  String gameStateColSalah = 'jumlah_salah';

  Future<Database> get db async {
    if (_db == null) {
      _db = await _initDb();
    }
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'child.db');

    final childDb = await openDatabase(
      path,
      version: 2,
      onCreate: _createDb,
      onUpgrade: _upgradeDb,
    );
    return childDb;
  }

  void _createDb(Database db, int version) async {
    await db.execute(
      'CREATE TABLE $anakTable($anakColId INTEGER PRIMARY KEY, $anakColNama TEXT, $anakColUmur INTEGER, $anakColKelas TEXT, $anakColKelamin TEXT)',
    );
    await db.execute(
        'CREATE TABLE users(id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT, password TEXT)');
    await db.execute(
      'CREATE TABLE $gameTable($gameColId INTEGER PRIMARY KEY, $gameColNamaGame TEXT)',
    );
    await db.execute(
      'CREATE TABLE $puzzleTable($puzzleColId INTEGER PRIMARY KEY, $puzzleColLevel INTEGER, $puzzleColKelas TEXT , $puzzleColGambarBenar TEXT, $puzzleColIdGambarSalah1 TEXT, $puzzleColIdGambarSalah2 TEXT, $puzzleColIdGame INTEGER, FOREIGN KEY ($puzzleColIdGame) REFERENCES $gameTable ($gameColId))',
    );
    await db.execute(
      'CREATE TABLE $gambarTable('
      '$gambarColId INTEGER PRIMARY KEY, '
      '$gambarColLabel TEXT, '
      '$gambarColLIDtema INTEGER, '
      '$gambarColTingkatKesulitan TEXT, '
      '$gambarColgambar1 TEXT, '
      '$gambarColgambar2 TEXT, '
      '$gambarColIdgambar3 TEXT, '
      '$gambarColIdSuara TEXT, '
      '$gambarColIdStatus BOOLEAN, '
      
      'FOREIGN KEY ($gambarColLIDtema) REFERENCES $TemaTable ($TemaColId)'
      ')',
    );

    await db.execute(
      'CREATE TABLE $garisTable($garisColId INTEGER PRIMARY KEY, $garisColLevel INTEGER, $garisColKelas TEXT, $garisColContent TEXT, $garisColIdGame INTEGER, FOREIGN KEY ($garisColIdGame) REFERENCES $gameTable ($gameColId))',
    );
    await db.execute(
        'CREATE TABLE $TemaTable($TemaColId INTEGER PRIMARY KEY, $TemaColInamaTema TEXT, $TemaColStatus BOOLEAN)');
    await db.execute(
      'CREATE TABLE $gameStateTable($gameStateColId INTEGER PRIMARY KEY, $gameStateColTanggal TEXT, $gameStateColIdGame INTEGER , $gameStateColSalah INTEGER, $gameStateColWaktu TIME, $gameStateColIdAnak INTEGER, FOREIGN KEY ($gameStateColIdGame) REFERENCES $gameTable ($gameColId), FOREIGN KEY ($gameStateColIdAnak) REFERENCES $anakTable ($anakColId))',
    );
  }

  void _upgradeDb(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {}
  }

  // CRUD Operations for ANAnK Table
  Future<List<Anak>> getAnakMapList() async {
    final db = await this.db;
    final List<Map<String, dynamic>> result = await db.query(anakTable);
    final List<Anak> anakList = [];
    result.forEach((anakMap) {
      anakList.add(Anak.fromMap(anakMap));
    });
    return anakList;
  }

  Future<IsiGambar?> getIsiGambarById(int id) async {
    final db = await this.db;
    final maps = await db.query(
      gambarTable,
      columns: [
        gambarColId,
        gambarColLIDtema,
        gambarColLabel,
        gambarColTingkatKesulitan,
        gambarColgambar1,
        gambarColgambar2,
        gambarColIdgambar3,
        gambarColIdStatus,
        gambarColIdSuara,
      ],
      where: '$gambarColId = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return IsiGambar.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<Anak?> getAnakById(int id) async {
    final db = await instance.db;

    final maps = await db.query(
      anakTable,
      columns: [anakColId, anakColNama, anakColUmur, anakColKelas],
      where: '$anakColId = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Anak.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> registerUser(String username, String password) async {
    final db = await this.db;
    return await db
        .insert('users', {'username': username, 'password': password});
  }

  Future<Map<String, dynamic>?> loginUser(
      String username, String password) async {
    final db = await this.db;
    List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> insertAnak(Anak Anak) async {
    final db = await this.db;
    final int result = await db.insert(anakTable, Anak.toMap());
    return result;
  }
  
  Future<List<Map<String, dynamic>>> getTemaMapList() async {
    Database db = await instance.db;
    return await db.query('tema');
  }

  Future<Tema?> getTemaById(int id) async {
    Database db = await instance.db;
    List<Map<String, dynamic>> maps = await db.query(
      'tema',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Tema.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> insertTema(Tema tema) async {
    Database db = await instance.db;
    return await db.insert('tema', tema.toMap());
  }

  Future<int> updateTema(Tema tema) async {
    Database db = await instance.db;
    return await db.update(
      'tema',
      tema.toMap(),
      where: 'id = ?',
      whereArgs: [tema.id],
    );
  }

  Future<int> deleteTema(int id) async {
    Database db = await instance.db;
    return await db.delete(
      'tema',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  Future<int> updateAnak(Anak anak) async {
    final db = await this.db;
    final int result = await db.update(
      anakTable,
      anak.toMap(),
      where: '$anakColId = ?',
      whereArgs: [anak.id],
    );
    return result;
  }

  Future<int> deleteAnak(int id) async {
    final db = await this.db;
    final int result = await db.delete(
      anakTable,
      where: '$anakColId = ?',
      whereArgs: [id],
    );
    return result;
  }

  Future<List<IsiGambar>> getIsiGambarList() async {
    final db = await this.db;
    final List<Map<String, dynamic>> result = await db.query(gambarTable);
    return List.generate(result.length, (i) {
      return IsiGambar.fromMap(result[i]);
    });
  }

  Future<List<IsiGambar>> getIsiGambarByTingkatKesulitan(
      String tingkatKesulitan) async {
    final db = await this.db;
    final List<Map<String, dynamic>> result = await db.query(
      'IsiGambar',
      where: 'TingkatKesulitan = ?',
      whereArgs: [tingkatKesulitan],
    );
    return result.map((map) => IsiGambar.fromMap(map)).toList();
  }

  Future<int> insertIsiGambar(IsiGambar isiGambar) async {
    final db = await this.db;
    return await db.insert(gambarTable, isiGambar.toMap());
  }

  Future<int> updateIsiGambar(IsiGambar isiGambar) async {
    final db = await this.db;
    return await db.update(
      gambarTable,
      isiGambar.toMap(),
      where: '$gambarColId = ?',
      whereArgs: [isiGambar.id],
    );
  }

  Future<int> deleteIsiGambar(int id) async {
    final db = await this.db;
    return await db.delete(
      gambarTable,
      where: '$gambarColId = ?',
      whereArgs: [id],
    );
  }

  // CRUD Operations for GAME Table
  Future<List<Map<String, dynamic>>> getGameMapList() async {
    final db = await this.db;
    final List<Map<String, dynamic>> result = await db.query(gameTable);
    return result;
  }

  Future<int> insertGame(Map<String, dynamic> game) async {
    final db = await this.db;
    final int result = await db.insert(gameTable, game);
    return result;
  }

  Future<int> updateGame(Map<String, dynamic> game) async {
    final db = await this.db;
    final int result = await db.update(
      gameTable,
      game,
      where: '$gameColId = ?',
      whereArgs: [game[gameColId]],
    );
    return result;
  }

  Future<int> deleteGame(int id) async {
    final db = await this.db;
    final int result = await db.delete(
      gameTable,
      where: '$gameColId = ?',
      whereArgs: [id],
    );
    return result;
  }

  // CRUD Operations for PUZZLE Table
  Future<List<Map<String, dynamic>>> getPuzzleMapList() async {
    final db = await this.db;
    final List<Map<String, dynamic>> result = await db.query(puzzleTable);
    return result;
  }

  Future<int> insertPuzzle(Map<String, dynamic> puzzle) async {
    final db = await this.db;
    final int result = await db.insert(puzzleTable, puzzle);
    return result;
  }

  Future<int> updatePuzzle(Map<String, dynamic> puzzle) async {
    final db = await this.db;
    final int result = await db.update(
      puzzleTable,
      puzzle,
      where: '$puzzleColId = ?',
      whereArgs: [puzzle[puzzleColId]],
    );
    return result;
  }

  Future<int> deletePuzzle(int id) async {
    final db = await this.db;
    final int result = await db.delete(
      puzzleTable,
      where: '$puzzleColId = ?',
      whereArgs: [id],
    );
    return result;
  }

  // CRUD Operations for GARIS Table
  Future<List<Map<String, dynamic>>> getGarisMapList() async {
    final db = await this.db;
    final List<Map<String, dynamic>> result = await db.query(garisTable);
    return result;
  }

  Future<int> insertGaris(Map<String, dynamic> garis) async {
    final db = await this.db;
    final int result = await db.insert(garisTable, garis);
    return result;
  }

  Future<int> updateGaris(Map<String, dynamic> garis) async {
    final db = await this.db;
    final int result = await db.update(
      garisTable,
      garis,
      where: '$garisColId = ?',
      whereArgs: [garis[garisColId]],
    );
    return result;
  }

  Future<int> deleteGaris(int id) async {
    final db = await this.db;
    final int result = await db.delete(
      garisTable,
      where: '$garisColId = ?',
      whereArgs: [id],
    );
    return result;
  }

  // CRUD Operations for GAME_STATE Table
  Future<List<Map<String, dynamic>>> getGameStateMapList() async {
    final db = await this.db;
    final List<Map<String, dynamic>> result = await db.query(gameStateTable);
    return result;
  }

  Future<int> insertGameState(Map<String, dynamic> gameState) async {
    final db = await this.db;
    final int result = await db.insert(gameStateTable, gameState);
    return result;
  }

  Future<int> updateGameState(Map<String, dynamic> gameState) async {
    final db = await this.db;
    final int result = await db.update(
      gameStateTable,
      gameState,
      where: '$gameStateColId = ?',
      whereArgs: [gameState[gameStateColId]],
    );
    return result;
  }

  Future<int> deleteGameState(int id) async {
    final db = await this.db;
    final int result = await db.delete(
      gameStateTable,
      where: '$gameStateColId = ?',
      whereArgs: [id],
    );
    return result;
  }
}
