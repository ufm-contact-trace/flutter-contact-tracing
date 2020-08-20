import 'package:sqflite/sqflite.dart';
import 'package:ug_covid_trace/storage/db.dart';

class ReportModel {
  final int id;
  final String lastExposureKey;
  final DateTime timeStamp;

  ReportModel({this.id, this.lastExposureKey, this.timeStamp});

  create() async {
    final Database db = await Storage.db;
    await db.insert('report', {
      'last_exposure_key': lastExposureKey,
      'timestamp': timeStamp.toIso8601String()
    });
  }

//Delete all reports from the table
  static Future<void> clearAll() async {
    final Database db = await Storage.db;
    await db.delete('report');
  }

//Might have to change the number here if I am to get back more than 1 result @findLatest
  static Future<ReportModel> findLatest() async {
    final Database db = await Storage.db;
    final List<Map<String, dynamic>> rows =
        await db.query('report', limit: 1, orderBy: "timestamp DESC");
    if (rows.length == 0) {
      return null;
    }
    return ReportModel(
        id: rows[0]['id'],
        lastExposureKey: rows[0]['last_exposure_key'],
        timeStamp: DateTime.parse(rows[0]['timestamp']));
  }
}
