<h1 align="center">flutter_daemon</h1>

<p align="center">
<a href="https://pub.dev/packages/flutter_daemon"><img src="https://img.shields.io/pub/v/flutter_daemon.svg" alt="Pub"></a>
<a href="https://github.com//wolfenrain/flutter_daemon/actions"><img src="https://github.com/wolfenrain/flutter_daemon/actions/workflows/main.yaml/badge.svg" alt="ci"></a>
<a href="https://github.com//wolfenrain/flutter_daemon/actions"><img src="https://raw.githubusercontent.com/wolfenrain/flutter_daemon/main/coverage_badge.svg" alt="coverage"></a>
<a href="https://pub.dev/packages/very_good_analysis"><img src="https://img.shields.io/badge/style-very_good_analysis-B22C89.svg" alt="style: very good analysis"></a>
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>
</p>

---

A programmable interface around the [Flutter daemon][flutter_daemon] protocol.

---

The `flutter` command-line tool supports running as a daemon server, allowing developers to control
the running flutter application by using the built-in [JSON-RPC](https://www.jsonrpc.org/) 
communication protocol.

This package provides a programmable interface on top of that to allow developers to use the daemon
with a strongly typed API. It maps all the documented method that the daemon supports and allows
developers to listen to events emitted by the daemon. 

## Installation

Add `flutter_daemon` as a dependency to your pubspec.yaml file ([what?](https://flutter.io/using-packages/)).

You can then import the Flutter daemon:

```dart
import 'package:flutter_daemon/flutter_daemon.dart';
```

## Usage

You can start using the Flutter daemon by creating an instance of the daemon and running a Flutter
application:

```dart
import 'package:flutter_daemon/flutter_daemon.dart';

void main() async {
  final daemon = FlutterDaemon();

  daemon.events.listen((event) {
    // Listen to events emitted by the daemon.
  });

  // You can run an application from the daemon.
  // Or alternatively you can attach using `daemon.attach`
  final application = daemon.run(
    arguments: [
      // Any flutter arguments go here.
    ],
    workingDirectory: 'your/flutter/app/location/',
  );


  application.events.listen((event) {
    // Listen to events specifically emitted by this application.
  });

  // Restart the application
  await application.restart();

  // Detach from the application, but dont stop it.
  await application.detach();

  // Stop the application.
  await application.stop();
}
```

## Calling Service Extensions

You can call both [Flutter](https://api.flutter.dev/flutter/services/ServicesBinding/initServiceExtensions.html) and [Dart](https://api.flutter.dev/flutter/dart-developer/registerExtension.html) service extensions using the daemon as well:

```dart
void main() async {
  final daemon = FlutterDaemon();

  final application = daemon.run(
    /// ...
  );

  final response = await application.callServiceExtension('ext.myExtension.handler', {
    'some': 'parameters'
  });

  if (response.hasError) throw response.error;
  print(response.result);
}
```

## Reusing the daemon

Once you `run` or `attach` an application the daemon can't be reused until you close it's current
process:

```dart
void main() async {
  final daemon = FlutterDaemon();

  final application1 = daemon.run(
    // ...
  );

  // If you don't close it and try to run or attach again it will throw a StateError.
  await daemon.close();

  final application2 = daemon.attach(
    // ...
  );
}
```

Once you are completely done with the daemon make sure you `dispose` of it correctly:

```dart
void main() async {
  final daemon = FlutterDaemon();

  // ...

  await daemon.dispose();
}
```

## Contributing

Have you found a bug or have a suggestion of how to enhance Goose? Open an issue and we will take a look at it as soon as possible.

Do you want to contribute with a PR? PRs are always welcome, just make sure to create it from the correct branch (main) and follow the [checklist](https://github.com/wolfenrain/flutter_daemon/blob/main/.github/PULL_REQUEST_TEMPLATE.md) which will appear when you open the PR.

[flutter_daemon]: https://github.com/flutter/flutter/blob/master/packages/flutter_tools/doc/daemon.md
