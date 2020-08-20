import 'dart:async';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

List<String> initialScript = [
  '''
CREATE TABLE user (
  id INTEGER PRIMARY KEY,
  uuid STRING,
  onboarding INTEGER,
  last_check TEXT,
  verify_token TEXT,
  refresh_token TEXT
)
  ''',
  "INSERT INTO user (uuid, onboarding) VALUES ('$uuid', 1)",
  '''
CREATE TABLE report (
  id INTEGER PRIMARY KEY,
  timestamp TEXT,
  last_exposure_key TEXT 
)
  ''',
  '''
CREATE TABLE exposure (
  id INTEGER PRIMARY KEY,
  date TEXT,
  duration INTEGER,
  total_risk_score INTEGER,
  transmission_risk_level INTEGER,
  reported INTEGER DEFAULT 0
)
  ''',
];

// Maps a DB version to migration scripts
Map<int, List<String>> migrationScripts = {
  2: [
    // Add first migration scripts here and specify `version: 2` in openDatabase
    // below.
  ],
};

final uuid = Uuid().v4();

Future<String> _dataBasePath(String path) async {
  return p.join(await getDatabasesPath(), path);
}

Future<Database> _initDatabase() async {
  return await openDatabase(await _dataBasePath('ugtrace.db'), version: 1,
      onCreate: (db, version) async {
    initialScript.forEach((script) async => await db.execute(script));
    if (version > 1) {
      _runMigrations(db, 1, version);
    }
  }, onUpgrade: _runMigrations);
}

Future<void> _runMigrations(db, oldVersion, newVersion) async {
  for (var i = oldVersion + 1; i <= newVersion; i++) {
    print('running migration ver $i');
    migrationScripts[i].forEach((script) async => await db.execute(script));
  }
}

class Storage {
  static final Future<Database> db = _initDatabase();
}
