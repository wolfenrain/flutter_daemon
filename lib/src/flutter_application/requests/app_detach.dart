part of 'requests.dart';

/// {@template app_detach_request}
/// Represents a request to detach the application.
/// {@endtemplate}
class AppDetachRequest extends FlutterDaemonRequest<AppDetachResponse> {
  /// {@macro app_detach_request}
  const AppDetachRequest(this.appId)
      : super('app.detach', AppDetachResponse.fromJSON);

  /// The app identifier to detach.
  final String appId;

  @override
  Map<String, dynamic> get parameters => {'appId': appId};
}

/// {@template app_detach_response}
/// The response of [AppDetachRequest].
/// {@endtemplate}
class AppDetachResponse extends FlutterDaemonResponse<bool> {
  /// {@macro app_detach_response}
  AppDetachResponse.fromJSON(super.data) : super.fromJSON();
}
