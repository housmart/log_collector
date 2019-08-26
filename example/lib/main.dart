import 'package:flutter/material.dart';
import 'package:log_collector/log_collector.dart';
import 'package:provider/provider.dart';

import 'EventFilter.dart';
import 'ga_event_output.dart';
import 'ga_screen_output.dart';
import 'keen_output.dart';
import 'my_home_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider<Logger>(
      builder: (_) => Logger(
        filters: [
          StandardFilter(
            tagPattern: 'screen',
            onTransform: (log) {
              return [
                Log(
                  payload: log.payload,
                  tag: 'ga.screen',
                  loggedAt: log.loggedAt,
                ),
                Log(
                  payload: Map.of(log.payload)..['type'] = 'screen',
                  tag: 'keen.screen',
                  loggedAt: log.loggedAt,
                ),
              ];
            },
          ),
          EventFilter(tagPattern: 'event'),
        ],
        outputs: [
          PrintOutput(tagPattern: '**'),
          GAScreenOutput(tagPattern: 'ga.screen'),
          GAEventOutput(tagPattern: 'ga.event'),
          KeenOutput(tagPattern: 'keen.*'),
        ],
      ),
      dispose: (_, logger) => logger.dispose(),
      child: MaterialApp(
        title: 'Log Collector Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(title: 'Log Collector Demo'),
      ),
    );
  }
}
