import 'dart:io';

class XplaneConnectData {  

  // Connection address information
  InternetAddress address;

  // Connection port
  int port;

 // Info of the connection state 
  bool connectionIsRunning = false;

  // Xplane data output values / [index][data,data,data,data]
  Map<int,List<double>> outputData = {};
}