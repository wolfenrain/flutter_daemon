/// {@template flutter_daemon_response}
/// Represents a response of a request that was send on the
/// {@endtemplate}
class FlutterDaemonResponse<T> {
  /// {@macro flutter_daemon_response}
  ///
  /// Construct one from raw JSON.
  FlutterDaemonResponse.fromJSON(Map<String, dynamic> data)
      : id = data['id'] as int,
        result = data['result'] as T?,
        error = data['error'] as String?;

  /// The unique request id for whom this response is.
  final int id;

  /// The result, if any.
  final T? result;

  /// The error, if any.
  final String? error;

  /// Returns true if it has an error.
  bool get hasError => error != null;

  @override
  String toString() => 'Response($id) {result: $result, error: $error}';
}
