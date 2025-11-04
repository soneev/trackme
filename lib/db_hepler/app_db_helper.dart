import 'package:my_location_traker_app/model/local_response.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class TrackingDBHelper {
  static final TrackingDBHelper _instance = TrackingDBHelper._internal();
  factory TrackingDBHelper() => _instance;
  TrackingDBHelper._internal();

  Database? _db;

  Future<void> initDB() async {
    if (_db != null) return;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'tracking.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tracking_sessions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            session_id TEXT,
            start_time TEXT,
            end_time TEXT,
            synced INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE locations(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            session_id TEXT,
            latitude REAL,
            longitude REAL,
            speed REAL,
            accuracy REAL,
            timestamp TEXT,
            synced INTEGER
          )
        ''');
      },
    );
  }

  Database get database {
    if (_db == null) {
      throw Exception("Database not initialized. Call initDB() first.");
    }
    return _db!;
  }

  //  Insert session
  Future<void> insertSession(Map<String, dynamic> session) async {
    await database.insert('tracking_sessions', session);
  }

  //  Update session end_time or sync status
  Future<void> updateSession(
      String sessionId, Map<String, dynamic> values) async {
    await database.update(
      'tracking_sessions',
      values,
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );
  }

  //  Insert location
  Future<void> insertLocation(Map<String, dynamic> location) async {
    await database.insert('locations', location);
  }

  //  Get unsynced sessions
  Future<List<Map<String, dynamic>>> getUnsyncedSessions() async {
    return await database
        .query('tracking_sessions', where: 'synced = ?', whereArgs: [0]);
  }

  //  Get unsynced locations
  Future<List<Map<String, dynamic>>> getUnsyncedLocations() async {
    return await database
        .query('locations', where: 'synced = ?', whereArgs: [0]);
  }

  // 🔹 Mark session as synced
  Future<void> markSynced(String sessionId) async {
    await updateSession(sessionId, {'synced': 1});
    await database.update('locations', {'synced': 1},
        where: 'session_id = ?', whereArgs: [sessionId]);
  }

  //  Close database (optional)
  Future<void> closeDB() async {
    await _db?.close();
    _db = null;
  }

  //  Delete a session and its related locations
  Future<void> deleteSession(String sessionId) async {
    final db = database;

    // Delete related locations first
    await db.delete(
      'locations',
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );

    // Then delete the session itself
    await db.delete(
      'tracking_sessions',
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );
  }

  Future<List<Map<String, dynamic>>> getSessionsWithLocationsRaw() async {
    final db = database;
    final sessionRows = await db.query('tracking_sessions', orderBy: 'id DESC');
    print("📦 Loaded ${sessionRows.length} sessions");

    List<Map<String, dynamic>> sessions = [];

    for (var session in sessionRows) {
      final sessionId = session['session_id'];
      final locationRows = await db.query(
        'locations',
        where: 'session_id = ?',
        whereArgs: [sessionId],
      );

      print("📍 Session $sessionId has ${locationRows.length} locations");

      // Add locations list directly into the session map
      sessions.add({
        ...session,
        'locations': locationRows, // raw list of maps
      });
    }

    print("✅ Final sessions count: ${sessions.length}");
    return sessions;
  }

  // 🔹 Get the current active session (no end_time yet)
  Future<Map<String, dynamic>?> getActiveSession() async {
    final db = database;

    final List<Map<String, dynamic>> result = await db.query(
      'tracking_sessions',
      where: 'end_time IS NULL',
      orderBy: 'id DESC',
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<void> updateSessionSynced(String sessionId) async {
    final db = database;
    await db.update(
      'tracking_sessions',
      {'synced': 1},
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );
  }

  Future<List<SessionModel>> getAllSyncedSessions() async {
    final db = database;
    final result = await db.query(
      'tracking_sessions',
      where: 'synced = ?',
      whereArgs: [1],
    );

    return result.map((json) => SessionModel.fromMap(json)).toList();
  }
}
