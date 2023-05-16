part of 'requests.dart';

/// {@template app_stop_request}
/// Represents a request to stop the application.
/// {@endtemplate}
class AppStopRequest extends FlutterDaemonRequest<AppStopResponse> {
  /// {@macro app_stop_request}
  const AppStopRequest(this.appId)
      : super('app.stop', AppStopResponse.fromJSON);

  /// The app identifier to stop.
  final String appId;

  @override
  Map<String, dynamic> get parameters => {'appId': appId};
}

/// {@template app_stop_response}
/// The response of [AppStopRequest].
/// {@endtemplate}
class AppStopResponse extends FlutterDaemonResponse<bool> {
  /// {@macro app_stop_response}
  AppStopResponse.fromJSON(super.data) : super.fromJSON();
}
