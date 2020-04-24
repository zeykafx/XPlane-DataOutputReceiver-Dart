# XPlane Connect

Library to get an easy stream of data about XPlane UDP protocol.

[![pub package](https://img.shields.io/pub/v/xplane_connect.svg)](https://pub.dev/packages/xplane_connect)

## How to use

In the XPlane configuration, on Data Output check 'Network via UDP' on the required o requires index.
![Configure data output](https://i.imgur.com/lrvldn5.png)

Then check 'Send nework data output', configure IP address and port of the dart/flutter client.
![Configure client](https://i.imgur.com/oherl1m.png)

A simple dart usage example:

```dart
import 'package:xplane_connect/xplane_connect.dart';

void main() {
  var xPlaneData = XplaneConnect(49001);

  xPlaneData.stream.listen((data) {
    print('Aircraft pitch: ${data[17][0]}');
  });
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/Lulzphantom/XPlane-DataOutputReceiver-Dart/issues
