
# Dart Log Collector

[![pub package](https://img.shields.io/pub/v/log_collector.svg)](https://pub.dartlang.org/packages/log_collector)

Provides log filtering, buffering, and retry.

Inspired by [cookpad/Puree-Swift](https://github.com/cookpad/Puree-Swift).

# Usage

### Define your own Filter/Output

#### Filter

`Filter` converts `Log` to `List<Log>`.

You can increase the log, transform it, or empty it.

```dart
class ActionFilter extends Filter {
  ActionFilter({String tagPattern}) : super(tagPattern: tagPattern);

  @override
  List<Log> transform(Log log) {
    final target = log.payload['target'];
    final type = log.payload['type'];
    if (target is! String || type is! String) {
      return [];
    } else {
      final properties = Map.of(log.payload)..remove('type');
      return [
        log.copyWith(
          tag: 'ga.action',
          payload: {
            'event_name': type,
            'properties': properties,
          },
        ),
        log.copyWith(
          tag: 'my.action',
          payload: {
            'event_name': '${type}_$target',
            'properties': Map.of(properties)..remove('target'),
          },
        ),
      ];
    }
  }
}
```

#### Output

`Output` does not provide buffering and retrying.

The following `PrintOutput` will output logs to the console.

```dart
class PrintOutput extends Output {
  PrintOutput({String tagPattern}) : super(tagPattern: tagPattern);

  @override
  void emit(Log log) {
    print('${log.loggedAt}:[${log.tag}] ${log.payload}');
  }
}
```

#### BufferedOutput

`BufferedOutput` provide buffering and retrying.

```dart
class MyLogOutput extends BufferedOutput {
  MyLogOutput({
    String tagPattern,
    int flushInterval = 100,
    int retryLimit = 3,
    int logCountLimit = 5,
  }) : super(
            tagPattern: tagPattern,
            logStorage: FileLogStorage(),
            flushInterval: flushInterval,
            retryLimit: retryLimit,
            logCountLimit: logCountLimit);

  Future<bool> write(List<Log> logs) async {
    // TODO: send logs to your server.
    return Future<bool>.delayed(Duration(milliseconds: 50), () {
      logs.forEach((log) {
        final eventName = log.payload['event_name'];
        final properties = log.payload['properties'];
        print('🥝[MyLog] ${log.loggedAt}:[$eventName] $properties');
      });
      // if return false, retrying.
      return true;
    });
  }
}
```

### Make logger

Only `Filter` and `Output` that match `TagPattern` are used.

```dart
final logger = Logger(
  filters: [
    PageViewFilter(tagPattern: 'page'),
    ActionFilter(tagPattern: 'action'),
  ],
  outputs: [
    PrintOutput(tagPattern: '**'),
    MyLogOutput(tagPattern: 'my.**'),
    AnalyticsOutput(tagPattern: 'ga.**'),
  ],
);
```

### Post log


```dart
logger.post({'name': 'page1'}, tag: 'page_view');
logger.post({'type': 'click', 'target': 'event_button'}, tag: 'action');
```

### TagPattern matching.


```dart
expect(TagPattern('aa.bb.cc').match('aa.bb.cc'), true);
expect(TagPattern('aa.bb.cc').match('aa.bb.dd'), false);
expect(TagPattern('aa.bb.cc').match('aa.bb'), false);
expect(TagPattern('aa.bb.cc').match('aa.bb.cc.dd'), false);

expect(TagPattern('aa.bb.*').match('aa.bb.cc'), true);
expect(TagPattern('aa.bb.*').match('aa.bb.cc.dd'), false);
expect(TagPattern('aa.bb.*').match('aa.bb'), false);

expect(TagPattern('aa.**').match('aa.bb.cc'), true);
expect(TagPattern('aa.**').match('aa.bb.cc.dd'), true);
expect(TagPattern('aa.**').match('aa'), false);

expect(TagPattern('*').match('aa.bb'), false);
expect(TagPattern('*').match('aa'), true);
expect(TagPattern('*').match('bb'), true);

expect(TagPattern('**').match('aa.bb.cc'), true);
expect(TagPattern('**').match('aa.bb'), true);
expect(TagPattern('**').match('aa'), true);
```
