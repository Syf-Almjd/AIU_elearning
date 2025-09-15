import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'MyHomePage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Map<ConnectivityResult, bool> _source = {ConnectivityResult.none: false};
  final MyConnectivity _connectivity = MyConnectivity.instance;

  @override
  void initState() {
    super.initState();
    _connectivity.initialise();
    _connectivity.myStream.listen((source) {
      if (mounted) {
        setState(() => _source = source);
      }
    });
  }

  @override
  void dispose() {
    _connectivity.disposeStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isConnected = _source.values.isNotEmpty ? _source.values.first : false;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AIU E-Learning Platform',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: isConnected
          ? const MyHomePage()
          : Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Image(image: AssetImage("assets/nodata.png")),
                    const SizedBox(height: 10),
                    const Text(
                      'You are disconnected from the internet.\nStay connected to continue!',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 50),
                    LoadingAnimationWidget.waveDots(
                        color: isConnected ? Colors.green : Colors.red,
                        size: 50),
                    const SizedBox(height: 10),
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
  final _controller =
      StreamController<Map<ConnectivityResult, bool>>.broadcast();

  Stream<Map<ConnectivityResult, bool>> get myStream => _controller.stream;

  void initialise() async {
    List<ConnectivityResult> results = await _connectivity.checkConnectivity();
    _checkStatus(results.isNotEmpty ? results.first : ConnectivityResult.none);

    _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      _checkStatus(
          results.isNotEmpty ? results.first : ConnectivityResult.none);
    });
  }

  void _checkStatus(ConnectivityResult result) async {
    bool isOnline = false;
    try {
      // Use a proper hostname, not a full URL
      final lookupResult = await InternetAddress.lookup('elearning.aiu.edu.my');
      isOnline =
          lookupResult.isNotEmpty && lookupResult[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      isOnline = false;
    }

    if (!_controller.isClosed) {
      _controller.sink.add({result: isOnline});
    }
  }

  void disposeStream() => _controller.close();
}
