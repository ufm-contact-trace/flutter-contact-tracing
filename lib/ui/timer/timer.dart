import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'timerPainter.dart';

class TimerScreen extends StatefulWidget {
  @override
  _TimerScreenState createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen>
    with TickerProviderStateMixin {
  AnimationController animationController;

  String get timerString {
    Duration duration =
        animationController.duration * animationController.value;
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
          title: Text('20s Wash Timer'), automaticallyImplyLeading: true),
      body: AnimatedBuilder(
          animation: animationController,
          builder: (context, _) {
            return Stack(
              children: <Widget>[
                Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      color: Colors.lightBlue,
                      height: animationController.value *
                          MediaQuery.of(context).size.height,
                    )),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: Align(
                          alignment: FractionalOffset.center,
                          child: AspectRatio(
                            aspectRatio: 1.0,
                            child: Stack(
                              children: <Widget>[
                                Positioned.fill(
                                    child: CustomPaint(
                                  painter: Custom20SecondTimer(
                                      Colors.white,
                                      Theme.of(context).accentColor,
                                      animationController),
                                )),
                                Align(
                                  alignment: FractionalOffset.center,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        "Count Down Timer",
                                        style: TextStyle(
                                            fontSize: 20.0,
                                            color: Colors.white),
                                      ),
                                      Text(timerString,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline5
                                              .copyWith(
                                                color: Colors.white,
                                              )),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      AnimatedBuilder(
                          animation: animationController,
                          builder: (context, _) {
                            return FloatingActionButton.extended(
                                onPressed: () {
                                  if (animationController.isAnimating) {
                                    animationController.stop();
                                  } else {
                                    animationController.reverse(
                                        from: animationController.value == 0.0
                                            ? 1.0
                                            : animationController.value);
                                  }
                                },
                                icon: Icon(animationController.isAnimating
                                    ? Icons.pause
                                    : Icons.play_arrow),
                                label: Text(animationController.isAnimating
                                    ? 'Pause'
                                    : 'Start'));
                          })
                    ],
                  ),
                ),
              ],
            );
          }),
    );
  }

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 20));
  }
}
