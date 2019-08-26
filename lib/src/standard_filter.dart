import 'package:flutter/foundation.dart';

import 'filter.dart';
import 'log.dart';

typedef Transform = List<Log> Function(Log log);

class StandardFilter extends Filter {
  final Transform onTransform;

  StandardFilter({
    @required tagPattern,
    Transform onTransform,
  })  : assert(tagPattern != null),
        this.onTransform = onTransform ?? ((log) => [log]),
        super(tagPattern: tagPattern);

  @override
  List<Log> transform(Log log) {
    return onTransform(log);
  }
}
