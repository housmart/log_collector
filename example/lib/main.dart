import 'package:flutter/material.dart';
import 'package:log_collector/log_collector.dart';

import 'event_filter.dart';
import 'ga_event_output.dart';
import 'my_log_output.dart';
import 'print_output.dart';
import 'normal_filter.dart';

void main() => runApp(MyApp());

final logger = Logger(
  filters: [
    EventFilter(tagPattern: 'event'),
    NormalFilter(tagPattern: 'my.*'),
  ],
  outputs: [
    PrintOutput(tagPattern: '**'),
    MyLogOutput(tagPattern: 'my.*'),
    GAEventOutput(tagPattern: 'ga.event'),
  ],
);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Log Collector Demo')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RaisedButton(
                child: Text('event'),
                onPressed: () {
                  logger.post({
                    'action': 'click_event_button',
                  }, tag: 'event');
                },
              ),
              SizedBox(height: 16),
              RaisedButton(
                child: Text('conversion'),
                onPressed: () {
                  logger.post({
                    'action': 'click_conversion_button',
                  }, tag: 'my.conversion');
                },
              ),
              SizedBox(height: 16),
              RaisedButton(
                child: Text('ignore'),
                onPressed: () {
                  logger.post({
                    'action': 'click_ignore_button',
                  }, tag: 'foo');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
