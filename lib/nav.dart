import 'package:animations/animations.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:ug_covid_trace/helper/check_exposures.dart';
import 'package:ug_covid_trace/state.dart';
import 'package:ug_covid_trace/ui/home/home_screen.dart';
import 'package:ug_covid_trace/ui/notify/notify_screen.dart';
import 'package:ug_covid_trace/ui/settings/settings_screen.dart';
import 'package:wakelock/wakelock.dart';

class TraceNav extends StatefulWidget {
  @override
  _TraceNavState createState() => _TraceNavState();
}

class _TraceNavState extends State<TraceNav> {
  int _currentPage = 0;

  var pages = [
    HomeScreen(),
    NotifyScreen(),
    SettingsScreen(),
  ];

  Future<void> initBackgroundFetch() async {
    var packageName = (await PackageInfo.fromPlatform()).packageName;
    var enTaskID = '$packageName.exposure-notification';

    await BackgroundFetch.configure(
        BackgroundFetchConfig(
          enableHeadless: true,
          minimumFetchInterval: 15,
          requiredNetworkType: NetworkType.ANY,
          requiresBatteryNotLow: true,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: true,
          startOnBoot: true,
          stopOnTerminate: false,
        ), (String taskId) async {
      if (taskId == enTaskID) {
        await checkExposures();
      }
      BackgroundFetch.finish(taskId);
    });
    await BackgroundFetch.scheduleTask(
        TaskConfig(taskId: enTaskID, delay: 1000 * 60 * 15, periodic: true));
  }

  @override
  void initState() {
    super.initState();
    if (!kReleaseMode) {
      Wakelock.enable();
    }
    initBackgroundFetch();
    NotificationState.instance
        .addListener(() => setState(() => _currentPage = 0));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (BuildContext context, AppState value, Widget child) =>
          PlatformScaffold(
        body: SafeArea(
          child: PageTransitionSwitcher(
              transitionBuilder: (Widget child,
                  Animation<double> primaryAnimation,
                  Animation<double> secondaryAnimation) {
                return FadeThroughTransition(
                    animation: primaryAnimation,
                    secondaryAnimation: secondaryAnimation);
              },
              child: pages.elementAt(_currentPage)),
        ),
        bottomNavBar: PlatformNavBar(
            currentIndex: _currentPage,
            items: [
              BottomNavigationBarItem(
                icon: Icon(context.platformIcons.home),
                title: Text('Home'),
              ),
              BottomNavigationBarItem(
                icon: Icon(context.platformIcons.flag),
                title: Text('Notify Others'),
              ),
              BottomNavigationBarItem(
                icon: Icon(context.platformIcons.settings),
                title: Text('Settings'),
              ),
            ],
            itemChanged: (index) => setState(() => _currentPage = index)),
      ),
    );
  }
}
