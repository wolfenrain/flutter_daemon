import 'package:flutter_daemon/flutter_daemon.dart';

part 'app_restart.dart';
part 'app_detach.dart';
part 'app_stop.dart';
part 'app_call_service_extension.dart';

/// {@template app_request}
/// Represents a request send by the app, as a sealed class so it can more
/// easily be pattern matched for the different app requests.
/// {@endtemplate}
sealed class AppRequest<Response extends FlutterDaemonResponse<dynamic>>
    extends FlutterDaemonRequest<Response> {
  /// {@macro app_request}
  const AppRequest(super.method, super.response);
}
