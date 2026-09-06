import 'package:flutter_test/flutter_test.dart';
import 'package:azzaops_mobile/app/core/utils/helpers.dart';

void main() {
  test('format ISO date string to DD-Bln-YYYY', () {
    expect(DateHelper.formatDate('2026-08-10T17:00:00.000000Z'), isNotEmpty);
    expect(DateHelper.formatDate('2026-08-11'), '11-Agu-2026');
  });

  test('format time string', () {
    expect(DateHelper.formatTime('06:23:00'), '06:23');
    expect(DateHelper.formatTime('13:00:00'), '13:00');
  });

  test('format datetime with separate time', () {
    final res = DateHelper.formatDateTime('2026-08-10T17:00:00.000000Z', timeStr: '06:23:00');
    expect(res.contains('06:23'), isTrue);
  });
}
