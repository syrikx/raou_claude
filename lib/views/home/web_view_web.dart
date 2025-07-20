import 'package:flutter/material.dart';
import 'dart:html' as html;

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
    return const WebViewPlaceholder();
  }
}

class JavaScriptMode {
  static const unrestricted = null;
}

class NavigationDelegate {
  NavigationDelegate({Function(String)? onPageFinished});
}

class WebViewPlaceholder extends StatelessWidget {
  const WebViewPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.web,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 24),
          const Text(
            'Coupang Shopping',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'WebView is not available on web platform.\nUse mobile app for full shopping experience.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              html.window.open('https://www.coupang.com', '_blank');
            },
            icon: const Icon(Icons.launch),
            label: const Text('Open Coupang in New Tab'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}