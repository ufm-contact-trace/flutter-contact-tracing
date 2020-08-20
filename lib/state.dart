import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:gact_plugin/gact_plugin.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:package_info/package_info.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ug_covid_trace/helper/signed_upload.dart';
import 'package:ug_covid_trace/storage/db.dart';

import 'helper/check_exposures.dart' as bg;
import 'storage/exposure.dart';
import 'storage/report.dart';
import 'storage/user.dart';
import 'utils/config.dart';

class NotificationState with ChangeNotifier {
  static final instance = NotificationState();

  void onNotice(String notice) {
    notifyListeners();
  }
}

class AppState with ChangeNotifier {
  static UserModel _user;
  static ReportModel _report;
  static bool _ready = false;
  static ExposureModel _exposure;

  AppState() {
    initState();
    NotificationState.instance.addListener(() async {
      setExposure(await getExposure());
    });
  }

  initState() async {
    _user = await UserModel.find();
    _report = await ReportModel.findLatest();
    _exposure = await getExposure();
    _ready = true;
    notifyListeners();
  }

  bool get ready => _ready;

  ExposureModel get exposure => _exposure;
  UserModel get user => _user;

  Future<ExposureModel> getExposure() async {
    var rows = await ExposureModel.findAll(limit: 1, orderBy: 'date DESC');
    return rows.isNotEmpty ? rows.first : null;
  }

  void setExposure(ExposureModel exposureModel) {
    _exposure = exposureModel;
    notifyListeners();
  }

  Future<ExposureModel> checkExposures() async {
    await bg.checkExposures();
    _user = await UserModel.find();
    _exposure = await getExposure();
    notifyListeners();
    return _exposure;
  }

  Future<void> saveUser(user) async {
    _user = user;
    await _user.save();
    notifyListeners();
  }

  ReportModel get report => _report;

  Future<void> saveReport(ReportModel reportModel) async {
    _report = reportModel;
    await _report.create();
    notifyListeners();
  }

  Future<bool> sendExposure() async {
    var success = false;
    try {
      var config = await Config.remote();
      var user = await UserModel.find();

      String bucket = config['exposureBucket'] ?? 'ugtrace-exposures';

      var data = jsonEncode({
        'duration': _exposure.duration.inMinutes,
        'totalRiskScore': _exposure.totalRiskScore,
        'transmissionRiskLevel': _exposure.transmissionRiskLevel,
        'timestamp': DateFormat('yyyy-MM-dd').format(_exposure.date)
      });

      if (!await objectUpload(
          config: config,
          bucket: bucket,
          object: '${user.uuid}.json',
          data: data)) {
        return false;
      }
      _exposure.reported = true;
      await _exposure.save();
      success = true;
    } catch (e) {
      print(e);
      success = false;
    }
    notifyListeners();
    return success;
  }

  Future<bool> objectUpload(
      {config,
      String bucket,
      String object,
      String data,
      String contentType = 'application/json; charset=utf-8'}) async {
    var user = await UserModel.find();

    return signedUpload(config, user.token,
        query: {'bucket': bucket, 'contentType': contentType, 'object': object},
        headers: {'Content-Type': contentType},
        body: data);
  }

  Future<List<ExposureKey>> sendExposureKeys(
      Map<String, dynamic> config, String verificationCode) async {
    Iterable<ExposureKey> keys;

    try {
      keys = await GactPlugin.getExposureKeys(testMode: false);
    } catch (e) {
      print(e);
      if (errorFromException(e) == ErrorCode.notAuthorized) {
        return null;
      }
    }
    if (keys == null || keys.isEmpty) {
      return keys?.toList();
    }
    var postData = {
      "regions": ['UG'],
      "appPackageName": (await PackageInfo.fromPlatform()).packageName,
      "platform": Platform.isIOS ? 'ios' : 'android',
      "deviceVerificationPayload": await GactPlugin.deviceCheck,
      "temporaryExposureKeys": keys
          .map((k) => {
                "key": k.keyData,
                "rollingPeriod": k.rollingPeriod,
                "rollingStartNumber": k.rollingStartNumber,
                "transmissionRisk": k.transmissionRiskLevel
              })
          .toList(),
      // TODO(wes): Support these fields, not currently required
      // "verificationPayload": verificationCode,
      // "padding": "",
    };

    var postResp = await http.post(
      Uri.parse(config['exposurePublishUrl']),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(postData),
    );
//Handle verification failure
    if (postResp.statusCode == 200) {
      return keys.toList();
    } else {
      print(postResp.body);
    }
    return null;
  }

  Future<bool> sendReport(String verificationCode) async {
    var success = false;
    var config = await Config.remote();

    try {
      List<ExposureKey> keys =
          await sendExposureKeys(config, verificationCode) ?? [];

      if (keys.isNotEmpty) {
        _report = ReportModel(
            lastExposureKey: keys.last.keyData, timeStamp: DateTime.now());
        await report.create();
        success = true;
      }
    } catch (e) {
      print(e);
      success = false;
    }
    notifyListeners();
    return success;
  }

  Future<void> clearReport() async {
    await ReportModel.clearAll();
    _report = null;
    notifyListeners();
  }

  Future<void> resetInfections() async {
    final Database db = await Storage.db;
    await Future.wait([
      db.update('user', {'last_check': null}),
      ExposureModel.destroyAll(),
    ]);
    _exposure = null;
    notifyListeners();
  }
}
