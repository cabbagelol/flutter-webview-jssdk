/**
 * 功能：webview
 */

import 'dart:async';
import 'dart:convert';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:flutter/material.dart';

//import 'package:youejia/utils/index.dart';
//import 'package:flutter_plugin_elui/elui.dart';

class WebPage extends StatefulWidget {
  final data;

  WebPage({
    this.data,
  });

  @override
  State<StatefulWidget> createState() => WebPageState();
}

class WebPageState extends State<WebPage> {
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
            case 'youejia://type=close':
              _flutterWebViewPlugin.close();
              this.dispose();
              Navigator.pop(context, "webviewBack");
              break;
            case 'youejia://type=back':
              _flutterWebViewPlugin.goBack();
              break;
            case 'youejia://type=forward':
              _flutterWebViewPlugin.goForward();
              break;
            case 'youejia://type=refresh':
              _flutterWebViewPlugin.reload();
              break;
            default:
//              var postData = urlE(
//                state.url.replaceAll("youejia://", ""),
//              );

//              switch (postData["type"]) {
//                case "toPage":
//                  if (postData["path"] == null) {
//                    return;
//                  }
//                  /**
//                   * 跳转内部路由
//                   * @path
//                   *
//                   * 使用例子:
//                   * new YouejiaSdk().on("toPage", {
//                   *  data: {
//                   *    "path": "url"
//                   *  }
//                   * })
//                   */
////                  Routes.router.navigateTo(context, Uri.decodeComponent(postData["path"]), transition: TransitionType.cupertino).then(
////                    (_) {
////                      Navigator.pop(context);
////                    },
////                  );
//                  break;
//                case "toWeb":
//                  if (postData["path"] == "" || postData["path"] == null) {
//                    return;
//                  }
//                  /**
//                   * 跳转外部网页地址
//                   * @path
//                   *
//                   * 使用例子:
//                   * new YouejiaSdk().on("toWeb", {
//                   *  data: {
//                   *    "path": "url",
//                   *    "headers": {}
//                   *  }
//                   * })
//                   */
//                  print("toWeb==== ${postData["path"]}");
//
//                  _flutterWebViewPlugin.reloadUrl(
//                    Uri.decodeComponent(postData["path"]),
//                    headers: postData["headers"] ?? {},
//                  );
//                  break;
//                case "storeData":
//                  if (postData["name"] == null || postData["data"] == null || postData["type"] == null) {
//                    return;
//                  }
////                  Storage.set(
////                    postData["name"],
////                    value: postData["data"],
////                    type: postData["type"],
////                  );
//                  break;
//                default:
////                  EluiMessageComponent.error(context)(
////                    child: Text("非法协议，请参阅优e家JSSDK配置"),
////                  );
//                  break;
//              }
              break;
          }
          break;
      }
    });
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
          invalidUrlRegex: 'youejia://.*',
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//      appBar: !options["fullscreen"]
//          ? EluiHeadComponent(
//              context: context,
//              title: title ?? "",
//              isBack: options["isBack"] ,
//            )
//          : null,
      body: SafeArea(
//        top: options["fullscreen"] ? false : true,
        child: FutureBuilder(
          future: _futureBuilderFuture,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            return Column(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: this._getWebview(),
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
