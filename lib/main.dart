import 'dart:io';

import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ug_covid_trace/helper/check_exposures.dart';
import 'package:ug_covid_trace/nav.dart';
import 'package:ug_covid_trace/state.dart';
import 'package:ug_covid_trace/ui/onboarding/onboarding_screen.dart';
import 'package:ug_covid_trace/utils/config.dart';

Future<void> main() async {
  await Config.load();
  await Hive.initFlutter();
  await Hive.openBox('ugTracerBox');
  runApp(
      ChangeNotifierProvider(create: (context) => AppState(), child: MyApp()));

  if (Platform.isAndroid) {
    BackgroundFetch.registerHeadlessTask((String id) async {
      await checkExposures();
      BackgroundFetch.finish(id);
    });
  }

  var notificationPlugin = FlutterLocalNotificationsPlugin();
  notificationPlugin.initialize(
    InitializationSettings(
        AndroidInitializationSettings('ic_launcher'),
        IOSInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false)),
    onSelectNotification: (notice) async =>
        NotificationState.instance.onNotice(notice),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Brightness brightness = Brightness.light;
  final bool onboarding =
      Hive.box('ugTracerBox').get('onboardingSeen', defaultValue: null);

  @override
  Widget build(BuildContext context) {
    final materialTheme = new ThemeData(
      primaryColor: Color(0xff1c3857),
      primaryColorLight: Color(0xffd8e5f3),
      primaryColorDark: Color(0xff254b74),
      accentColor: Color(0xffe0a700),
    );
    final materialDarkTheme = new ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.amber,
    );

    final cupertinoTheme = new CupertinoThemeData(
      brightness: brightness,
      primaryColor: CupertinoDynamicColor.withBrightness(
        color: CupertinoColors.systemBlue,
        darkColor: CupertinoColors.systemOrange,
      ),
    );
    return Consumer<AppState>(
      builder: (context, value, child) {
        if (value.user != null) {
          return PlatformProvider(
            builder: (context) => PlatformApp(
              localizationsDelegates: <LocalizationsDelegate<dynamic>>[
                DefaultMaterialLocalizations.delegate,
                DefaultWidgetsLocalizations.delegate,
                DefaultCupertinoLocalizations.delegate,
              ],
              title: 'Ug Covid Trace',
              material: (_, __) {
                return MaterialAppData(
                  theme: materialTheme,
                  darkTheme: materialDarkTheme,
                  // themeMode: brightness == Brightness.light
                  //     ? ThemeMode.light
                  //     : ThemeMode.dark,
                );
              },
              cupertino: (_, __) {
                return CupertinoAppData(
                  theme: cupertinoTheme,
                );
              },
              home: onboarding == true ? TraceNav() : OnboardingScreen(),
            ),
          );
        } else {
          return Container(color: Colors.white);
        }
      },
    );
  }
}
