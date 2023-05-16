// ignore_for_file: prefer_const_constructors

import 'package:flutter_daemon/flutter_daemon.dart';
import 'package:test/test.dart';

void main() {
  group('$AppDetachRequest', () {
    test('can construct one', () {
      final request = AppDetachRequest('appId');

      expect(request.parameters, equals({'appId': 'appId'}));
    });
  });

  group('$AppDetachResponse', () {
    test('can construct one from JSON', () {
      final response = AppDetachResponse.fromJSON({
        'id': 0,
        'result': true,
      });

      expect(response.id, equals(0));
      expect(response.result, isTrue);
    });
  });
}
