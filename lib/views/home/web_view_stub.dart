// Stub file for conditional imports
import 'package:flutter/material.dart';

class WebViewController {
  WebViewController setJavaScriptMode(dynamic mode) => this;
  WebViewController setNavigationDelegate(NavigationDelegate delegate) => this;
  WebViewController loadRequest(Uri uri) => this;
}

class WebViewWidget extends StatelessWidget {
  final WebViewController controller;
  const WebViewWidget({super.key, required this.controller});
  
  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class JavaScriptMode {
  static const unrestricted = null;
}

class NavigationDelegate {
  NavigationDelegate({Function(String)? onPageFinished});
}