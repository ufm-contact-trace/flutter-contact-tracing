import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:ug_covid_trace/utils/operator.dart';

class VerifyPhone extends StatefulWidget {
  @override
  _VerifyPhoneState createState() => _VerifyPhoneState();
}

class _VerifyPhoneState extends State<VerifyPhone>
    with SingleTickerProviderStateMixin {
  final _phoneForm = GlobalKey<FormState>();
  final _codeForm = GlobalKey<FormState>();
  final phoneController = TextEditingController();
  final codeController = TextEditingController();
  FocusNode codeFocus;
  AnimationController slideController;
  var animation;
  String _phoneToken;
  String _phoneError;
  String _codeError;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    codeFocus = FocusNode();
    slideController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    animation = Tween<Offset>(begin: Offset(1, 0), end: Offset.zero).animate(
        CurvedAnimation(parent: slideController, curve: Curves.fastOutSlowIn));
  }

  @override
  void dispose() {
    codeFocus.dispose();
    slideController.dispose();
    phoneController.dispose();
    codeController.dispose();
    super.dispose();
  }

  Future<void> requestCode(String number) async {
    setState(() => _loading = true);
    var token = await Operator.init(number);
    setState(() => _loading = false);

    if (token == null) {
      setState(() =>
          _phoneError = 'There was an error requestion a verification code');
      return;
    }

    _phoneToken = token;
    slideController.forward();
    codeFocus.requestFocus();
  }

  Future<void> verifyCode(String code) async {
    setState(() => _loading = true);
    var token = await Operator.verify(_phoneToken, code);
    setState(() => _loading = false);

    if (token == null) {
      setState(() => _codeError = 'The code provided was incorrect');
      codeController.text = '';
      return;
    }

    if (token.valid) {
      Navigator.pop(context);
    } else {
      setState(() => _codeError = 'Something went wrong');
      codeController.text = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    var loadIndicator = SizedBox(
        width: 20,
        height: 20,
        child: Platform.isIOS
            ? CupertinoActivityIndicator()
            : CircularProgressIndicator(
                strokeWidth: 2,
                value: null,
                valueColor: AlwaysStoppedAnimation(
                    Theme.of(context).textTheme.button.color)));
    return SingleChildScrollView(
      padding: EdgeInsets.only(
          top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Form(
              key: _phoneForm,
              child: Column(
                children: <Widget>[
                  Text(
                    'We need to verify your app the first time you submit data. Please enter your phone number to receive a verification code.',
                    softWrap: true,
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1
                        .merge(TextStyle(height: 1.4)),
                  ),
                  PlatformTextField(
                    autofocus: true,
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    onChanged: (value) => setState(() => _phoneError = null),
                    maxLength: 10,
                    maxLengthEnforced: true,
                    maxLines: 1,
                    textInputAction: TextInputAction.done,
                    material: (_, __) => MaterialTextFieldData(
                      decoration: InputDecoration(
                          labelText: 'Phone Number',
                          errorText: _phoneError,
                          border: OutlineInputBorder()),
                    ),
                    cupertino: (_, __) => CupertinoTextFieldData(
                      clearButtonMode: OverlayVisibilityMode.editing,
                      placeholder: 'Phone Number',
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Your phone number is never saved or associated with any data you submit.',
                    style: Theme.of(context).textTheme.caption,
                  ),
                  SizedBox(height: 20),
                  PlatformButton(
                    child: _loading ? loadIndicator : Text('Submit'),
                    onPressed: () {
                      if (_phoneForm.currentState.validate()) {
                        requestCode(phoneController.text);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          Positioned.fill(
              child: SlideTransition(
            position: animation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Material(
                child: Form(
                    key: _codeForm,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Enter the code sent to your phone',
                          textAlign: TextAlign.left,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1
                              .merge(TextStyle(height: 1.4)),
                        ),
                        PlatformTextField(
                          focusNode: codeFocus,
                          controller: codeController,
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() => _codeError = null);
                            if (value.length == 6 &&
                                _codeForm.currentState.validate()) {
                              verifyCode(codeController.text);
                            }
                          },
                          maxLength: 6,
                          maxLengthEnforced: true,
                          maxLines: 1,
                          textInputAction: TextInputAction.done,
                          material: (_, __) => MaterialTextFieldData(
                            decoration: InputDecoration(
                                labelText: 'Code',
                                errorText: _codeError,
                                border: OutlineInputBorder()),
                          ),
                          cupertino: (_, __) => CupertinoTextFieldData(
                            clearButtonMode: OverlayVisibilityMode.editing,
                            placeholder: 'Code',
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Center(
                          child: PlatformButton(
                            child: _loading ? loadIndicator : Text('Submit'),
                            onPressed: () {
                              if (_codeForm.currentState.validate()) {
                                verifyCode(codeController.text);
                              }
                            },
                          ),
                        )
                      ],
                    )),
              ),
            ),
          ))
        ],
      ),
    );
  }
}
