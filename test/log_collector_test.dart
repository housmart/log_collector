import 'package:flutter_test/flutter_test.dart';

void main() {
  test('adds one to input values', () {
    var colors = ["red", "green", "blue", "orange", "pink"];
    final sub = colors.sublist(0, 3);
    colors.removeRange(0, 3);
    expect(sub.length, 3);
    expect(sub[0], "red");
    expect(sub[1], "green");
    expect(sub[2], "blue");
    expect(colors.length, 2);
    expect(colors[0], "orange");
    expect(colors[1], "pink");
  });
}
