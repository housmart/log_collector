
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
class EventFilter extends Filter {
  EventFilter({tagPattern}) : super(tagPattern: tagPattern);

  @override
  List<Log> transform(Log log) {
    if (log.payload['action'] == null) {
      return [];
    } else {
      return [
        log.copyWith(tag: 'ga.event'),
        log.copyWith(
          payload: Map.of(log.payload)..['type'] = 'event',
          tag: 'my.event',
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
  PrintOutput({tagPattern}) : super(tagPattern: tagPattern);

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
    tagPattern,
    flushInterval = 100,
    retryLimit = 3,
    logCountLimit = 5,
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
        print('[MyLog] ${log.loggedAt}:[${log.tag}] ${log.payload}');
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
    EventFilter(tagPattern: 'event'),
    NormalFilter(tagPattern: 'my.*'),
  ],
  outputs: [
    PrintOutput(tagPattern: '**'),
    MyLogOutput(tagPattern: 'my.*'),
    GAEventOutput(tagPattern: 'ga.event'),
  ],
);
```

### Post log


```dart
logger.post({'action': 'click_event_button'}, tag: 'event');
logger.post({'action': 'click_conversion_button'}, tag: 'my.conversion');
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
