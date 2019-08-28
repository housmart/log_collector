import 'package:log_collector/log_collector.dart';

class MyLogOutput extends BufferedOutput {
  MyLogOutput({
    tagPattern,
    flushInterval = 100,
    retryLimit = 3,
    logCountLimit = 5,
  }) : super(
            tagPattern: tagPattern,
            logStorage: FileLogStorage(),
            flushInterval: flushInterval,
            retryLimit: retryLimit,
            logCountLimit: logCountLimit);

  Future<bool> write(List<Log> logs) async {
    // TODO: send logs to your server.
    return Future<bool>.delayed(Duration(milliseconds: 50), () {
      logs.forEach((log) {
        print('[MyLog] ${log.loggedAt}:[${log.tag}] ${log.payload}');
      });
      // if return false, retrying.
      return true;
    });
  }
}
