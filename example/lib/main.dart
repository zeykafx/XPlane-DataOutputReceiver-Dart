import 'package:xplane_connect/xplane_connect.dart';

void main() {
  var xPlaneData = XplaneConnect(49001);

  xPlaneData.stream.listen((data) {
    print('Aircraft pitch:    ${data[17][0]}');
    print('Aircraft roll:     ${data[17][1]}');
    print('Aircraft heading:  ${data[17][3]}');
  });
}