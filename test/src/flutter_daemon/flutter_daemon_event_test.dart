import 'package:flutter_daemon/flutter_daemon.dart';
import 'package:test/test.dart';

void main() {
  group('$FlutterDaemonEvent', () {
    test('can construct one from JSON', () {
      final event = FlutterDaemonEvent.fromJSON({
        'event': 'test',
        'params': {'key': 1}
      });

      expect(event.event, equals('test'));
      expect(event.params, equals({'key': 1}));
    });

    test('toString', () {
      final event = FlutterDaemonEvent.fromJSON({
        'event': 'test',
        'params': {'key': 1}
      });

      expect(event.toString(), equals('Event(test) {params: {key: 1}}'));
    });
  });
}
