// ignore_for_file: prefer_const_constructors

import 'package:flutter_daemon/flutter_daemon.dart';
import 'package:test/test.dart';

void main() {
  group('$FlutterDaemonRequest', () {
    test('can construct one', () {
      final request = _TestRequest(
        'test',
        FlutterDaemonResponse<dynamic>.fromJSON,
      );

      expect(request.method, equals('test'));
      expect(request.response, equals(FlutterDaemonResponse<dynamic>.fromJSON));
    });

    test('toJSON', () {
      final request = _TestRequest(
        'test',
        FlutterDaemonResponse<dynamic>.fromJSON,
      );

      expect(
        request.toJSON(1),
        equals({'id': 1, 'method': 'test', 'params': <String, dynamic>{}}),
      );
    });
  });
}

class _TestRequest
    extends FlutterDaemonRequest<FlutterDaemonResponse<dynamic>> {
  _TestRequest(super.method, super.response);
}
