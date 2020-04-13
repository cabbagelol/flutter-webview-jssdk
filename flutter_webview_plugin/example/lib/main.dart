import 'package:flutter/material.dart';
import 'dart:async';

import './webview/webview.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  openWebview () {
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => Webview(
        data: {
          'url': 'https://cabbagelol.github.io/flutter-webview-jssdk/flutter_webview_plugin/demo-01.html',
          'fullscreen': false
        }
    )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GestureDetector(
          onTap: () {
            this.openWebview();
          },
          child: Text(
            '点击打开',
            style: TextStyle(
                color: Colors.black45,
                fontSize: 14
            ),
          ),
        ),
      ),
    );
  }
}
