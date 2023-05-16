part of 'requests.dart';

/// {@template app_restart_request}
/// Represents a request to restart the application.
/// {@endtemplate}
class AppRestartRequest extends FlutterDaemonRequest<AppRestartResponse> {
  /// {@macro app_restart_request}
  const AppRestartRequest(
    this.appId, {
    this.fullRestart,
    this.reason,
    this.pause,
    this.debounce,
  }) : super('app.restart', AppRestartResponse.fromJSON);

  /// The app identifier to restart.
  final String appId;

  /// Whether to do a full (rather than an incremental) restart of the
  /// application.
  final bool? fullRestart;

  /// The reason for the full restart (eg. save, manual) for reporting purposes.
  final String? reason;

  /// Whether a hot restart should put the isolate in a paused mode.
  final bool? pause;

  /// Whether to automatically debounce multiple requests sent in quick
  /// succession (this may introduce a short delay in processing the request).
  final bool? debounce;

  @override
  Map<String, dynamic> get parameters => {
        'appId': appId,
        'fullRestart': fullRestart,
        'reason': reason,
        'pause': pause,
        'debounce': debounce,
      };
}

/// {@template app_restart_response}
/// The response of [AppRestartRequest].
/// {@endtemplate}
class AppRestartResponse extends FlutterDaemonResponse<Map<String, dynamic>> {
  /// {@macro app_restart_response}
  AppRestartResponse.fromJSON(super.data) : super.fromJSON();

  /// The code indicating success or failure, 0 is success and non-zero is
  /// failure.
  int get code => result!['code'] as int;

  /// Optional message as to why it failed.
  String get message => result!['message'] as String;
}
