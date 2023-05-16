part of 'requests.dart';

/// {@template app_call_service_extension_request}
/// Represents a request to call an service extension on the application.
/// {@endtemplate}
class AppCallServiceExtensionRequest
    extends AppRequest<AppCallServiceExtensionResponse> {
  /// {@macro app_call_service_extension_request}
  const AppCallServiceExtensionRequest(
    this.appId,
    this.methodName, {
    this.params = const {},
  }) : super(
          'app.callServiceExtension',
          AppCallServiceExtensionResponse.fromJSON,
        );

  /// The app identifier on which to call the service extension.
  final String appId;

  /// The service extension method to call.
  final String methodName;

  /// The parameters for the service extension method.
  final Map<String, dynamic> params;

  @override
  Map<String, dynamic> get parameters => {
        'appId': appId,
        'methodName': methodName,
        'params': params,
      };
}

/// {@template app_call_service_extension_response}
/// The response of [AppCallServiceExtensionRequest].
/// {@endtemplate}
class AppCallServiceExtensionResponse
    extends FlutterDaemonResponse<Map<String, dynamic>?> {
  /// {@macro app_call_service_extension_response}
  AppCallServiceExtensionResponse.fromJSON(super.data) : super.fromJSON();
}
