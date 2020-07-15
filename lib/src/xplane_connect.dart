import 'dart:async';
import 'package:udp/udp.dart';

import 'models/xplane_data_model.dart';

class XplaneConnect {

  XplaneConnect(int udpPort) {
    _udpPort = udpPort;
    _listen(_udpPort);
  }

  UDP _receiver;
  int _udpPort;
  XplaneConnectData _xPlaneConnection;

  //Stream controller
  final _controller = StreamController<XplaneConnectData>();

  // Gets the data stream of xplane data outputs with indexed table model
  Stream<XplaneConnectData> get stream  => _controller.stream;

  // Start listen UDP port
  void _listen(int udpPort) async {

    // Set new connection object
    _xPlaneConnection = XplaneConnectData();  

    var connected = false;
    
    // Set UDP port to listen
    _receiver = await UDP.bind(Endpoint.any(port: Port(udpPort))).then((value) {
      print('UDP binded on ${value.local.address}:${value.local.port.value} , waiting for XPlane');
      _xPlaneConnection.port = udpPort;
      _setConnectionData(_xPlaneConnection);
      return value;
    }).catchError((error) {
      print('UDP error: $error');
    });

    // receiving\listening
    await _receiver.listen((datagram) {      

      // UDP data
      var xPdata = datagram.data;

      // Verify data header
      var header = String.fromCharCodes(xPdata, 0, 5);
      if (header.contains('DATA')) {
        // Discart data header
        xPdata = xPdata.sublist(5, xPdata.lengthInBytes);
        if (!connected) {  
          connected = true;          
          _xPlaneConnection.address = datagram.address;  
          _xPlaneConnection.connectionIsRunning = true;     
                  
        }
      } else {
        // Worng data type
        print('Worng type of DATA');        
        _xPlaneConnection.connectionIsRunning = false; 
        _setConnectionData(_xPlaneConnection);  
        return;
      }

      var totalLen = 36; // set data length to 36 bytes, index[4-bytes] + data[32-bytes]

      // Get count of data outputs
      var totalData = ((xPdata.lengthInBytes) / totalLen);      

      _xPlaneConnection.outputData = {};

      for (var dataIndex = 0; dataIndex < totalData; dataIndex++) {
        
        // Get data output by index
        var dataOutput = xPdata.sublist(dataIndex * totalLen, totalLen * (dataIndex + 1));

        // Get index of XPlane data output
        var index = dataOutput[0];
            
        // Get data output values
        var values = dataOutput.buffer.asFloat32List(4,4).toList();

        // Set value on dataOutputs object, update the data if exists        a
        _xPlaneConnection.outputData.putIfAbsent(index, () => values);  
        //print(_xPlaneConnection.outputData);
      }

      // Add dataOutputs to stream
      _setConnectionData(_xPlaneConnection);       
    });
  }

  void _setConnectionData(XplaneConnectData data) {
    // Add data to stream    
    _controller.sink.add(data);
  }

  // Close current UDP connection
  void closeConnection() {
    if (_receiver.closed) {
      print('Connection has already closed');
    } else {
      _receiver.close();
      _xPlaneConnection.connectionIsRunning = false;
      _setConnectionData(_xPlaneConnection);
      print('Connection has been closed');
    } 
  }

  // Reset current UDP connection
  void restartConnection() {
    if (!_receiver.closed) {
      closeConnection();
    }      
    _listen(_udpPort);
  }
}
