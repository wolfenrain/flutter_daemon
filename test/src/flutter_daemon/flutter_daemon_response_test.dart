import 'package:flutter_daemon/flutter_daemon.dart';
import 'package:test/test.dart';

void main() {
  group('$FlutterDaemonResponse', () {
    test('can construct one from JSON', () {
      final response = FlutterDaemonResponse<bool>.fromJSON({
        'id': 1,
        'result': true,
      });

      expect(response.id, equals(1));
      expect(response.result, isTrue);
      expect(response.error, isNull);
    });

    test('hasError', () {
      final response1 = FlutterDaemonResponse<bool>.fromJSON({
        'id': 1,
        'result': true,
      });

      expect(response1.hasError, isFalse);

      final response2 = FlutterDaemonResponse<bool>.fromJSON({
        'id': 1,
        'error': 'error',
      });

      expect(response2.hasError, isTrue);
    });

    test('toString', () {
      final response = FlutterDaemonResponse<bool>.fromJSON({
        'id': 1,
        'result': true,
      });

      expect(
        response.toString(),
        equals('Response(1) {result: true, error: null}'),
      );
    });
  });
}
