import 'log.dart';

abstract class LogStorage {
  void prepare() {}
  void dispose() {}
  Future<List<Log>> retrieveLogs(String storageHash);
  Future add(List<Log> logs, String storageHash);
  Future remove(List<Log> logs, String storageHash);
}
