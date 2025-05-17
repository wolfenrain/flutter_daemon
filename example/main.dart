import 'package:flutter_daemon/flutter_daemon.dart';

/// You can run this example using the following command:
/// ```sh
/// # First parameter has to be the working directory, everything else is normal
/// # Flutter arguments.
/// dart example/main.dart ../path/to/flutter/app/ --target lib/main.dart --flavor development
/// ```
void main(List<String> arguments) async {
  final daemon = FlutterDaemon();
  daemon.events.listen(print);

  final workingDirectory = arguments.first;
  final application = await daemon.run(
    arguments: arguments.sublist(1),
    workingDirectory: workingDirectory,
  );

  // Wait for it to be fully started.
  await application.started;

  print('started');
  await Future<void>.delayed(const Duration(seconds: 10));

  print('restarting');
  print(await application.restart());
  await Future<void>.delayed(const Duration(seconds: 10));

  print('stopping');
  await application.stop();
  await daemon.dispose();
}
