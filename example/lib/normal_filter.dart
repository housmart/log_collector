import 'package:log_collector/log_collector.dart';

class NormalFilter extends Filter {
  NormalFilter({tagPattern}) : super(tagPattern: tagPattern);

  @override
  List<Log> transform(Log log) {
    return [log];
  }
}
