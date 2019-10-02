import 'package:example/pageview_filter.dart';
import 'package:flutter/material.dart';
import 'package:log_collector/log_collector.dart';

import 'action_filter.dart';
import 'analytics_output.dart';
import 'my_log_output.dart';
import 'print_output.dart';

void main() => runApp(MyApp());

final logger = Logger(
  filters: [
    PageViewFilter(tagPattern: 'page_view'),
    ActionFilter(tagPattern: 'action'),
  ],
  outputs: [
    PrintOutput(tagPattern: '**'),
    MyLogOutput(tagPattern: 'my.**'),
    AnalyticsOutput(tagPattern: 'ga.**'),
  ],
);

class MyApp extends StatelessWidget {
  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    logger.post({
      'name': settings.name,
    }, tag: 'page_view');
    switch (settings.name) {
      case 'page2':
        return MaterialPageRoute(builder: (_) => Page2(), settings: settings);
      case 'page3':
        return MaterialPageRoute(builder: (_) => Page3(), settings: settings);
      default:
        return MaterialPageRoute(builder: (_) => Page1(), settings: settings);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: 'page1',
      onGenerateRoute: _onGenerateRoute,
    );
  }
}

class Page1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Log Collector Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RaisedButton(
              child: Text('event'),
              onPressed: () {
                logger.post({
                  'page': 'page1',
                  'type': 'click',
                  'target': 'event_button',
                }, tag: 'action');
              },
            ),
            SizedBox(height: 16),
            RaisedButton(
              child: Text('conversion'),
              onPressed: () {
                logger.post({
                  'page': 'page1',
                  'type': 'click',
                  'target': 'conversion_button',
                  'foo': 123,
                  'bar': 'abc',
                }, tag: 'action');
              },
            ),
            SizedBox(height: 16),
            RaisedButton(
              child: Text('Page 2'),
              onPressed: () => Navigator.of(context).pushNamed('page2'),
            ),
            SizedBox(height: 16),
            RaisedButton(
              child: Text('Page 3'),
              onPressed: () => Navigator.of(context).pushNamed('page3'),
            ),
          ],
        ),
      ),
    );
  }
}

class Page2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Page 2')),
      body: Center(
        child: RaisedButton(
          child: Text('Page 3'),
          onPressed: () => Navigator.of(context).pushNamed('page3'),
        ),
      ),
    );
  }
}

class Page3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Page 3')),
      body: Center(
        child: RaisedButton(
          child: Text('Back'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }
}
