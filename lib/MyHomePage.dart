import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_webview_pro/webview_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isLoading = true;
  int progressBar = 0;
  late WebViewController _webViewController;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: _goBack,
        child: Scaffold(
          body: Container(
            child: Stack(
              children: [
                WebView(
                  initialUrl: "https://elearning.aiu.edu.my/",
                  javascriptMode: JavascriptMode.unrestricted,
                  onWebViewCreated: (WebViewController webViewController) {
                    _webViewController = webViewController;
                  },
                  allowsInlineMediaPlayback: true,
                  gestureNavigationEnabled: true,
                  zoomEnabled: true,
                  navigationDelegate: (NavigationRequest request) async {
                    if (request.url.contains(".pdf") ||
                        request.url.contains(".pptx")) {
                      var url = await Uri.parse(request.url);
                      launchUrl(
                        url,
                        mode: LaunchMode.externalApplication,
                      );
                      return NavigationDecision.prevent;
                    }
                    if (request.url.contains("aiu.edu.my")) {
                      return NavigationDecision.navigate;
                    }
                    return NavigationDecision.prevent;
                  },
                  onPageStarted: (url) {
                    print("started loading");
                    setState(() {
                      isLoading = true;
                    });
                  },
                  onPageFinished: (url) {
                    print("finished loading");
                    setState(() {
                      isLoading = false;
                    });
                  },
                  onProgress: (progress) {
                    print("done $progress");
                    setState(() {
                      progressBar = progress;
                    });
                  },
                ),
                if (isLoading) loading(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget loading() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            LoadingAnimationWidget.flickr(leftDotColor: Colors.blue, rightDotColor: Colors.green, size: 60),
            SizedBox(height: 20),
            Text(
              "Progress $progressBar",
              style: TextStyle(color: Colors.blue, fontSize: 12),
            ),
            SizedBox(height: 20),
          ],
        ),
      );
    }
    return SizedBox.shrink();
  }

  Future<bool> _goBack() async {
    if (await _webViewController.canGoBack()) {
      _webViewController.goBack();
      return false;
    }
    return true;
  }
}