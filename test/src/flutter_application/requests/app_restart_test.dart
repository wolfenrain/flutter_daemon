// ignore_for_file: prefer_const_constructors

import 'package:flutter_daemon/flutter_daemon.dart';
import 'package:test/test.dart';

void main() {
  group('$AppRestartRequest', () {
    test('can construct one', () {
      final request = AppRestartRequest('appId');

      expect(
        request.parameters,
        equals({
          'appId': 'appId',
          'fullRestart': null,
          'reason': null,
          'pause': null,
          'debounce': null
        }),
      );
    });
  });

  group('$AppRestartResponse', () {
    test('can construct one from JSON', () {
      final response = AppRestartResponse.fromJSON({
        'id': 0,
        'result': {
          'code': 0,
          'message': 'message',
        },
      });

      expect(response.id, equals(0));
      expect(response.code, equals(0));
      expect(response.message, equals('message'));
    });
  });
}
