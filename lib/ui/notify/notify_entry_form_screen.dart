import 'dart:io';

import 'package:cupertino_stepper/cupertino_stepper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ug_covid_trace/state.dart';
import 'package:ug_covid_trace/utils/config.dart';
import 'package:ug_covid_trace/utils/operator.dart';

import 'code_pin.dart';
import 'verify_phone.dart';

class NotifyEntryFormScreen extends StatefulWidget {
  @override
  _NotifyEntryFormScreenState createState() => _NotifyEntryFormScreenState();
}

class _NotifyEntryFormScreenState extends State<NotifyEntryFormScreen>
    with TickerProviderStateMixin {
  var _loading = false;
  var _step = 0;
  var _verificationCode = '';
  bool _expandHeader = false;
  AnimationController expandController;
  CurvedAnimation curvedAnimation;

  @override
  void initState() {
    super.initState();
    expandController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    curvedAnimation =
        CurvedAnimation(parent: expandController, curve: Curves.fastOutSlowIn);
    Provider.of<AppState>(context, listen: false).addListener(onStateChanged);
  }

  void onStateChanged() async {
    AppState state = Provider.of<AppState>(context, listen: false);
    if (state.report != null) {
      expandController.forward();
      setState(() => _expandHeader = true);
    }
  }

  void onSubmit(context, AppState state) async {
    if (!await sendReport(state)) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('There was an error submitting your report'),
        backgroundColor: Colors.deepOrange,
      ));
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('Your report was successfully submitted'),
        backgroundColor: Colors.green,
      ));
    }
  }

  Future<bool> sendReport(AppState state) async {
    setState(() => _loading = true);
    var success = await state.sendReport(_verificationCode);
    setState(() => _loading = false);

    return success;
  }

  Future<Token> verifyPhone() {
    return showPlatformModalSheet(
        context: context,
        builder: (context) => VerifyPhone(),
        androidIsScrollControlled: true);
  }

  void onCodeChange(context, String code) {
    setState(() => _verificationCode = code);
    if (codeComplete) {
      FocusScope.of(context).unfocus();
    }
  }

  bool get codeComplete => _verificationCode.length == 6;

  List<Widget> getHeading(String title) {
    var authority = Config.get()["healthAuthority"];
    return [
      SizedBox(height: 20),
      Center(
        child:
            Text(authority['name'], style: Theme.of(context).textTheme.caption),
      ),
      Center(
          child: Text(
              'Updated ${DateFormat.yMMMd().format(DateTime.parse(authority['updated']))}',
              style: Theme.of(context).textTheme.caption)),
      SizedBox(height: 10),
      Center(child: Text(title, style: Theme.of(context).textTheme.subtitle1)),
      SizedBox(height: 10),
    ];
  }

  Widget buildReportedView(BuildContext context, AppState state) {
    var alertText = TextStyle(color: Colors.white);

    return Padding(
      padding: EdgeInsets.only(left: 15, right: 15),
      child: ListView(children: [
        SizedBox(height: 15),
        Container(
          decoration: BoxDecoration(
              color: Colors.blueGrey, borderRadius: BorderRadius.circular(10)),
          child: InkWell(
            onTap: () {
              setState(() => _expandHeader = !_expandHeader);
              _expandHeader
                  ? expandController.forward()
                  : expandController.reverse();
            },
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                children: [
                  Row(children: [
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text('Report Submitted',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6
                                  .merge(alertText)),
                          SizedBox(height: 2),
                          Text(
                              'On ${DateFormat.yMMMd().add_jm().format(state.report.timeStamp)}',
                              style: alertText)
                        ])),
                    FaIcon(FontAwesomeIcons.clinicMedical, size: 20)
                  ]),
                  SizeTransition(
                      child: Column(children: [
                        Divider(height: 20, color: Colors.white),
                        Text(
                            'Thank you for submitting your anonymized exposure history. Your data will help people at risk respond faster.',
                            style: alertText),
                        Divider(height: 20, color: Colors.white),
                        Text(
                            'We continue to remind you to follow the prevention guidelines in place to stop further spread of the disease'),
                      ]),
                      axisAlignment: 1.0,
                      sizeFactor: curvedAnimation),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    var enableContinue = true;
    var textTheme = Theme.of(context).textTheme;
    var stepTextTheme = textTheme.subtitle1;

    return Consumer<AppState>(
      builder: (BuildContext context, AppState state, Widget child) {
        if (state.report != null) {
          return PlatformScaffold(
            body: buildReportedView(context, state),
          );
        }
        return PlatformScaffold(
          body: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Builder(
                builder: (context) {
                  return SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        Platform.isIOS
                            ? CupertinoStepper(
                                currentStep: _step,
                                type: StepperType.vertical,
                                onStepContinue: () => setState(() => _step++),
                                onStepTapped: (value) =>
                                    setState(() => _step = value),
                                onStepCancel: () =>
                                    _step == 0 ? null : setState(() => _step--),
                                controlsBuilder: (context,
                                    {onStepCancel, onStepContinue}) {
                                  return _step < 2
                                      ? Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: <Widget>[
                                            CupertinoButton(
                                                color:
                                                    CupertinoColors.activeBlue,
                                                onPressed: enableContinue
                                                    ? onStepContinue
                                                    : null,
                                                child: Text('Continue')),
                                          ],
                                        )
                                      : SizedBox.shrink();
                                },
                                steps: [
                                    Step(
                                      title: Text('Notify Others',
                                          style: textTheme.headline6),
                                      content: Text(
                                        'If you have tested postive for COVID-19, anonymously sharing your diagnosis will help your community contain the spread of the virus.\n\nOnly those who have been exposed will receive a notification.\n\nThis submission is optional.',
                                        style: stepTextTheme,
                                        softWrap: true,
                                      ),
                                    ),
                                    Step(
                                        isActive: _step == 1,
                                        state: _step > 1
                                            ? StepState.complete
                                            : StepState.indexed,
                                        title: Text('What Will Be Shared',
                                            style: textTheme.headline6),
                                        content: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'The random IDs generated by your phone and anonymously exchanged with others you have interacted with over the last 14 days will be shared.\n\nThis app neither collects nor shares any user identifiable information.',
                                                style: stepTextTheme,
                                                softWrap: true,
                                              ),
                                            ])),
                                    Step(
                                        isActive: _step == 2,
                                        title: Text('Verify Diagnosis',
                                            style: textTheme.headline6),
                                        content: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  'Enter the verification code provided by your health official to submit your report.',
                                                  style: stepTextTheme),
                                              Material(
                                                child: CodePin(
                                                    size: 6,
                                                    onChange: (value) =>
                                                        onCodeChange(
                                                            context, value)),
                                              ),
                                              SizedBox(height: 10),
                                              Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    CupertinoButton(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 40),
                                                        color: CupertinoColors
                                                            .activeBlue,
                                                        child: _loading
                                                            ? SizedBox(
                                                                height: 20,
                                                                width: 20,
                                                                child:
                                                                    CupertinoActivityIndicator(),
                                                              )
                                                            : Text("Submit"),
                                                        onPressed: codeComplete
                                                            ? () => onSubmit(
                                                                context, state)
                                                            : null),
                                                  ]),
                                            ])),
                                  ])
                            : Stepper(
                                currentStep: _step,
                                type: StepperType.vertical,
                                onStepContinue: () => setState(() => _step++),
                                onStepTapped: (value) =>
                                    setState(() => _step = value),
                                onStepCancel: () =>
                                    _step == 0 ? null : setState(() => _step--),
                                controlsBuilder: (context,
                                    {onStepCancel, onStepContinue}) {
                                  return _step < 2
                                      ? ButtonBar(
                                          alignment: MainAxisAlignment.start,
                                          children: <Widget>[
                                            RaisedButton(
                                                elevation: 0,
                                                color: Theme.of(context)
                                                    .buttonTheme
                                                    .colorScheme
                                                    .primary,
                                                onPressed: enableContinue
                                                    ? onStepContinue
                                                    : null,
                                                child: Text('Continue')),
                                          ],
                                        )
                                      : SizedBox.shrink();
                                },
                                steps: [
                                    Step(
                                      title: Text('Notify Others',
                                          style: textTheme.headline6),
                                      content: Text(
                                        'If you have tested postive for COVID-19, anonymously sharing your diagnosis will help your community contain the spread of the virus.\n\nOnly those who have been exposed will receive a notification.\n\nThis submission is optional.',
                                        style: stepTextTheme,
                                        softWrap: true,
                                      ),
                                    ),
                                    Step(
                                        isActive: _step == 1,
                                        state: _step > 1
                                            ? StepState.complete
                                            : StepState.indexed,
                                        title: Text('What Will Be Shared',
                                            style: textTheme.headline6),
                                        content: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'The random IDs generated by your phone and anonymously exchanged with others you have interacted with over the last 14 days will be shared.\n\nThis app neither collects nor shares any user identifiable information.',
                                                style: stepTextTheme,
                                                softWrap: true,
                                              ),
                                            ])),
                                    Step(
                                        isActive: _step == 2,
                                        title: Text('Verify Diagnosis',
                                            style: textTheme.headline6),
                                        content: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  'Enter the verification code provided by your health official to submit your report.',
                                                  style: stepTextTheme),
                                              CodePin(
                                                  size: 6,
                                                  onChange: (value) =>
                                                      onCodeChange(
                                                          context, value)),
                                              SizedBox(height: 10),
                                              ButtonBar(
                                                  alignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    RaisedButton(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 40),
                                                        color: Theme.of(context)
                                                            .buttonTheme
                                                            .colorScheme
                                                            .primary,
                                                        child: _loading
                                                            ? SizedBox(
                                                                height: 20,
                                                                width: 20,
                                                                child:
                                                                    CircularProgressIndicator(
                                                                  strokeWidth:
                                                                      2,
                                                                  value: null,
                                                                  valueColor:
                                                                      AlwaysStoppedAnimation(
                                                                          Colors
                                                                              .white),
                                                                ),
                                                              )
                                                            : Text("Submit"),
                                                        onPressed: codeComplete
                                                            ? () => onSubmit(
                                                                context, state)
                                                            : null),
                                                  ]),
                                            ])),
                                  ])
                      ],
                    ),
                  );
                },
              )),
        );
      },
    );
  }
}

// class SharingSuccessPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return PlatformScaffold(
//       body: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
//         child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Text(
//                 'Thank you for sharing your test result',
//                 style: Theme.of(context).textTheme.headline4,
//               ),
//               SizedBox(height: 20),
//               Text(
//                   'We continue to remind you to follow the prevention guidelines in place to stop further spread of the disease'),
//               Expanded(
//                 child: Align(
//                   alignment: FractionalOffset.bottomCenter,
//                   child: Padding(
//                       padding: EdgeInsets.only(bottom: 10.0),
//                       child: PlatformButton(
//                         child: PlatformText('Done'),
//                         onPressed: () {
//                           Navigator.pushReplacement(
//                               context,
//                               platformPageRoute(
//                                   builder: (_) => TraceNav(),
//                                   context: context));
//                         },
//                       )),
//                 ),
//               )
//             ]),
//       ),
//     );
//   }
// }
