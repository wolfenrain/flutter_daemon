import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter_daemon/flutter_daemon.dart';
import 'package:process/process.dart';

export 'flutter_daemon_event.dart';
export 'flutter_daemon_request.dart';
export 'flutter_daemon_response.dart';

/// {@template flutter_daemon}
///
/// {@endtemplate}
class FlutterDaemon {
  /// {@macro flutter_daemon}
  FlutterDaemon({
    ProcessManager? processManager,
  })  : _eventsController = StreamController.broadcast(),
        _rawResponseController = StreamController.broadcast(),
        _processManager = processManager ?? const LocalProcessManager();

  final ProcessManager _processManager;
  Process? _process;

  int _requestId = 0;
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  /// Resolves when the daemon process finishes.
  Future<void> get finished => _finished.future;

  /// Returns true if the daemon process finished, else false.
  bool get isFinished => _finished.isCompleted;
  final _finished = Completer<void>();

  /// Emits the events that the daemon process emits.
  late final Stream<FlutterDaemonEvent> events = _eventsController.stream;
  final StreamController<FlutterDaemonEvent> _eventsController;
  final StreamController<Map<String, dynamic>> _rawResponseController;

  /// Perform a `flutter run --machine` to start up a daemon process that runs
  /// a flutter application.
  Future<FlutterApplication> run({
    required List<String> arguments,
    String? workingDirectory,
  }) {
    return _start(
      arguments: arguments,
      workingDirectory: workingDirectory,
      isAttach: false,
    );
  }

  /// Perform a `flutter attach --machine` to start up a daemon process that
  /// attaches to an already running flutter application.
  Future<FlutterApplication> attach({
    required List<String> arguments,
    String? workingDirectory,
  }) {
    return _start(
      arguments: arguments,
      workingDirectory: workingDirectory,
      isAttach: true,
    );
  }

  /// Send a RPC request to the daemon and wait for a response.
  ///
  /// For more information on available requests see:
  /// https://github.com/flutter/flutter/blob/master/packages/flutter_tools/doc/daemon.md
  Future<Response> request<Response extends FlutterDaemonResponse<dynamic>>(
    FlutterDaemonRequest<Response> request,
  ) async {
    final id = ++_requestId;
    final data = _rawResponseController.stream.firstWhere((r) => r['id'] == id);
    _process!.stdin.writeln(json.encode([request.toJSON(id)]));
    return request.response(await data);
  }

  /// Close the current daemon process so that the instance can be reused again
  /// for [run] or [attach].
  Future<void> close() async {
    _process?.kill();
    _process = null;
    await Future.wait(_subscriptions.map((s) => s.cancel()));
    _subscriptions.clear();
  }

  /// Dispose the daemon and clear up all resources, it is unusable after this.
  Future<void> dispose() async {
    await close();
    await _eventsController.close();
    await _rawResponseController.close();
  }

  Future<FlutterApplication> _start({
    required List<String> arguments,
    required bool isAttach,
    String? workingDirectory,
  }) async {
    if (_process != null) {
      throw StateError(
        'Daemon already in use, either close it or create a new instance.',
      );
    }
    final completer = Completer<FlutterApplication>();
    FutureOr<void> complete([FutureOr<void>? value]) {
      if (!_finished.isCompleted) _finished.complete();
    }

    log('Starting daemon: ${arguments.join(' ')}', level: 300);
    _process = await _processManager.start(
      [
        'flutter',
        if (isAttach) 'attach' else 'run',
        '--machine',
        ...arguments,
      ],
      runInShell: true,
      workingDirectory: workingDirectory,
    );

    final errorBuffer = StringBuffer();
    _subscriptions.addAll([
      _process!.stderr.transform(utf8.decoder).listen(
        errorBuffer.write,
        onDone: () {
          // If it exited without correctly attaching to the application, we
          // output the errors.
          if (!completer.isCompleted) {
            completer.completeError(errorBuffer.toString());
          }
        },
      ),
      _process!.stdout
          .transform(utf8.decoder)
          .where((d) => d.startsWith('['))
          .map(json.decode)
          .cast<List<dynamic>>()
          .listen(
        (list) {
          log('Received: $list', level: 300);
          for (final data in list.cast<Map<String, dynamic>>()) {
            if (data.containsKey('event')) {
              final event = FlutterDaemonEvent.fromJSON(data);
              _eventsController.add(event);
              if (event.event == 'app.started') {
                log('App started', level: 300);
                completer.complete(
                  FlutterApplication(event.params['appId'] as String, this),
                );
              }
            } else {
              _rawResponseController.add(data);
            }
          }
        },
        onDone: complete,
      ),
    ]);

    _process!.exitCode.then(complete).ignore();

    return completer.future;
  }
}
