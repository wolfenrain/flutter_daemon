/// {@template flutter_daemon_event}
/// Represents an event that was received on the daemon.
/// {@endtemplate}
class FlutterDaemonEvent {
  /// {@macro flutter_daemon_event}
  ///
  /// Construct one from raw JSON.
  FlutterDaemonEvent.fromJSON(Map<String, dynamic> data)
      : event = data['event'] as String,
        params =
            (data['params'] as Map<dynamic, dynamic>).cast<String, dynamic>();

  /// Event name.
  final String event;

  /// Parameters of the event.
  final Map<String, dynamic> params;

  @override
  String toString() => 'Event($event) {params: $params}';
}
