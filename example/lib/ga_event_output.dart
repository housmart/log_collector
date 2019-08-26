import 'package:log_collector/log_collector.dart';

class GAEventOutput extends BufferedOutput {
  GAEventOutput({
    tagPattern,
  }) : super(
          tagPattern: tagPattern,
          logStorage: FileLogStorage(),
        );

  Future<bool> write(List<Log> logs) async {
    return Future<bool>.delayed(Duration(milliseconds: 50), () {
      logs.forEach((log) {
        print('[GAEvent] ${log.loggedAt}:[${log.tag}] ${log.payload}');
      });
      return true;
    });
  }
}
