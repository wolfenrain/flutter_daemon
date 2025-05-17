import 'dart:async';

import 'package:flutter_daemon/flutter_daemon.dart';

export 'requests/requests.dart';

/// {@template flutter_application}
/// Represents an attached application on the [FlutterDaemon].
///
/// Instances of this class can be received through [FlutterDaemon.attach] or
/// [FlutterDaemon.run].
/// {@endtemplate}
class FlutterApplication {
  /// {@macro flutter_application}
  FlutterApplication(this.appId, this._daemon) : _started = Completer() {
    events
        .firstWhere((e) => e.event == 'app.started')
        .whenComplete(_started.complete);
  }

  /// {@macro flutter_application}
  ///
  /// Created when the daemon is getting attached to a running app.
  FlutterApplication.attached(
    this.appId,
    this._daemon,
  ) : _started = Completer() {
    _started.complete();
  }

  /// The application id of the attached flutter app.
  final String appId;

  /// Emits events related to this application.
  late final Stream<FlutterDaemonEvent> events =
      _daemon.events.where((event) => event.params['appId'] == appId);

  /// Resolves once the application has emitted the `app.started` event.
  ///
  /// If this application was created through an attach it will already be
  /// resolved.
  Future<void> get started => _started.future;
  final Completer<void> _started;

  final FlutterDaemon _daemon;

  /// Restarts the application.
  ///
  /// If [AppRestartResponse.code] is 0 it indicates success, non-zero
  /// indicates failures.
  Future<AppRestartResponse> restart({
    bool? fullRestart,
    String? reason,
    bool? pause,
    bool? debounce,
  }) {
    return _daemon.request(
      AppRestartRequest(
        appId,
        fullRestart: fullRestart,
        reason: reason,
        pause: pause,
        debounce: debounce,
      ),
    );
  }

  /// Stops the application.
  ///
  /// It returns a bool to indicate success or failure in stopping an app.
  Future<AppStopResponse> stop() {
    return _daemon.request(AppStopRequest(appId));
  }

  /// Detach from the application without stopping it.
  ///
  /// It returns a bool to indicate success or failure in detaching from an app.
  Future<AppDetachResponse> detach() {
    return _daemon.request(AppDetachRequest(appId));
  }

  /// Call service protocol extension methods on the application.
  ///
  /// [AppCallServiceExtensionResponse.result] is the result of the method.
  Future<AppCallServiceExtensionResponse> callServiceExtension(
    String method, {
    Map<String, dynamic> params = const {},
  }) {
    return _daemon.request(
      AppCallServiceExtensionRequest(appId, method, params: params),
    );
  }
}
