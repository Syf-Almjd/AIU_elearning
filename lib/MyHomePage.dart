import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isLoading = true;
  int progressBar = 0;
  late final WebViewController _webViewController;

  @override
  void initState() {
    super.initState();

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              progressBar = progress;
            });
          },
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) async {
            if (request.url.contains(".pdf") || request.url.contains(".pptx")) {
              var url = Uri.parse(request.url);
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
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
        ),
      )
      ..enableZoom(true)
      ..loadRequest(Uri.parse("https://elearning.aiu.edu.my/"));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          if (didPop) return;
          await _goBack();
        },
        child: Scaffold(
          body: Stack(
            children: [
              WebViewWidget(controller: _webViewController),
              if (isLoading) loading(),
            ],
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
            LoadingAnimationWidget.flickr(
              leftDotColor: Colors.blue,
              rightDotColor: Colors.green,
              size: 60,
            ),
            const SizedBox(height: 20),
            Text(
              "Progress $progressBar%",
              style: const TextStyle(color: Colors.blue, fontSize: 12),
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Future<void> _goBack() async {
    if (await _webViewController.canGoBack()) {
      await _webViewController.goBack();
    } else {
      // If can't go back, exit the app or show dialog
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}
