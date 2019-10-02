import 'dart:async';

import 'package:flutter/foundation.dart';

import 'filter.dart';
import 'log.dart';
import 'output.dart';

class Logger {
  final _streamController = StreamController<Log>.broadcast();
  final List<Output> _outputs;

  Logger({List<Filter> filters, @required List<Output> outputs})
      : assert(outputs != null),
        _outputs = outputs {
    if (filters != null && filters.length > 0) {
      filters.forEach((filter) {
        _streamController.stream
            .where(filter.where)
            .transform(filter.streamTransformer)
            .where((logs) => logs.length > 0)
            .listen(
          (logs) {
            logs.forEach((log) {
              outputs
                  .where((output) => output.where(log))
                  .forEach((output) => output.emit(log));
            });
          },
        );
      });
    } else {
      _streamController.stream.listen((log) {
        outputs
            .where((output) => output.where(log))
            .forEach((output) => output.emit(log));
      });
    }
    _start();
  }

  void dispose() async {
    await _streamController.close();
    final outputs = _outputs;
    _outputs.clear();
    Timer.run(() {
      outputs.forEach((output) => output.dispose());
    });
  }

  void post(Map<String, Object> payload, {String tag}) {
    _streamController.sink.add(
      Log(
        payload: payload,
        tag: tag,
        loggedAt: DateTime.now(),
      ),
    );
  }

  void _start() {
    _outputs.forEach((output) => output.start());
  }

  void suspend() {
    Timer.run(() {
      _outputs.forEach((output) => output.suspend());
    });
  }

  void resume() {
    Timer.run(() {
      _outputs.forEach((output) => output.resume());
    });
  }
}
