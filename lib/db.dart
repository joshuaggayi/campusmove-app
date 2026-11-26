import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'models.dart';

const String kKampala = 'Kampala (Old Taxi Park)';
const String kMakerere = 'Makerere University';
const String kMubs = 'MUBS Nakawa';
const String kKyambogo = 'Kyambogo University';
const String kNtinda = 'Ntinda';

const List<String> kReviewTags = ['Safety', 'Fare', 'Overcrowding', 'Other'];

/// One sample route. Each seed is stored in both directions.
/// Stages are written as 'Stage name|Landmark'.
class _Seed {
  final String a;
  final String b;
  final String mode;
  final int fare;
  final int minutes;
  final List<String> stages;

  const _Seed(this.a, this.b, this.mode, this.fare, this.minutes, this.stages);
}

// SAMPLE DATA: fares, times and stages are illustrative. Replace them with
// figures from your own field survey before presenting the app.
const List<_Seed> _seeds = [
  _Seed(kKampala, kMakerere, 'Taxi', 1000, 20, [
    'Old Taxi Park|Main taxi stage',
    'Wandegeya|Wandegeya Market',
    'Makerere University|Main Gate',
  ]),
  _Seed(kKampala, kMakerere, 'Boda boda', 3000, 12, [
    'Old Taxi Park|Boda stage',
    'Wandegeya|Wandegeya Market',
    'Makerere University|Main Gate',
  ]),
  _Seed(kKampala, kMubs, 'Taxi', 1500, 30, [
    'Old Taxi Park|Main taxi stage',
    'Clock Tower|Start of Jinja Road',
    'Nakawa|Nakawa Market',
    'MUBS Nakawa|Main Gate',
  ]),
  _Seed(kKampala, kMubs, 'Boda boda', 5000, 20, [
    'Old Taxi Park|Boda stage',
    'Clock Tower|Start of Jinja Road',
    'Nakawa|Nakawa Market',
    'MUBS Nakawa|Main Gate',
  ]),
  _Seed(kKampala, kKyambogo, 'Taxi', 1500, 40, [
    'Old Taxi Park|Main taxi stage',
    'Clock Tower|Start of Jinja Road',
    'Nakawa|Nakawa Market',
    'Banda|Banda trading centre',
    'Kyambogo University|Main Gate',
  ]),
  _Seed(kKampala, kKyambogo, 'Boda boda', 6000, 28, [
    'Old Taxi Park|Boda stage',
    'Clock Tower|Start of Jinja Road',
    'Nakawa|Nakawa Market',
    'Banda|Banda trading centre',
    'Kyambogo University|Main Gate',
  ]),
  _Seed(kKampala, kNtinda, 'Taxi', 1500, 30, [
    'Old Taxi Park|Main taxi stage',
    'Nakawa|Nakawa Market',
    'Ntinda|Ntinda trading centre',
  ]),
  _Seed(kKampala, kNtinda, 'Boda boda', 5000, 22, [
    'Old Taxi Park|Boda stage',
    'Nakawa|Nakawa Market',
    'Ntinda|Ntinda trading centre',
  ]),
  _Seed(kMakerere, kMubs, 'Taxi', 2500, 55, [
    'Makerere University|Main Gate',
    'Wandegeya|Wandegeya Market',
    'Old Taxi Park|Change taxis here',
    'Nakawa|Nakawa Market',
    'MUBS Nakawa|Main Gate',
  ]),
  _Seed(kMakerere, kMubs, 'Boda boda', 8000, 35, [
    'Makerere University|Boda stage at the gate',
    'Wandegeya|Wandegeya Market',
    'Nakawa|Nakawa Market',
    'MUBS Nakawa|Main Gate',
  ]),
  _Seed(kMakerere, kKyambogo, 'Taxi', 3000, 60, [
    'Makerere University|Main Gate',
    'Wandegeya|Wandegeya Market',
    'Old Taxi Park|Change taxis here',
    'Nakawa|Nakawa Market',
    'Banda|Banda trading centre',
    'Kyambogo University|Main Gate',
  ]),
  _Seed(kMakerere, kKyambogo, 'Boda boda', 7000, 40, [
    'Makerere University|Boda stage at the gate',
    'Wandegeya|Wandegeya Market',
    'Ntinda|Ntinda trading centre',
    'Kyambogo University|Main Gate',
  ]),
  _Seed(kMakerere, kNtinda, 'Taxi', 2500, 50, [
    'Makerere University|Main Gate',
    'Wandegeya|Wandegeya Market',
    'Old Taxi Park|Change taxis here',
    'Nakawa|Nakawa Market',
    'Ntinda|Ntinda trading centre',
  ]),
  _Seed(kMakerere, kNtinda, 'Boda boda', 6000, 35, [
    'Makerere University|Boda stage at the gate',
    'Wandegeya|Wandegeya Market',
    'Ntinda|Ntinda trading centre',
  ]),
  _Seed(kMubs, kKyambogo, 'Taxi', 1000, 25, [
    'MUBS Nakawa|Nakawa taxi stage',
    'Banda|Banda trading centre',
    'Kyambogo University|Main Gate',
  ]),
  _Seed(kMubs, kKyambogo, 'Boda boda', 4000, 15, [
    'MUBS Nakawa|Boda stage at the gate',
    'Banda|Banda trading centre',
    'Kyambogo University|Main Gate',
  ]),
  _Seed(kMubs, kNtinda, 'Taxi', 1000, 20, [
    'MUBS Nakawa|Nakawa taxi stage',
    'Nakawa|Nakawa Market',
    'Ntinda|Ntinda trading centre',
  ]),
  _Seed(kMubs, kNtinda, 'Boda boda', 3000, 12, [
    'MUBS Nakawa|Boda stage at the gate',
    'Nakawa|Nakawa Market',
    'Ntinda|Ntinda trading centre',
  ]),
  _Seed(kKyambogo, kNtinda, 'Taxi', 1000, 20, [
    'Kyambogo University|Main Gate',
    'Banda|Banda trading centre',
    'Ntinda|Ntinda trading centre',
  ]),
  _Seed(kKyambogo, kNtinda, 'Boda boda', 3000, 12, [
    'Kyambogo University|Boda stage at the gate',
    'Banda|Banda trading centre',
    'Ntinda|Ntinda trading centre',
  ]),
];

