import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ug_covid_trace/ui/ar/so_dis_screen.dart';
import 'package:ug_covid_trace/ui/timer/timer.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool tracingOn = false;

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text('Exposures'),
        leading: IconButton(
          icon: FaIcon(FontAwesomeIcons.peopleArrows),
          onPressed: () => Navigator.push(
            context,
            platformPageRoute(
              context: context,
              builder: (BuildContext context) => SocialDistanceAR(),
            ),
          ),
        ),
        trailingActions: <Widget>[
          IconButton(
            icon: FaIcon(FontAwesomeIcons.stopwatch20),
            onPressed: () => Navigator.push(
              context,
              platformPageRoute(
                context: context,
                builder: (BuildContext context) => TimerScreen(),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          SwitchListTile.adaptive(
              title: Text('Exposure Notifications'),
              value: tracingOn,
              onChanged: (changeTracingStatus) {
                setState(() {
                  tracingOn = changeTracingStatus;
                });
              }),
          Divider(),
        ],
      ),
    );
  }
}
