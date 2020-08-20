import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:hive/hive.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:ug_covid_trace/nav.dart';
import 'package:gact_plugin/gact_plugin.dart';
import 'package:ug_covid_trace/storage/user.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  var _requestExposure = false;
  var _requestNotification = false;
  var _linkToSettings = false;

  AuthorizationStatus status;

  void requestPermission(bool permReq) async {
    if (_linkToSettings) {
      //AppSettings.openAppSettings();
      return;
    }
    //AuthorizationStatus status;
    try {
      status = await GactPlugin.authorizationStatus;
      print('Enable exposure notification $status');

      if (status != AuthorizationStatus.Authorized) {
        status = await GactPlugin.enableExposureNotification();
      }

      if (status != AuthorizationStatus.Authorized) {
        setState(() => _linkToSettings = true);
      }
    } catch (e) {
      print(e);
      if (errorFromException(e) == ErrorCode.notAuthorized) {
        setState(() => _linkToSettings = true);
      }
    }
    setState(() => _requestExposure = status == AuthorizationStatus.Authorized);
  }

  void requestNotifications(bool selected) async {
    var plugin = FlutterLocalNotificationsPlugin();
    bool allowed = await plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        .requestPermissions(alert: true, sound: true);

    setState(() => _requestNotification = allowed);
    var user = await UserModel.find();
    await user.save();
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0, color: Colors.black);
    const pageDecoration = const PageDecoration(
      titleTextStyle: TextStyle(
          fontSize: 28.0, fontWeight: FontWeight.w700, color: Colors.black),
      bodyTextStyle: bodyStyle,
      descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.zero,
    );

    var introPageViews = <PageViewModel>[
      PageViewModel(
        title: "Welcome to Ug Contact Trace",
        body:
            "An initative by the Ministry of Health in the fight against the Coronavirus(COVID_19)",
        decoration: pageDecoration,
        image: Center(child: Image.asset('assets/img/moh-logo.png')),
      ),
      PageViewModel(
        title: "Features",
        bodyWidget: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '• Statistics Count of Confirmed, Active, Recovered and Death Cases',
                style: bodyStyle,
              ),
              Text(
                '• Self Reporting Tool for symptom reporting',
                style: bodyStyle,
              ),
              Text(
                '• Self Checker for checking if you have symptoms',
                style: bodyStyle,
              ),
              Text(
                '• Frequently Asked Questions about Covid-19',
                style: bodyStyle,
              ),
              Text(
                '• Recommended Guidelines for staying safe during the pandemic',
                style: bodyStyle,
              ),
              Text(
                '• Contact Tracing Features',
                style: bodyStyle,
              ),
            ]),
        decoration: pageDecoration,
      ),
      PageViewModel(
        title: "Turn on COVID-19 Exposure Notifications",
        bodyWidget: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "These notifications are designed to notify you if you have been exposed to a user who later reports themselves as testing positive for COVID-19. You can choose to turn off these notifications at any time.",
                softWrap: true,
                style: bodyStyle,
              ),
              SizedBox(height: 10),
              Text(
                "Exposure notifications rely on the sharing and collecting of random IDs. These IDs are a random string of numbers that won't identify you to other users and change many times a day to protect your privacy",
                softWrap: true,
                style: bodyStyle,
              ),
            ],
          ),
        ),
        decoration: pageDecoration,
        //image: Center(child: Image.asset('assets/img/moh-logo.png')),
        footer: PlatformSwitch(
            value: _requestExposure, onChanged: requestPermission),
      ),
      PageViewModel(
          title: 'what to Expect',
          bodyWidget: InkWell(
            onTap: () => requestNotifications(!_requestExposure),
            child: Container(
                child: Text(
                    'UG Trace is now monitoring for exposures. You will get a notification if you were potentially exposed to COVID-19.')),
          ),
          decoration: pageDecoration,
          footer: PlatformSwitch(
              value: _requestNotification, onChanged: requestNotifications)),
    ];

    return SafeArea(
      child: IntroductionScreen(
        initialPage: 0,
        pages: introPageViews,
        onDone: () => _onIntroEnd(context),
        onSkip: () => introPageViews.last,
        showSkipButton: false,
        showNextButton: true,
        nextFlex: 0,
        done: PlatformButton(
          onPressed: () async {
            var user = await UserModel.find();
            user.onboarding = false;
            await user.save();
            Hive.box('ugTracerBox').put('onboardingSeen', true);
            Navigator.of(context).pushReplacement(platformPageRoute(
                builder: (_) => TraceNav(), context: context));
          },
          child: Text('Get Started'),
          materialFlat: (_, __) => MaterialFlatButtonData(),
          cupertinoFilled: (_, __) => CupertinoFilledButtonData(),
        ),
        next: Icon(context.platformIcons.forward),
        dotsDecorator: const DotsDecorator(
          size: Size(10.0, 10.0),
          color: Color(0xFFBDBDBD),
          activeSize: Size(22.0, 10.0),
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
          ),
        ),
      ),
    );
  }

  void _onIntroEnd(BuildContext context) =>
      Navigator.of(context).pushReplacement(
          platformPageRoute(builder: (_) => TraceNav(), context: context));
}