/// Local SQLite storage for users, routes, stages, reviews and saved routes.
class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  /// Incremented after every write so open screens know to reload.
  final ValueNotifier<int> version = ValueNotifier<int>(0);

  Database? _db;

  Future<Database> get database async {
    return _db ??= await _open();
  }

  Future<Database> _open() async {
    final dir = await getDatabasesPath();
    return openDatabase(
      p.join(dir, 'campusmove.db'),
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
    );
  }

  static String _hash(String password) =>
      sha256.convert(utf8.encode('campusmove:$password')).toString();

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        role TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE routes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        origin TEXT NOT NULL,
        destination TEXT NOT NULL,
        mode TEXT NOT NULL,
        fare_ugx INTEGER NOT NULL,
        minutes INTEGER NOT NULL,
        boarding_point TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE route_stages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        route_id INTEGER NOT NULL REFERENCES routes(id),
        seq INTEGER NOT NULL,
        stage_name TEXT NOT NULL,
        landmark TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE reviews (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        route_id INTEGER NOT NULL REFERENCES routes(id),
        user_id INTEGER NOT NULL REFERENCES users(id),
        rating INTEGER NOT NULL,
        comment TEXT NOT NULL,
        tag TEXT NOT NULL,
        created_at TEXT NOT NULL,
        hidden INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE saved_routes (
        user_id INTEGER NOT NULL REFERENCES users(id),
        route_id INTEGER NOT NULL REFERENCES routes(id),
        PRIMARY KEY (user_id, route_id)
      )
    ''');
    await _seed(db);
  }

  Future<void> _seed(Database db) async {
    // Demo accounts for testing.
    await db.insert('users', {
      'name': 'Campus Admin',
      'email': 'admin@campusmove.ug',
      'password_hash': _hash('admin123'),
      'role': 'Admin',
    });
    final studentId = await db.insert('users', {
      'name': 'Sample Student',
      'email': 'student@campusmove.ug',
      'password_hash': _hash('student123'),
      'role': 'Student',
    });

    for (final s in _seeds) {
      await _insertRoute(db, s.a, s.b, s, s.stages);
      await _insertRoute(db, s.b, s.a, s, s.stages.reversed.toList());
    }

    await _addSeedReview(db, studentId, kKampala, kMakerere, 'Taxi', 4,
        'Safety', 'Safe in daytime, but it fills up fast after lectures.');
    await _addSeedReview(db, studentId, kKampala, kMakerere, 'Boda boda', 3,
        'Fare', 'Fast, but agree the fare before you get on.');
    await _addSeedReview(db, studentId, kKampala, kMubs, 'Taxi', 5, 'Fare',
        'Cheap and direct along Jinja Road.');
    await _addSeedReview(db, studentId, kMakerere, kKyambogo, 'Taxi', 2,
        'Overcrowding', 'Very crowded in the evening and you must change taxis.');
  }

  Future<int> _insertRoute(
      Database db, String a, String b, _Seed s, List<String> stages) async {
    final first = stages.first.split('|');
    final id = await db.insert('routes', {
      'origin': a,
      'destination': b,
      'mode': s.mode,
      'fare_ugx': s.fare,
      'minutes': s.minutes,
      'boarding_point': '${first[0]} (${first[1]})',
    });
    for (var i = 0; i < stages.length; i++) {
      final parts = stages[i].split('|');
      await db.insert('route_stages', {
        'route_id': id,
        'seq': i + 1,
        'stage_name': parts[0],
        'landmark': parts[1],
      });
    }
    return id;
  }

  Future<void> _addSeedReview(Database db, int userId, String a, String b,
      String mode, int rating, String tag, String comment) async {
    final rows = await db.query(
      'routes',
      columns: ['id'],
      where: 'origin = ? AND destination = ? AND mode = ?',
      whereArgs: [a, b, mode],
      limit: 1,
    );
    if (rows.isEmpty) return;
    await db.insert('reviews', {
      'route_id': rows.first['id'],
      'user_id': userId,
      'rating': rating,
      'comment': comment,
      'tag': tag,
      'created_at': DateTime.now().toIso8601String(),
      'hidden': 0,
    });
  }

  // ---------------------------------------------------------------- users

  /// Returns the new user, or null if the email is already registered.
  Future<AppUser?> registerUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final db = await database;
    final cleanEmail = email.trim().toLowerCase();
    try {
      final id = await db.insert('users', {
        'name': name.trim(),
        'email': cleanEmail,
        'password_hash': _hash(password),
        'role': role,
      });
      return AppUser(id: id, name: name.trim(), email: cleanEmail, role: role);
    } on DatabaseException {
      return null;
    }
  }

  Future<AppUser?> login(String email, String password) async {
    final db = await database;
    final rows = await db.query(
      'users',
      where: 'email = ? AND password_hash = ?',
      whereArgs: [email.trim().toLowerCase(), _hash(password)],
      limit: 1,
    );
    return rows.isEmpty ? null : AppUser.fromMap(rows.first);
  }

  Future<AppUser?> getUser(int id) async {
    final db = await database;
    final rows =
        await db.query('users', where: 'id = ?', whereArgs: [id], limit: 1);
    return rows.isEmpty ? null : AppUser.fromMap(rows.first);
  }

  // --------------------------------------------------------------- routes

  static const String _routeSelect = '''
    SELECT r.*,
           COALESCE(AVG(v.rating), 0) AS avg_rating,
           COUNT(v.id) AS review_count
    FROM routes r
    LEFT JOIN reviews v ON v.route_id = r.id AND v.hidden = 0
  ''';

  Future<List<String>> getPlaces() async {
    final db = await database;
    final rows =
        await db.rawQuery('SELECT DISTINCT origin FROM routes ORDER BY origin');
    return rows.map((r) => r['origin'] as String).toList();
  }

  Future<List<TransportRoute>> searchRoutes(
      String origin, String destination) async {
    final db = await database;
    final rows = await db.rawQuery(
      '$_routeSelect WHERE r.origin = ? AND r.destination = ? GROUP BY r.id',
      [origin, destination],
    );
    return rows.map(TransportRoute.fromMap).toList();
  }

  Future<TransportRoute?> getRoute(int id) async {
    final db = await database;
    final rows = await db.rawQuery(
      '$_routeSelect WHERE r.id = ? GROUP BY r.id',
      [id],
    );
    return rows.isEmpty ? null : TransportRoute.fromMap(rows.first);
  }

  Future<List<RouteStage>> getStages(int routeId) async {
    final db = await database;
    final rows = await db.query(
      'route_stages',
      where: 'route_id = ?',
      whereArgs: [routeId],
      orderBy: 'seq',
    );
    return rows.map(RouteStage.fromMap).toList();
  }

  // -------------------------------------------------------------- reviews

  Future<List<Review>> getReviewsForRoute(int routeId) async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT v.*, u.name AS user_name
      FROM reviews v
      JOIN users u ON u.id = v.user_id
      WHERE v.route_id = ? AND v.hidden = 0
      ORDER BY v.id DESC
    ''', [routeId]);
    return rows.map(Review.fromMap).toList();
  }

  Future<List<Review>> getRecentReviews({int limit = 50}) async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT v.*, u.name AS user_name,
             r.origin || ' to ' || r.destination || ' (' || r.mode || ')'
               AS route_label
      FROM reviews v
      JOIN users u ON u.id = v.user_id
      JOIN routes r ON r.id = v.route_id
      WHERE v.hidden = 0
      ORDER BY v.id DESC
      LIMIT ?
    ''', [limit]);
    return rows.map(Review.fromMap).toList();
  }

  Future<void> addReview({
    required int routeId,
    required int userId,
    required int rating,
    required String comment,
    required String tag,
  }) async {
    final db = await database;
    await db.insert('reviews', {
      'route_id': routeId,
      'user_id': userId,
      'rating': rating,
      'comment': comment.trim(),
      'tag': tag,
      'created_at': DateTime.now().toIso8601String(),
      'hidden': 0,
    });
    version.value++;
  }

  /// Admin moderation: hides a comment from everyone.
  Future<void> hideReview(int reviewId) async {
    final db = await database;
    await db.update('reviews', {'hidden': 1},
        where: 'id = ?', whereArgs: [reviewId]);
    version.value++;
  }

  // ---------------------------------------------------------- saved routes

  Future<bool> isSaved(int userId, int routeId) async {
    final db = await database;
    final rows = await db.query(
      'saved_routes',
      where: 'user_id = ? AND route_id = ?',
      whereArgs: [userId, routeId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  /// Saves or unsaves a route. Returns true if the route is now saved.
  Future<bool> toggleSaved(int userId, int routeId) async {
    final db = await database;
    final saved = await isSaved(userId, routeId);
    if (saved) {
      await db.delete('saved_routes',
          where: 'user_id = ? AND route_id = ?', whereArgs: [userId, routeId]);
    } else {
      await db.insert('saved_routes', {'user_id': userId, 'route_id': routeId});
    }
    version.value++;
    return !saved;
  }

  Future<List<TransportRoute>> getSavedRoutes(int userId) async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT r.*,
             COALESCE(AVG(v.rating), 0) AS avg_rating,
             COUNT(v.id) AS review_count
      FROM saved_routes s
      JOIN routes r ON r.id = s.route_id
      LEFT JOIN reviews v ON v.route_id = r.id AND v.hidden = 0
      WHERE s.user_id = ?
      GROUP BY r.id
      ORDER BY s.rowid DESC
    ''', [userId]);
    return rows.map(TransportRoute.fromMap).toList();
  }

  Future<int> countSaved(int userId) async {
    final db = await database;
    final rows = await db
        .rawQuery('SELECT COUNT(*) FROM saved_routes WHERE user_id = ?', [userId]);
    return Sqflite.firstIntValue(rows) ?? 0;
  }

  Future<int> countReviewsBy(int userId) async {
    final db = await database;
    final rows = await db.rawQuery(
        'SELECT COUNT(*) FROM reviews WHERE user_id = ? AND hidden = 0',
        [userId]);
    return Sqflite.firstIntValue(rows) ?? 0;
  }
}
