// ignore_for_file: prefer_const_constructors
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_daemon/flutter_daemon.dart';
import 'package:mocktail/mocktail.dart';
import 'package:process/process.dart';
import 'package:test/test.dart';

void main() {
  group('$FlutterDaemon', () {
    late ProcessManager processManager;
    late Process process;
    late Completer<int> exitCode;
    late IOSink stdin;
    late StreamController<List<int>> stdout;
    late StreamController<List<int>> stderr;

    late FlutterDaemon daemon;

    void exitWith(int code) {
      if (exitCode.isCompleted) return;
      exitCode.complete(code);
    }

    void recreateStreams() {
      stdout = StreamController(onCancel: () => exitWith(0));
      when(() => process.stdout).thenAnswer((_) => stdout.stream);
      stderr = StreamController(onCancel: () => exitWith(0));
      when(() => process.stderr).thenAnswer((_) => stderr.stream);
    }

    setUp(() {
      processManager = _MockProcessManager();

      process = _MockProcess();
      exitCode = Completer<int>();
      exitCode.future.whenComplete(() {
        stdout.close();
        stderr.close();
      });

      when(() => process.exitCode).thenAnswer((_) => exitCode.future);

      stdin = _MockIOSink();
      when(() => stdin.writeln(any())).thenAnswer((_) {});
      when(() => process.stdin).thenReturn(stdin);

      recreateStreams();
      when(process.kill).thenReturn(true);

      when(
        () => processManager.start(
          any(),
          runInShell: any(named: 'runInShell', that: isTrue),
          workingDirectory: any(named: 'workingDirectory', that: isA<String>()),
        ),
      ).thenAnswer((_) async => process);

      daemon = FlutterDaemon(processManager: processManager);
    });

    test('run correctly', () async {
      final appFuture = daemon.run(arguments: [], workingDirectory: '');
      final finishedFuture = daemon.finished;

      /// Emit app start event.
      await stdout.appStart();
      expect(await appFuture, isA<FlutterApplication>());

      expect(daemon.isFinished, isFalse);
      exitWith(0);
      await finishedFuture;
      expect(daemon.isFinished, isTrue);
    });

    test('attach correctly', () async {
      final appFuture = daemon.attach(arguments: [], workingDirectory: '');
      final finishedFuture = daemon.finished;

      /// Emit app start event.
      await stdout.appStart();
      expect(await appFuture, isA<FlutterApplication>());

      expect(daemon.isFinished, isFalse);
      exitWith(0);
      await finishedFuture;
      expect(daemon.isFinished, isTrue);
    });

    test('throws state error if a process is already active', () async {
      final appFuture = daemon.attach(arguments: [], workingDirectory: '');

      /// Emit app start event.
      await stdout.appStart();
      expect(await appFuture, isA<FlutterApplication>());

      expect(
        daemon.run(arguments: [], workingDirectory: ''),
        throwsA(
          isStateError.having(
            (e) => e.message,
            'message',
            equals(
              '''Daemon already in use, either close it or create a new instance.''',
            ),
          ),
        ),
      );
    });

    test('throws error buffer if process exist early', () async {
      final appFuture = daemon.attach(arguments: [], workingDirectory: '');
      stderr.add(utf8.encode('Some reason why it failed'));
      exitWith(1);

      expect(appFuture, throwsA(equals('Some reason why it failed')));
    });

    test('disposes correctly', () async {
      final appFuture = daemon.attach(arguments: [], workingDirectory: '');

      /// Emit app start event.
      await stdout.appStart();
      expect(await appFuture, isA<FlutterApplication>());

      exitWith(0);
      await daemon.dispose();

      expect(
        daemon.attach(arguments: [], workingDirectory: ''),
        throwsA(
          isStateError.having(
            (e) => e.message,
            'message',
            equals('Stream has already been listened to.'),
          ),
        ),
      );
    });

    test('closes correctly so it can be reused', () async {
      final appFuture1 = daemon.attach(arguments: [], workingDirectory: '');

      /// Emit app start event.
      await stdout.appStart();
      expect(await appFuture1, isA<FlutterApplication>());

      exitWith(0);
      await daemon.close();

      // Recreate the controllers.
      recreateStreams();

      final appFuture2 = daemon.attach(arguments: [], workingDirectory: '');

      /// Emit app start event.
      await stdout.appStart();
      expect(await appFuture2, isA<FlutterApplication>());
    });

    test('handles requests correctly', () async {
      final appFuture = daemon.attach(arguments: [], workingDirectory: '');

      /// Emit app start event.
      await stdout.appStart();
      expect(await appFuture, isA<FlutterApplication>());

      when(() => stdin.writeln(any())).thenAnswer((_) {
        final requests = json.decode(
          _.positionalArguments.first as String,
        ) as List<dynamic>;

        stdout.write(
          json.encode(
            requests.cast<Map<String, dynamic>>().map((e) {
              return {'id': e['id'], 'result': true};
            }).toList(),
          ),
        );
      });

      final response = await daemon.request(
        _TestRequest('test', _TestResponse.fromJSON),
      );

      expect(response, isA<_TestResponse>());
      expect(response.id, equals(1));
      expect(response.result, isTrue);

      verify(
        () => stdin.writeln(
          any(that: equals('[{"id":1,"method":"test","params":{}}]')),
        ),
      ).called(1);
    });

    test('emits events correctly', () async {
      final appFuture = daemon.attach(arguments: [], workingDirectory: '');

      /// Emit app start event.
      await stdout.appStart();
      expect(await appFuture, isA<FlutterApplication>());

      final eventFuture = daemon.events.first;
      stdout.write(
        json.encode([
          {
            'event': 'test',
            'params': {'key': 1},
          }
        ]),
      );

      final event = await eventFuture;
      expect(event.event, equals('test'));
      expect(event.params, equals({'key': 1}));
    });

    test('does not throw error if malformed events appears', () async {
      final appFuture = daemon.attach(arguments: [], workingDirectory: '');

      /// Emit app start event.
      await stdout.appStart();
      expect(await appFuture, isA<FlutterApplication>());

      final eventFuture = daemon.events.first;

      // Thanks to Flutter we can now get some errors on stdout instead of
      // stderr.
      stdout
        ..write(
          '[ERROR:flutter/shell/platform/darwin/graphics/FlutterDarwinContextMetalImpeller.mm(42)] Using the Impeller rendering backend.',
        )
        ..write(
          json.encode([
            {
              'event': 'test',
              'params': {'key': 1},
            }
          ]),
        );

      final event = await eventFuture;
      expect(event.event, equals('test'));
      expect(event.params, equals({'key': 1}));
    });
  });
}

extension on StreamController<List<int>> {
  void write(String data) => add(utf8.encode('$data\n'));

  Future<void> appStart() {
    write(
      json.encode([
        {
          'event': 'app.started',
          'params': {'appId': '0000'},
        }
      ]),
    );
    return Future.delayed(Duration.zero);
  }
}

class _MockProcessManager extends Mock implements ProcessManager {}

class _MockProcess extends Mock implements Process {}

class _MockIOSink extends Mock implements IOSink {}

class _TestResponse extends FlutterDaemonResponse<bool> {
  _TestResponse.fromJSON(super.data) : super.fromJSON();
}

class _TestRequest
    extends FlutterDaemonRequest<FlutterDaemonResponse<dynamic>> {
  _TestRequest(super.method, super.response);
}
