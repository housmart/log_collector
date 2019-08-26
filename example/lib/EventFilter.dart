import 'package:flutter/foundation.dart';
import 'package:log_collector/log_collector.dart';

class EventFilter extends Filter {
  EventFilter({
    @required tagPattern,
  })  : assert(tagPattern != null),
        super(tagPattern: tagPattern);

  @override
  List<Log> transform(Log log) {
    return [
      Log(
        payload: log.payload,
        tag: 'ga.event',
        loggedAt: log.loggedAt,
      ),
      Log(
        payload: Map.of(log.payload)..['type'] = 'event',
        tag: 'keen.event',
        loggedAt: log.loggedAt,
      ),
    ];
  }
}
