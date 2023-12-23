import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'MyHomePage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Map _source = {ConnectivityResult.none: false};
  final MyConnectivity _connectivity = MyConnectivity.instance;

  @override
  void initState() {
    super.initState();
    _connectivity.initialise();
    _connectivity.myStream.listen((source) {
      setState(() => _source = source);
    });
  }

  @override
  void dispose() {
    _connectivity.disposeStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isConnected = false;
    switch (_source.keys.toList()[0]) {
      case ConnectivityResult.mobile:
        isConnected = true;
        break;
      case ConnectivityResult.wifi:
        isConnected = true;
        break;
      case ConnectivityResult.none:
      default:
        isConnected = false;
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AIU E-Learning Platform',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: isConnected
          ? MyHomePage()
          : Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image(image: AssetImage("assets/nodata.png")),
                    SizedBox(
                      height: 10,
                      width: 10,
                    ),
                    Text(
                      'You are disconnected from the internet.\nStay connected to continue!',
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 50,
                      width: 50,
                    ),
                    LoadingAnimationWidget.waveDots(
                        color: isConnected ? Colors.green : Colors.red,
                        size: 50),
                    SizedBox(
                      height: 10,
                      width: 10,
                    ),
                    Text(
                      isConnected
                          ? "Connected, Please Wait"
                          : "No Connection! Trying to connect again..",
                      style: TextStyle(
                          color: isConnected ? Colors.green : Colors.red,
                          fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class MyConnectivity {
  MyConnectivity._();

  static final _instance = MyConnectivity._();

  static MyConnectivity get instance => _instance;
  final _connectivity = Connectivity();
  final _controller = StreamController.broadcast();

  Stream get myStream => _controller.stream;

  void initialise() async {
    ConnectivityResult result = await _connectivity.checkConnectivity();
    _checkStatus(result);
    _connectivity.onConnectivityChanged.listen((result) {
      _checkStatus(result);
    });
  }

  void _checkStatus(ConnectivityResult result) async {
    bool isOnline = false;
    try {
      final result =
          await InternetAddress.lookup('https://elearning.aiu.edu.my/');
      isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      isOnline = false;
    }
    _controller.sink.add({result: isOnline});
  }

  void disposeStream() => _controller.close();
}
