import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:log_collector/src/log_storage.dart';
import 'package:path_provider/path_provider.dart';

import 'log.dart';

class FileLogStorage extends LogStorage {
  final _storedLogs = List<Log>();

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> _localFile(String storageName) async {
    final path = await _localPath;
    return File('$path/${_hash(storageName)}');
  }

  String _hash(String storageName) {
    return sha1.convert(utf8.encode(storageName)).toString();
  }

  Future<List<Log>> retrieveLogs(String storageName) async {
    _storedLogs.clear();
    final file = await _localFile(storageName);
    if (await file.exists()) {
      String contents = await file.readAsString();
      _storedLogs.addAll(Log.logsFromJsonString(contents));
    }
    return _storedLogs;
  }

  Future add(List<Log> logs, String storageName) async {
    _storedLogs.addAll(logs);
    return _save(storageName);
  }

  Future remove(List<Log> logs, String storageName) async {
    _storedLogs.removeWhere((log) => logs.contains(log));
    return _save(storageName);
  }

  Future _save(String storageName) async {
    final file = await _localFile(storageName);
    file.writeAsStringSync(Log.jsonStringFromLogs(_storedLogs));
  }
}
