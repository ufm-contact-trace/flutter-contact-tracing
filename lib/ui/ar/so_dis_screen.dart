import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class SocialDistanceAR extends StatefulWidget {
  @override
  _SocialDistanceARState createState() => _SocialDistanceARState();
}

class _SocialDistanceARState extends State<SocialDistanceAR> {
  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
        appBar: PlatformAppBar(
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: true,
        ),
        body: PlatformWidget(ios: (_) {
          //Render the ARKit screen
          return Container();
        }, android: (_) {
          //Render the ARCore Screen
          return Container();
        }));
  }
}
