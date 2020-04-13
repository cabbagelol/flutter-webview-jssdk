import 'package:flutter/material.dart';

import './web.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      //
      // 'https://cabbagelol.github.io/flutter-webview-jssdk/flutter_webview_plugin/demo-01.html'
      body: WebPage(
        data: {
          'url': 'https://cabbagelol.github.io/flutter-webview-jssdk/flutter_webview_plugin/demo-01.html',
          'fullscreen': false
        }
      ),
    );
  }
}
