import 'package:log_collector/log_collector.dart';

class MyLogOutput extends BufferedOutput {
  MyLogOutput({
    tagPattern,
  }) : super(
          tagPattern: tagPattern,
          logStorage: FileLogStorage(),
        );

  Future<bool> write(List<Log> logs) async {
    // send log to your web server
    return Future<bool>.delayed(Duration(milliseconds: 50), () {
      logs.forEach((log) {
        print('[MyLog] ${log.loggedAt}:[${log.tag}] ${log.payload}');
      });
      return true;
    });
  }
}
