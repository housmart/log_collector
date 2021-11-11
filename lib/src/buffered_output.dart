import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'log_storage.dart';
import 'log.dart';
import 'output.dart';
import 'package:synchronized/synchronized.dart';

class BufferedOutput extends Output {
  final LogStorage _logStorage;
  final int flushInterval;
  final int retryLimit;
  final int logCountLimit;
  Timer _timer;
  final _buffer = <Log>[];
  final _chunks = <BufferChunk>[];
  final _lock = Lock();

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
    _reloadLogStorage();
    _flush();
    _startTimer();
  }

  void suspend() {
    _stopTimer();
  }

  void _startTimer() {
    _stopTimer();
    _timer = Timer.periodic(Duration(milliseconds: flushInterval), (timer) {
      _flush();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void emit(Log log) async {
    await _lock.synchronized(() async {
      _buffer.add(log);
    });
    _logStorage.add([log], storageHash);
    if (_buffer.length >= logCountLimit) {
      _flush();
    }
  }

  void _flush() async {
    if (_buffer.length == 0) {
      return;
    }
    List<Log> logs;
    BufferChunk chunk;
    await _lock.synchronized(() async {
      if (logCountLimit < _buffer.length) {
        logs = _buffer.sublist(0, logCountLimit);
        _buffer.removeRange(0, logCountLimit);
      } else {
        logs = List<Log>.of(_buffer);
        _buffer.clear();
      }
      chunk = BufferChunk(logs);
      _chunks.add(chunk);
    });

    _writeChunk(chunk);
  }

  void _writeChunk(BufferChunk chunk) async {
    if (await write(chunk.logs)) {
      await _lock.synchronized(() async {
        _chunks.remove(chunk);
      });
      _logStorage.remove(chunk.logs, storageHash);
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

  String get storageHash =>
      '${this.runtimeType.hashCode}_${tagPattern.pattern.hashCode}';

  Future _reloadLogStorage() async {
    final logs = await _logStorage.retrieveLogs(storageHash);
    final filteredLogs = logs.where((log) {
      return _chunks.firstWhere((chunk) => chunk.logs.contains(log) == true,
              orElse: () => null) ==
          null;
    });
    await _lock.synchronized(() async {
      _buffer.clear();
      _buffer.addAll(filteredLogs);
    });

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
    return 2 * pow(2, retryCount - 1).toInt();
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
