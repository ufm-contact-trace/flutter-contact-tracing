import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text('Settings'),
        automaticallyImplyLeading: false,
      ),
      body: Column(children: [
        ListTile(
            title: Text('Change Language'),
            onTap: () {
              if (Platform.isIOS) {
                showCupertinoModalPopup(
                  context: context,
                  builder: (_) => CupertinoActionSheet(
                    title: Text('Change App Language'),
                    actionScrollController: FixedExtentScrollController(),
                    actions: <Widget>[
                      CupertinoActionSheetAction(
                        onPressed: () {
                          //Will set app language
                        },
                        child: Text('English'),
                        isDefaultAction: true,
                      ),
                      CupertinoActionSheetAction(
                        onPressed: () {
                          //Will set app language
                        },
                        child: Text('Luganda'),
                        isDefaultAction: true,
                      ),
                      CupertinoActionSheetAction(
                        onPressed: () {
                          //Will set app language
                        },
                        child: Text('Arabic'),
                        isDefaultAction: true,
                      ),
                    ],
                    cancelButton: CupertinoActionSheetAction(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancel')),
                  ),
                );
              } else if (Platform.isAndroid) {
                showModalBottomSheet(
                    context: context,
                    builder: (_) => Container(
                          height: 300,
                          child: ListView(
                            children: <Widget>[
                              ListTile(title: Text('English')),
                              ListTile(title: Text('Luganda')),
                              ListTile(title: Text('Arabic')),
                            ],
                          ),
                        ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10))));
              }
            }),
        ListTile(
          title: Text('FAQs'),
          trailing: Icon(context.platformIcons.rightChevron),
        ),
        ListTile(
          title: Text('Privacy Policy'),
          trailing: Icon(context.platformIcons.rightChevron),
        ),
        ListTile(
          title: Text('Terms of Service'),
          trailing: Icon(context.platformIcons.rightChevron),
        ),
        ListTile(
          title: Text('About UGTrace'),
          onTap: () => showLicensePage(
              context: context,
              applicationName: 'UGTrace',
              applicationVersion: '0.0.1'),
        ),
        ListTile(
          title: Text('Delete Data'),
          subtitle: Text(
              'This will remove all data related to this application from this device'),
          onTap: () {
            showPlatformDialog(
              builder: (_) => PlatformAlertDialog(
                title: Text('Delete all your data from Ug Covid Trace?'),
                actions: <Widget>[
                  PlatformDialogAction(
                    child: Text('Cancel'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  PlatformDialogAction(
                    child: Text('Delete'),
                    onPressed: () {
                      //Call the delete data endpoint
                    },
                  ),
                ],
              ),
              context: context,
            );
          },
        ),
      ]),
    );
  }
}
