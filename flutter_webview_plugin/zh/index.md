# 开始 [施工中]

---

基于flutter\_webview\_plugin的实现方式

### 一、原理

### 二、代码
#### 2-1 创建
创建一份配置清单，起名为conf.json,作为jssdk的全局配置。
```json
  {
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
再创建一份app-jssdk[-mini].js并在头导入json。
```js
import Conf from 'conf.json';
```
接着创建

```js
class AppSdk {
  NAME = Conf.name';

  /// 是否在客户端内
  isApp() {
    var NAME = this.NAME;
    try {
      iframe.contentWindow.location.href = "${NAME}://app.com";
      return true;
    } catch(e) {
      if (e.name == "NS_ERROR_UNKNOWN_PROTOCOL") {}
      return false;
    }
  }
  
  close () {
    this.on('close');
  }

  /**
   * 通信指令
   * @param method
   * @param data
   * @returns {Promise<any>}
   */
  on(method = "none", {data = new Object()}) {
    var strData;
    var NAME = this.NAME;

    var util = new AppUtil();

    if (typeof data != "object") {
      console.log("data 为Object类型");
      return;
    }

    return new Promise(async (resolve, reject) => {
      switch (method) {
        case "close":
          strData = "${NAME}://type=close";
          break;
        case "back":
          strData = "${NAME}://type=back";
          break;
        case "forward":
          strData = "${NAME}://type=forward";
          break;
        case "refresh":
          strData = "${NAME}://type=refresh";
          break;
        case "toPage":
          data.type = method;
          strData = "${NAME}://" + util.urlEncode(data).slice(1);
          break;
        case "toWeb":
          data.type = method;
          strData = "${NAME}://" + util.urlEncode(data).slice(1);
          break;
        case "storeData":
          data.type = method;

          if (data.name == null || data.data == null || data.type == null) {
            console.log(`${method}方式参数错误，请检查该事件接收参数格式`);
            return;
          }

          strData = "${NAME}://" + util.urlEncode(data).slice(1);
          break;
        case "none":
        default:
          reject({
            "code": -1
          });
          break;
      }

      /**
       * 跳转协议， app接受
       * @type {string}
       */
      window.location.href = strData;

      resolve({
        "code": 0,
        "data": data,
        "youejiaAppUrl": strData,
      });
    })

  }
}
```
创建AppWeb类，

```js
/**
 * 处理App外部url
 */
 class AppWeb {
  on(type = "", {data = new Object()}) {
    const SDK = new AppSDk();
    const util = new AppUtil();
    const NAME = SDK.NAME;
    var uri = "${Conf.name}://app.com/";

    switch (type) {
      case "toPage_app":
        data.type = type;
        uri += util.urlEncode(data).slice(1);
        window.location.href = uri;
        break;
      case "openApp":
        if (navigator.userAgent.match(/(iPhone|iPod|iPad);?/i)) {
          var loadDateTime = new Date();
          
          window.setTimeout(function() {
            var timeOutDateTime = new Date();
            if (timeOutDateTime - loadDateTime <2200) {
              window.location = Conf.download.ios;
            } else {
              window.close();
            }
          },2000);
          
          window.location = "${NAME}://${Conf.schema.ios}";
          
        } else if (navigator.userAgent.match(/android/i)) {
          var loadDateTime = new Date();
          
          window.setTimeout(function() {
            var timeOutDateTime = new Date();
            if (timeOutDateTime - loadDateTime < 2200) {
              window.location = Conf.download.android;   
            } else {
              window.close();
            }
          },2000);
          
          window.location = "${NAME}://${Conf.schema.android}";
          
        }
        break;
      default:
        console.log("type is ''");
        break;
    }
  }
}
```
工具类

```js
class AppUtil {
  /**
  * 工具类 检查平台
  */
  isVersion () {
   if (navigator.userAgent.match(/(iPhone|iPod|iPad);?/i)) {
     return 'ios';
   } else if (navigator.userAgent.match(/android/i)) {
     return 'android';
   } else {
     return 'none';
   }
  }

  /**
   * 工具类 解析url地址
   * @param param
   * @param key
   * @param encode
   * @returns {string}
   */
  urlEncode(param, key, encode) {
    if (param == null) return '';
    var paramStr = '';
    var t = typeof (param);
    if (t == 'string' || t == 'number' || t == 'boolean') {
      paramStr += '&' + key + '=' + ((encode == null || encode) ? encodeURIComponent(param) : param);
    } else {
      for (var i in param) {
        var k = key == null ? i : key + (param instanceof Array ? '[' + i + ']' : '.' + i)
        paramStr += this.urlEncode(param[i], k, encode)
      }
    }
    return paramStr;
  }
}
```
#### 2-2 使用
在这里存在二种方式使用，第一种是在app内的webview网页直接通信。

```js
 const SDK = new AppSdk();
 
 // 终止(关闭)
 // SDK.on('close'); or SDK.close();
 
 // 返回
 // SDK.on('back');
 
 // 上一页
 // SDK.on('forward');
 
 // 刷新
 // SDK.on('refresh');
 
 // 跳转内部页面
 // SDK.on('toPage');
 
 // 通过App打开页面
 // SDK.on('toWeb');
```

第二种从系统游览器通信方式

```js
const WEB = new AppWeb();

// 从外部游览器直接打开app内指定页面
WEB.on('toPage_app', {
  // ...
});

// 单纯打开app
WEB.on('openApp');
```




