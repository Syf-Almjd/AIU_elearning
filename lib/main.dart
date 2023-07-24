import 'dart:async';

import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'MyHomePage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isConnected = true;
  late StreamSubscription<InternetConnectionStatus> connectionSubscription;

  @override
  void initState() {
    Internet();
    super.initState();
  }

  Future<bool> Internet() async {
    connectionSubscription =
        await InternetConnectionChecker().onStatusChange.listen((status) {
      switch (status) {
        case InternetConnectionStatus.connected:
          setState(() {
            isConnected = true;
          });
        case InternetConnectionStatus.disconnected:
          isConnected = false;
          break;
      }
    });
    return isConnected;
  }

  @override
  void dispose() {
    connectionSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
