/**
 * 功能：webview
 */

import 'dart:async';
import 'dart:convert';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:flutter/material.dart';

class Webview extends StatefulWidget {
  final data;

  Webview({
    this.data,
  });

  @override
  State<StatefulWidget> createState() => WebviewState();
}

class WebviewState extends State<Webview> {
  Map options = {
    "url": "",
    "fullscreen": true,
    "isBack": true,
  };

  Future _futureBuilderFuture;

  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  StreamSubscription<String> _onUrlChanged;

  StreamSubscription<WebViewStateChanged> _onStateChanged;

  StreamSubscription<WebViewHttpError> _onHttpError;

  Map _onHttpErrorMap = new Map();

  FlutterWebviewPlugin _flutterWebViewPlugin = new FlutterWebviewPlugin();

  String title;

  @override
  void initState() {
    options = widget.data;

    options["url"] = Uri.decodeComponent(options["url"]);

    setState(() {
      _futureBuilderFuture = this._getData();
    });

    _onHttpError = _flutterWebViewPlugin.onHttpError.listen((WebViewHttpError error) {
      setState(() {
        _onHttpErrorMap = {
          "code": error.code,
          "url": error.url,
        };
      });
    });

    _onUrlChanged = _flutterWebViewPlugin.onUrlChanged.listen((String url) {
      _flutterWebViewPlugin.evalJavascript("window.document.title").then((title) {
        title = title.substring(1, title.toString().length - 1);
        setState(() {
          this.title = title;
        });
      });
    });

    /**
     * 监听url变动时
     */
    _onStateChanged = _flutterWebViewPlugin.onStateChanged.listen((WebViewStateChanged state) async {
      switch (state.type) {
        case WebViewState.shouldStart:
        case WebViewState.startLoad:
        case WebViewState.finishLoad:
          break;
        case WebViewState.abortLoad:
          /**
           * [webview 内部指令]
           * 用于监听网页通知app的事件处理
           */
          switch (state.url) {
            case 'app://type=close':
              _flutterWebViewPlugin.close();
              this.dispose();
              Navigator.pop(context, "webviewBack");
              break;
            case 'app://type=back':
              this._goBack();
              break;
            case 'app://type=forward':
              _flutterWebViewPlugin.goForward();
              break;
            case 'app://type=refresh':
              _flutterWebViewPlugin.reload();
              break;
            default:
              // TODO 具体跳转路由代码
              break;
          }
          break;
      }
    });
  }

  _goForward () {
    _flutterWebViewPlugin.goForward();
  }

  _goBack () {
    _flutterWebViewPlugin.goBack();
  }

  Future _getData() async {
    return await options;
  }

  Widget _getWebview() {
    switch (_onHttpErrorMap["code"].toString()) {
      case "-6":
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("网页走丢"),
              Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  "${_onHttpErrorMap["url"]}  错误代码:${_onHttpErrorMap["code"]}",
                  style: TextStyle(
                    fontSize: 9,
                    color: Color(0xffaaaaaa),
                  ),
                ),
              )
            ],
          ),
        );
        break;
      case "null":
      default:
        return WebviewScaffold(
          key: _scaffoldKey,
          url: options["url"],
          withZoom: false,
          withLocalStorage: true,
          withJavascript: true,
          appCacheEnabled: true,
          withLocalUrl: true,
          hidden: true,
          allowFileURLs: true,
          invalidUrlRegex: 'app://.*',
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title??''),
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: _futureBuilderFuture,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            return Column(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: this._getWebview(),
                ),
                Container(
                  padding: EdgeInsets.only(
                    top: 10,
                    bottom: 10,
                    left: 30,
                    right: 30,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          this._goBack();
                        },
                        child: Icon(
                          Icons.chevron_left,
                          size: 50,
                          color: Colors.black45,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          this._goForward();
                        },
                        child: Icon(
                          Icons.chevron_right,
                          size: 50,
                          color: Colors.black45,
                        ),
                      ),

                    ],
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  /// 释放webview
  void _webviewDispose() {
    _onHttpError.cancel();
    _onUrlChanged.cancel();
    _onStateChanged.cancel();
    _flutterWebViewPlugin.hide();
    _flutterWebViewPlugin.dispose();
  }

  @override
  void dispose() {
    super.dispose();

    this._webviewDispose();
  }

  @override
  void deactivate() {
    super.deactivate();

    this._webviewDispose();
  }
}
