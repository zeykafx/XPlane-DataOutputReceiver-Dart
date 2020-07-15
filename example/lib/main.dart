import 'package:xplane_connect/xplane_connect.dart';

void main() {
  var xPlaneData = XplaneConnect(49001);

  xPlaneData.stream.listen((data) {
    print('Aircraft pitch:    ${data.outputData[17][0]}');
    print('Aircraft roll:     ${data.outputData[17][1]}');
    print('Aircraft heading:  ${data.outputData[17][3]}');
  });
}