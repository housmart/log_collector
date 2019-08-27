import 'dart:io';

import 'package:log_collector/src/log_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:synchronized/synchronized.dart';

import 'log.dart';

class FileLogStorage extends LogStorage {
  final _storedLogs = List<Log>();
  final _lock = Lock();

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> _localFile(String storageHash) async {
    final path = await _localPath;
    return File('$path/$storageHash');
  }

  Future<List<Log>> retrieveLogs(String storageHash) async {
    List<Log> storedLogs;
    final file = await _localFile(storageHash);
    if (await file.exists()) {
      String contents = await file.readAsString();
      await _lock.synchronized(() async {
        _storedLogs.clear();
        _storedLogs.addAll(Log.logsFromJsonString(contents));
        storedLogs = List.from(_storedLogs);
      });
    } else {
      storedLogs = List.from(_storedLogs);
    }
    return storedLogs;
  }

  Future add(List<Log> logs, String storageHash) async {
    List<Log> storedLogs;
    await _lock.synchronized(() async {
      _storedLogs.addAll(logs);
      storedLogs = List.from(_storedLogs);
      await _save(storedLogs, storageHash);
    });
    return;
  }

  Future remove(List<Log> logs, String storageHash) async {
    List<Log> storedLogs;
    await _lock.synchronized(() async {
      _storedLogs.removeWhere((log) => logs.contains(log));
      storedLogs = List.from(_storedLogs);
      await _save(storedLogs, storageHash);
    });
    return;
  }

  Future _save(List<Log> logs, String storageHash) async {
    final file = await _localFile(storageHash);
    print('save: ${logs.length}');
    file.writeAsStringSync(Log.jsonStringFromLogs(logs));
    return;
  }
}
