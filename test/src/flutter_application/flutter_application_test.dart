// ignore_for_file: prefer_const_constructors

import 'package:flutter_daemon/flutter_daemon.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockFlutterDaemon extends Mock implements FlutterDaemon {}

void main() {
  group('$FlutterApplication', () {
    late FlutterDaemon daemon;
    late FlutterApplication application;

    setUp(() {
      daemon = _MockFlutterDaemon();
      when(() => daemon.request(any<AppStopRequest>())).thenAnswer((_) async {
        final request = _.positionalArguments.first as AppStopRequest;
        return request.response({
          'id': 0,
          'result': true,
        });
      });
      when(() => daemon.request(any<AppRestartRequest>()))
          .thenAnswer((_) async {
        final request = _.positionalArguments.first as AppRestartRequest;
        return request.response({
          'id': 0,
          'result': {'code': 0, 'message': 'message'},
        });
      });
      when(() => daemon.request(any<AppDetachRequest>())).thenAnswer((_) async {
        final request = _.positionalArguments.first as AppDetachRequest;
        return request.response({
          'id': 0,
          'result': true,
        });
      });
      when(() => daemon.request(any<AppCallServiceExtensionRequest>()))
          .thenAnswer((_) async {
        final request =
            _.positionalArguments.first as AppCallServiceExtensionRequest;
        return request.response({
          'id': 0,
          'result': <String, dynamic>{},
        });
      });

      application = FlutterApplication('appId', daemon);
    });

    setUpAll(() {
      registerFallbackValue(AppStopRequest('dummy'));
      registerFallbackValue(AppRestartRequest('dummy'));
      registerFallbackValue(AppDetachRequest('dummy'));
      registerFallbackValue(AppCallServiceExtensionRequest('dummy', 'dummy'));
    });

    test('restart', () async {
      final response = await application.restart();
      expect(response.code, equals(0));
      expect(response.message, equals('message'));

      verify(() => daemon.request(any<AppRestartRequest>())).called(equals(1));
      verifyNever(() => daemon.request(any<AppStopRequest>()));
      verifyNever(() => daemon.request(any<AppDetachRequest>()));
      verifyNever(() => daemon.request(any<AppCallServiceExtensionRequest>()));
    });

    test('stop', () async {
      final response = await application.stop();
      expect(response.result, isTrue);

      verify(() => daemon.request(any<AppStopRequest>())).called(equals(1));
      verifyNever(() => daemon.request(any<AppRestartRequest>()));
      verifyNever(() => daemon.request(any<AppDetachRequest>()));
      verifyNever(() => daemon.request(any<AppCallServiceExtensionRequest>()));
    });

    test('detach', () async {
      final response = await application.detach();
      expect(response.result, isTrue);

      verify(() => daemon.request(any<AppDetachRequest>())).called(equals(1));
      verifyNever(() => daemon.request(any<AppRestartRequest>()));
      verifyNever(() => daemon.request(any<AppStopRequest>()));
      verifyNever(() => daemon.request(any<AppCallServiceExtensionRequest>()));
    });

    test('callServiceExtension', () async {
      final response = await application.callServiceExtension('method');
      expect(response.result, equals({}));

      verify(() => daemon.request(any<AppCallServiceExtensionRequest>()))
          .called(equals(1));
      verifyNever(() => daemon.request(any<AppRestartRequest>()));
      verifyNever(() => daemon.request(any<AppStopRequest>()));
      verifyNever(() => daemon.request(any<AppDetachRequest>()));
    });
  });
}
