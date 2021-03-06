import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wanandroidflutter/entity/base_entity.dart';
import 'package:wanandroidflutter/net/request_urls.dart';
import 'package:wanandroidflutter/net/wan_android_cookie_manager.dart';
import 'package:wanandroidflutter/utils/net/net_exception.dart';
import 'package:wanandroidflutter/utils/net/net_request.dart';
import 'package:cookie_jar/cookie_jar.dart';

class WanAndroidApi {
  static WanAndroidCookieManager _androidCookieManager;

  static Future<void> init() async {
    await Net.instance.init(baseUrl: URL_BASE);
    _androidCookieManager = WanAndroidCookieManager(PersistCookieJar(dir: '${(await getApplicationDocumentsDirectory()).path}/cookie/'));
    Net.instance.dio.interceptors.add(_androidCookieManager);
  }

  static bool isAuth() {
    return _androidCookieManager.isAuth();
  }

  static Future<BaseEntity<T>> get<T>(
    String path, {
    Map<String, dynamic> queryParameters,
    Options options,
    CancelToken cancelToken,
    ProgressCallback onReceiveProgress,
  }) async {
    Map<String, dynamic> response = await Net.instance.get(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
    return _tran2Entity<T>(response);
  }

  static Future<BaseEntity<T>> post<T>(
    String path, {
    Map<String, dynamic> params,
    Map<String, dynamic> queryParameters,
    Options options,
    CancelToken cancelToken,
    ProgressCallback onSendProgress,
    ProgressCallback onReceiveProgress,
  }) async {
    Map<String, dynamic> response = await Net.instance.post(
      path,
      params: params,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    return _tran2Entity<T>(response);
  }

  static Future<BaseEntity<T>> postFrom<T>(
    String path, {
    FormData data,
    Map<String, dynamic> queryParameters,
    Options options,
    CancelToken cancelToken,
    ProgressCallback onSendProgress,
    ProgressCallback onReceiveProgress,
  }) async {
    Map<String, dynamic> response = await Net.instance.postForm(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
    return _tran2Entity<T>(response);
  }

  static BaseEntity<T> _tran2Entity<T>(Map<String, dynamic> response) {
    var errorMsg = response['errorMsg'];
    var errorCode = response['errorCode'];

    if (errorCode.toInt() != 0) {
      throw NetException(errorMsg);
    }
    return BaseEntity<T>.fromJson(response);
  }
}
