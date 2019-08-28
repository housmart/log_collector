import 'dart:async';

import 'package:flutter/foundation.dart';

import 'log.dart';
import 'tag_pattern.dart';

abstract class Filter {
  final TagPattern tagPattern;

  Filter({
    @required String tagPattern,
  })  : assert(tagPattern != null),
        this.tagPattern = TagPattern(tagPattern);

  List<Log> transform(Log log);

  bool where(Log log) {
    return tagPattern.match(log.tag);
  }

  StreamTransformer<Log, List<Log>> get streamTransformer {
    return StreamTransformer<Log, List<Log>>.fromHandlers(
        handleData: (log, sink) {
      sink.add(transform(log) ?? []);
    });
  }
}
