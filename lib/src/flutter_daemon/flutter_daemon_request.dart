import 'package:flutter_daemon/flutter_daemon.dart';

/// {@template flutter_daemon_request}
/// Represents a request that can be send on the [FlutterDaemon].
///
/// The daemon will call the [response] construct once it receives a response
/// with the corresponding id.
/// {@endtemplate}
abstract class FlutterDaemonRequest<
    Response extends FlutterDaemonResponse<dynamic>> {
  /// {@macro flutter_daemon_request}
  const FlutterDaemonRequest(this.method, this.response);

  /// The method of the request.
  final String method;

  /// The response constructor for this request.
  final Response Function(Map<String, dynamic>) response;

  /// Optional parameters to add to the request.
  Map<String, dynamic> get parameters => {};

  /// Turn the request into JSON for the daemon, using the unique [id].
  Map<String, dynamic> toJSON(int id) {
    return {
      'id': id,
      'method': method,
      'params': parameters,
    };
  }
}
