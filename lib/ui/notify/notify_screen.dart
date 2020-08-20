import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:ug_covid_trace/ui/notify/notify_entry_form_screen.dart';

class NotifyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text('Notify Others'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Share your positive test result',
                style: Theme.of(context).textTheme.headline4,
              ),
              SizedBox(height: 20),
              Text(
                'If you have tested positive for COVID-19, sharing your test result will help notify others who may have been exposed. This will let others in your community know if they should monitor for symptoms & contain the spread of the virus. This does not share any personally identifying information.',
                style: Theme.of(context)
                    .textTheme
                    .bodyText2
                    .copyWith(fontSize: 20),
                softWrap: true,
              ),
              SizedBox(height: 20),
              PlatformButton(
                child: PlatformText('Share Positive Test Result'),
                onPressed: () {
                  Navigator.push(
                      context,
                      platformPageRoute(
                          builder: (_) => NotifyEntryFormScreen(),
                          context: context,
                          fullscreenDialog: true));
                },
              )
            ]),
      ),
    );
  }
}
