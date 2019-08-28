import 'package:log_collector/log_collector.dart';

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
