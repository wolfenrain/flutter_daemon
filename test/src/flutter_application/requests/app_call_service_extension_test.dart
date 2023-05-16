// ignore_for_file: prefer_const_constructors

import 'package:flutter_daemon/flutter_daemon.dart';
import 'package:test/test.dart';

void main() {
  group('$AppCallServiceExtensionRequest', () {
    test('can construct one', () {
      final request = AppCallServiceExtensionRequest(
        'appId',
        'methodName',
        params: {
          'parameter': 1,
        },
      );

      expect(
        request.parameters,
        equals({
          'appId': 'appId',
          'methodName': 'methodName',
          'params': {'parameter': 1}
        }),
      );
    });
  });

  group('$AppCallServiceExtensionResponse', () {
    test('can construct one from JSON', () {
      final response = AppCallServiceExtensionResponse.fromJSON({
        'id': 0,
        'result': {
          'key': 'value',
        },
      });

      expect(response.id, equals(0));
      expect(response.result, equals({'key': 'value'}));
    });
  });
}
