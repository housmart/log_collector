import 'package:flutter/foundation.dart';
import 'package:log_collector/log_collector.dart';

class PrintOutput extends Output {
  PrintOutput({
    @required tagPattern,
  }) : super(tagPattern: tagPattern);

  @override
  void emit(Log log) {
    print('${log.loggedAt}:[${log.tag}] ${log.payload}');
  }
}
