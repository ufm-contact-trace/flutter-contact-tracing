import 'package:sqflite/sqflite.dart';
import 'package:ug_covid_trace/storage/db.dart';

class ExposureModel {
  static const TABLE_NAME = 'exposure';

  final int id;
  final DateTime date;
  final Duration duration;
  final int totalRiskScore;
  final int transmissionRiskLevel;
  bool reported;

  ExposureModel(
      {this.id,
      this.date,
      this.duration,
      this.totalRiskScore,
      this.transmissionRiskLevel,
      this.reported});

  Future<void> destroy() async {
    final Database db = await Storage.db;
    return db.delete(TABLE_NAME, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> insert() async {
    final Database db = await Storage.db;
    await db.insert(TABLE_NAME, toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    print('inserted exposure ${toMap()}');
  }

  Future<int> save() async {
    final Database db = await Storage.db;
    return db.update(TABLE_NAME, toMap(), where: 'id = ?', whereArgs: [id]);
  }

  Map<String, dynamic> toMap() {
    var day = DateTime(date.year, date.month, date.day);

    return {
      'id': id,
      'date': day.toIso8601String(),
      'duration': duration.inMinutes,
      'total_risk_score': totalRiskScore,
      'transmission_risk_level': transmissionRiskLevel,
      'reported': reported == true ? 1 : 0,
    };
  }

  static Future<Map<String, int>> count() async {
    var db = await Storage.db;

    var count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $TABLE_NAME;'));

    var reported = Sqflite.firstIntValue(await db
        .rawQuery('SELECT COUNT(*) FROM $TABLE_NAME WHERE reported = 1;'));

    return {'count': count, 'reported': reported};
  }

  static Future<void> destroyAll() async {
    final Database db = await Storage.db;
    await db.delete(TABLE_NAME);
  }

  static Future<List<ExposureModel>> findAll(
      {int limit,
      String where,
      List<dynamic> whereArgs,
      String orderBy,
      String groupBy}) async {
    final Database db = await Storage.db;

    var rows = await db.query(TABLE_NAME,
        limit: limit,
        orderBy: orderBy,
        where: where,
        whereArgs: whereArgs,
        groupBy: groupBy);

    return List.generate(
        rows.length,
        (index) => ExposureModel(
              id: rows[index]['id'],
              date: DateTime.parse(rows[index]['date']),
              duration: Duration(minutes: rows[index]['duration']),
              totalRiskScore: rows[index]['total_risk_score'],
              transmissionRiskLevel: rows[index]['transmission_risk_level'],
              reported: rows[index]['reported'] == 1,
            ));
  }
}
