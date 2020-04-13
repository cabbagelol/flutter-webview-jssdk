# 开始 [施工中]

--- 

基于flutter\_webview\_plugin的实现方式

### 一、原理

### 二、代码
#### 2-1-1 创建javascript代码
创建一份app-jssdk.js([传送门](../jssdk-0.1.js))，配置全局清单，具体说明如下。
```json
  const Conf = {
    // 协议名称,应当命名不易重合的名称
    name: 'app',
    // schema
    schema: {
      android: 'www.app.com', 
      ios: 'www.app.com',
    },
    // 应用下载地址
    download: {
      android: 'http(s)://www.app.com/download/app.apk',
      ios: 'http(s)://apps.apple.com/{ch (地区)}/app/apple-store/id{375380948 (应用id)}',
    }
  }
```

#### 2-1-2 使用
在这里jssdk.js文件提供二种方式使用，第一种是在app内的webview网页直接通信。

```js
 const SDK = new AppSdk();
 // 终止(关闭)
 // SDK.on('close'); or SDK.close();
 // 返回
 // SDK.on('back') or SDK.back();
 // 上一页
 // SDK.on('forward'); or SDK.forward();
 // 刷新
 // SDK.on('refresh'); or SDK.refresh();
```

另一种从系统游览器通信方式

```js
const WEB = new AppWeb();

// 单纯打开app
WEB.on('openApp');
```
#### 2-1-3 其他

- Q**: 能否扩展？**
- 答: 能, 这处决于您的业务，无论获取网页内路由还是控制，还是共享cookie都可以。


#### 2-2-1 创建flutter代码

具体看example/lib/下的代码 ([传送门](/../example/lib/))。

#### 2-2-2 使用

```dart
  // 导入
  import './webview/webview.dart';
  
  // 通过事件触发
  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => Webview(
      data: {
        'url': 'https://cabbagelol.github.io/flutter-webview-jssdk/flutter_webview_plugin/demo-01.html',
        'fullscreen': false
      }
  )));

```








