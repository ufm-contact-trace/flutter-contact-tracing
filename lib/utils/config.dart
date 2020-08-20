import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class Config {
  static Map<String, dynamic> _local;
  static Map<String, dynamic> get() => _local;
  static bool get loaded => _local != null;

  static Future<Map<String, dynamic>> load() async {
    if (loaded) {
      return _local;
    }
    WidgetsFlutterBinding.ensureInitialized();

    var source = await rootBundle.loadString('assets/config.json');
    _local = jsonDecode(source);

    return _local;
  }

  static Future<dynamic> remote() async {
    if (!loaded) {
      await load();
    }
    // Allow local "remote" configuration for easier development/testing
    var remoteUrl = Uri.parse(_local['remote']);
    if (remoteUrl.hasScheme) {
      var configResp = await http.get(remoteUrl.toString());
      if (configResp.statusCode != 200) {
        throw ('Unable to fetch config file');
      }
      return jsonDecode(configResp.body);
    } else {
      var configResp = await rootBundle.loadString(remoteUrl.toString());
      return jsonDecode(configResp);
    }
  }
}
