import 'package:flutter_test/flutter_test.dart';

import '../lib/src/tag_pattern.dart';

void main() {
  test('test TagPattern', () {
    expect(TagPattern('aa.bb.cc').match('aa.bb.cc'), true);
    expect(TagPattern('aa.bb.cc').match('aa.bb.dd'), false);

    expect(TagPattern('aa.bb.*').match('aa.bb.cc'), true);
    expect(TagPattern('aa.bb.*').match('aa.bb.dd'), true);
    expect(TagPattern('aa.bb.*').match('aa.bb.dd.ee'), false);
    expect(TagPattern('aa.bb.*').match('aa.ff.gg'), false);

    expect(TagPattern('aa.**').match('aa.bb.cc'), true);
    expect(TagPattern('aa.**').match('aa.bb.dd'), true);
    expect(TagPattern('aa.**').match('aa.bb.dd.ee'), true);
    expect(TagPattern('aa.**').match('aa.ff.gg'), true);
    expect(TagPattern('aa.**').match('aa'), false);
    expect(TagPattern('aa.**').match('hh'), false);
    expect(TagPattern('aa.**').match('hh.ii'), false);

    expect(TagPattern('*').match('aa.bb.cc'), false);
    expect(TagPattern('*').match('aa.bb.dd'), false);
    expect(TagPattern('*').match('aa.bb.dd.ee'), false);
    expect(TagPattern('*').match('aa.ff.gg'), false);
    expect(TagPattern('*').match('aa'), true);
    expect(TagPattern('*').match('hh'), true);
    expect(TagPattern('*').match('hh.ii'), false);

    expect(TagPattern('**').match('aa.bb.cc'), true);
    expect(TagPattern('**').match('aa.bb.dd'), true);
    expect(TagPattern('**').match('aa.bb.dd.ee'), true);
    expect(TagPattern('**').match('aa.ff.gg'), true);
    expect(TagPattern('**').match('aa'), true);
    expect(TagPattern('**').match('hh'), true);
    expect(TagPattern('**').match('hh.ii'), true);
  });
}
