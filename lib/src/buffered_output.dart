import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:synchronized/synchronized.dart';

import 'log_storage.dart';
import 'log.dart';
import 'output.dart';

class BufferedOutput extends Output {
  final LogStorage _logStorage;
  final int flushInterval;
  final int retryLimit;
  final int logCountLimit;
  Timer _timer;
  final _buffer = List<Log>();
  final _chunks = List<BufferChunk>();
  final _lock = Lock(reentrant: true);

  BufferedOutput({
    @required tagPattern,
    @required LogStorage logStorage,
    this.flushInterval = 100,
    this.retryLimit = 3,
    this.logCountLimit = 5,
  })  : this._logStorage = logStorage,
        super(tagPattern: tagPattern);

  void dispose() async {
    _stopTimer();
    _logStorage.dispose();
  }

  void start() {
    resume();
  }

  void resume() async {
    await _lock.synchronized(() async {
      _reloadLogStorage();
      _flush();
    });
    _startTimer();
  }

  void suspend() {
    _stopTimer();
  }

  void _startTimer() {
    _stopTimer();
    _timer =
        Timer.periodic(Duration(milliseconds: flushInterval), (timer) async {
      await _lock.synchronized(() async {
        _flush();
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void emit(Log log) async {
    await _lock.synchronized(() async {
      _buffer.add(log);
      _logStorage.add([log], storageName);
      if (_buffer.length >= logCountLimit) {
        _flush();
      }
    });
  }

  void _flush() async {
    if (_buffer.length == 0) {
      return;
    }
    List<Log> logs;
    if (logCountLimit < _buffer.length) {
      logs = _buffer.sublist(0, logCountLimit);
      _buffer.removeRange(0, logCountLimit);
    } else {
      logs = List<Log>.of(_buffer);
      _buffer.clear();
    }

    final chunk = BufferChunk(logs);
    _chunks.add(chunk);
    _writeChunk(chunk);
  }

  void _writeChunk(BufferChunk chunk) async {
    if (await write(chunk.logs)) {
      _chunks.remove(chunk);
      _logStorage.remove(chunk.logs, storageName);
    } else {
      chunk.retryCount++;
      if (chunk.retryCount <= retryLimit) {
        Timer(Duration(milliseconds: chunk.retryMillisecondsDelay), () async {
          await _lock.synchronized(() async {
            _writeChunk(chunk);
          });
        });
      }
    }
  }

  String get storageName => '${tagPattern.pattern}_${this.runtimeType}';

  Future _reloadLogStorage() async {
    _buffer.clear();
    final logs = await _logStorage.retrieveLogs(storageName);
    final filteredLogs = logs.where((log) {
      return _chunks.firstWhere((chunk) => chunk.logs.contains(log),
              orElse: () => null) ==
          null;
    });
    _buffer.addAll(filteredLogs);

    return null;
  }

  Future<bool> write(List<Log> logs) async {
    return false;
  }
}

class BufferChunk {
  final List<Log> logs;
  int retryCount = 0;

  BufferChunk(this.logs);

  int get retryMillisecondsDelay {
    return 2 * pow(2, retryCount - 1);
  }

  @override
  bool operator ==(Object other) =>
      other is BufferChunk &&
      logs.length == other.logs.length &&
      hashCode == other.hashCode;

  String get toJsonString => Log.jsonStringFromLogs(logs);

  @override
  int get hashCode => toJsonString.hashCode;
}
