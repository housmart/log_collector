import 'package:log_collector/log_collector.dart';

class KeenOutput extends BufferedOutput {
  KeenOutput({
    tagPattern,
  }) : super(
          tagPattern: tagPattern,
          logStorage: FileLogStorage(),
          flushInterval: 2000,
        );

  Future<bool> write(List<Log> logs) async {
    return Future<bool>.delayed(Duration(milliseconds: 50), () {
      logs.forEach((log) {
        print('[Keen] ${log.loggedAt}:[${log.tag}] ${log.payload}');
      });
      return true;
    });
  }
}
