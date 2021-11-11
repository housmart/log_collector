import 'dart:convert';

class Log {
  final Map<String, Object> payload;
  final String tag;
  final DateTime loggedAt;

  Log({
    required this.payload,
    required this.tag,
    required DateTime loggedAt,
  }) : loggedAt = loggedAt;

  Log copyWith({
    Map<String, Object>? payload,
    String? tag,
    DateTime? loggedAt,
  }) {
    return Log(
      payload: payload ?? this.payload,
      tag: tag ?? this.tag,
      loggedAt: loggedAt ?? this.loggedAt,
    );
  }

  factory Log.fromJsonString(String jsonString) {
    final map = json.decode(jsonString);
    return Log.fromMap(map);
  }

  factory Log.fromMap(Map map) {
    return Log(
      payload: (map['payload'] as Map).cast<String, Object>(),
      tag: map['tag'] as String,
      loggedAt: DateTime.fromMillisecondsSinceEpoch(map['loggedAt'] as int),
    );
  }

  String get toJsonString {
    final map = {
      'payload': payload,
      'tag': tag,
      'loggedAt': loggedAt.millisecondsSinceEpoch,
    };
    return json.encode(map);
  }

  static String jsonStringFromLogs(List<Log> logs) {
    return '[${logs.map((log) => log.toJsonString).join(',')}]';
  }

  static List<Log> logsFromJsonString(String jsonString) {
    try {
      final array = json.decode(jsonString) as List;
      return array.cast<Map>().map((map) => Log.fromMap(map)).toList();
    } on Exception catch (_) {
      return [];
    }
  }
}
