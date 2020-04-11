# 开始

---

基于flutter\_webview\_plugin的实现方式

一、原理

二、代码

```js
class AppSdk {
  NAME = 'youejia';

  /// 是否在客户端内
  isApp() {
    try {
      iframe.contentWindow.location.href = "youejia://app.com";
      return true;
    } catch(e) {
      if (e.name == "NS_ERROR_UNKNOWN_PROTOCOL") {}
      return false;
    }
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

    var util = new YouejiaUtil();

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
处理业务性质对接接口

```
/**
 * 处理App外部url
 */
 class AppWeb {
  on(type = "", {data = new Object()}) {  
  
    var uri = "youejia://app.com/";

    var util = new AppUtil();

    switch (type) {
      case "toPage_app":
        data.type = type;
        uri += util.urlEncode(data).slice(1);
        window.location.href = uri;
        break;
      case "openApp":
        if (navigator.userAgent.match(/(iPhone|iPod|iPad);?/i)) {
          // 判断useragent，当前设备为ios设备
          var loadDateTime = new Date();
          // 设置时间阈值，在规定时间里面没有打开对应App的话，直接去App store进行下载。
          window.setTimeout(function() {
            var timeOutDateTime = new Date();
            if (timeOutDateTime - loadDateTime <2200) {
              window.location = "xxxxxxxx";  // APP下载地址
            } else {
              window.close();
            }
          },2000);
          window.location = "apptest://apptest";　　//ios端URL Schema
        } else if (navigator.userAgent.match(/android/i)) {
          // 判断useragent，当前设备为Android设备
          // 判断useragent，当前设备为ios设备
          var loadDateTime = new Date();
          // 设置时间阈值，在规定时间里面没有打开对应App的话，直接去App store进行下载。
          window.setTimeout(function() {
            var timeOutDateTime = new Date();
            if (timeOutDateTime - loadDateTime < 2200) {
              window.location = "http://leyej.com";   // APP下载地址
            } else {
              window.close();
            }
          },2000);
          window.location = "youejia://app.com";　　// Android端URL Schema
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

```
class AppUtil {
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



