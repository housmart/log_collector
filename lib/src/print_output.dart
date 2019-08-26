import 'package:flutter/foundation.dart';

import 'log.dart';
import 'output.dart';

class PrintOutput extends Output {
  PrintOutput({
    @required tagPattern,
  }) : super(tagPattern: tagPattern);

  @override
  void emit(Log log) {
    print('${log.loggedAt}:[${log.tag}] ${log.payload}');
  }
}
