import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(title: 'Allen Travel'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  WebViewController? controller;
  bool isLoading = true;

  final String _url = 'https://bus.esolvelabs.com:4433/allen/';

  @override
  void initState() {
    super.initState();
    checkInternetAndLoad();
  }

  Future<void> checkInternetAndLoad() async {
    setState(() {
      isLoading = true;
    });

    final webViewController = WebViewController()
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            setState(() => isLoading = true);
          },
          onPageFinished: (_) {
            setState(() => isLoading = false);
          },
          onWebResourceError: (error) {
            setState(() {
              isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${error.description}')),
            );
          },
        ),
      )
      ..loadRequest(Uri.parse(_url));

    setState(() {
      controller = webViewController;
    });
  }

  Future<void> refreshPage() async {
    setState(() {
      isLoading = true;
    });
    controller?.reload();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (controller != null && await controller!.canGoBack()) {
          await controller!.goBack();
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: controller == null
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  SafeArea(
                    child: RefreshIndicator(
                      onRefresh: refreshPage,
                      child: WebViewWidget(controller: controller!),
                    ),
                  ),
                  if (isLoading)
                    Container(
                      color: Colors.white,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/Allens.png',
                              width: 100,
                              height: 100,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Loading, please wait...',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 20),
                            const CircularProgressIndicator(),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
        floatingActionButton: (controller != null)
            ? FloatingActionButton(
                onPressed: refreshPage,
                child: const Icon(Icons.refresh),
              )
            : null,
      ),
    );
  }
}
