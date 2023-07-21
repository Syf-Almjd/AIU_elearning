import 'dart:async';

import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'MyHomePage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool isConnected;
  late StreamSubscription<InternetConnectionStatus> connectionSubscription;

  @override
  void initState() {
    super.initState();
    isConnected = false;
    connectionSubscription =
        InternetConnectionChecker().onStatusChange.listen((status) {
          setState(() {
            switch (status) {
              case InternetConnectionStatus.connected:
                isConnected = true;
                break;
              case InternetConnectionStatus.disconnected:
                isConnected = false;
                break;
            }
          });
        });
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
              Text(
                'You are disconnected from the internet.\nStay connected to continue!',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
