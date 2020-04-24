import 'dart:async';
import 'package:udp/udp.dart';

class XplaneConnect {

  XplaneConnect(int udpPort) {
    _udpPort = udpPort;
    _listen(_udpPort);
  }

  UDP _receiver;
  int _udpPort;

  //Stream controller
  final _controller = StreamController<Map<int, List<double>>>();

  // Gets the data stream of xplane data outputs with indexed table model
  Stream<Map<int, List<double>>> get stream  => _controller.stream;

  void _listen(int udpPort) async {

    var connected = false;
    
    // Set UDP port to listen
    _receiver = await UDP.bind(Endpoint.any(port: Port(udpPort))).then((value) {
      print(
          'UDP binded on ${value.local.address}:${value.local.port.value} , waiting for XPlane');
      return value;
    }).catchError((error) {
      print('UDP error: $error');
    });

    // receiving\listening
    await _receiver.listen((datagram) {      

      var xPdata = datagram.data; 

      // Verify data header
      var header = String.fromCharCodes(xPdata, 0, 5);
      if (header.contains('DATA')) {
        // Discart data header
        xPdata = xPdata.sublist(5, xPdata.lengthInBytes);
        if (!connected) {  
          connected = true;      
          print('Xplane connected, IP: ${datagram.address.address}');
        }
      } else {
        // Worng data type
        print('Worng type of DATA');
      }

      var totalLen = 36; // set data length to 36 bytes, index[4-bytes] + data[32-bytes]

      // Get count of data outputs
      var totalData = ((xPdata.lengthInBytes) / totalLen);
      var dataOutputs = <int, List<double>>{};

      for (var dataIndex = 0; dataIndex < totalData; dataIndex++) {
        
        // Get data output by index
        var dataOutput = xPdata.sublist(dataIndex * totalLen, totalLen * (dataIndex + 1));

        // Get index of XPlane data output
        var index = dataOutput[0];
            
        // Get data output values
        var values = dataOutput.buffer.asFloat32List(4,4).toList();

        // Set value on dataOutputs object, update the data if exists        
        dataOutputs.putIfAbsent(index, () => values);  
      }

      // Add dataOutputs to stream
      _controller.sink.add(dataOutputs);       
    });
  }

  void closeConnection() {
    if (_receiver.closed) {
      print('Connection has already closed');
    } else {
      _receiver.close();
      print('Connection has been closed');
    } 
  }

  void restartConnection() {
    if (!_receiver.closed) {
      closeConnection();
    }      
    _listen(_udpPort);
  }
}
