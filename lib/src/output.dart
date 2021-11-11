import 'log.dart';
import 'tag_pattern.dart';

abstract class Output {
  final TagPattern tagPattern;

  Output({
    required String tagPattern,
  }) : this.tagPattern = TagPattern(tagPattern);

  bool where(Log log) {
    return tagPattern.match(log.tag);
  }

  void dispose() async {}

  void start() {}

  void resume() {}

  void suspend() {}

  void emit(Log log);

  Future<bool> write(List<Log> logs) async {
    return true;
  }
}
