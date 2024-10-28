
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebInterface extends StatefulWidget {
  const WebInterface({Key? key}) : super(key: key);

  @override
  State<WebInterface> createState() => _WebInterfaceState();
}

class _WebInterfaceState extends State<WebInterface> {
  InAppWebViewController? _webViewController;
  final Uri _url = Uri.parse('http://192.168.20.1');
  bool _isLoadingError = false;
  bool _isLoading = true; // To track if the site is still loading

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(_url.toString())),
            initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                horizontalScrollBarEnabled: false,
                preferredContentMode: UserPreferredContentMode.MOBILE,
                supportZoom: true,
              ),
            ),
            onWebViewCreated: (InAppWebViewController controller) {
              _webViewController = controller;
            },
            onLoadStart: (controller, url) {
              setState(() {
                _isLoading = true;
              });
            },
            onLoadStop: (controller, url) {
              setState(() {
                _isLoading = false;
              });
            },
            onLoadError: (controller, url, code, message) {
              setState(() {
                _isLoadingError = true;
              });
            },
          ),
          // Shimmer effect while loading
          if (_isLoading)
           const Center(
              child: SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  color: Color(0xFF0C7C3C),
                )
              ),

            ),
        ],
      ),
    );
  }
}
