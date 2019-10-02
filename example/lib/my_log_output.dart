import 'package:log_collector/log_collector.dart';

class MyLogOutput extends BufferedOutput {
  MyLogOutput({
    String tagPattern,
    int flushInterval = 100,
    int retryLimit = 3,
    int logCountLimit = 5,
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
        final eventName = log.payload['event_name'];
        final properties = log.payload['properties'];
        print('🥝[MyLog] ${log.loggedAt}:[$eventName] $properties');
      });
      // if return false, retrying.
      return true;
    });
  }
}
