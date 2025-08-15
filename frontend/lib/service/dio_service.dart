import 'package:dio/dio.dart';
import 'auth_service.dart';

/// Author: Łukasz Piętka (FUT 2025)
class DioService {
  static final DioService _instance = DioService._internal();
  factory DioService() => _instance;

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://poligon-2025.azurewebsites.net/api/',
      contentType: 'application/json',
      validateStatus: (status) =>
       status != null && (status >= 200 && status < 300) || status == 304,
    ),
  );

  String? _idToken;

  DioService._internal() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_idToken != null &&
              (options.method != 'GET' || options.path.contains('crew/me'))) {
            options.headers['Authorization'] = 'Bearer $_idToken';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            final refreshed = await _tryReauthenticate();
            if (refreshed) {
              final RequestOptions requestOptions = error.requestOptions;

              // Skopiuj oryginalny request z nowym tokenem
              final opts = Options(
                method: requestOptions.method,
                headers: requestOptions.headers,
              );


              // Ustaw nowy token
              if (_idToken != null) {
                opts.headers?['Authorization'] = 'Bearer $_idToken';
              }

              try {
                final Response response = await dio.request(
                  requestOptions.path,
                  data: requestOptions.data,
                  queryParameters: requestOptions.queryParameters,
                  options: opts,
                );
                return handler.resolve(response);
              } catch (e) {
                return handler.reject(e as DioException);
              }
            } else {
              // Nie udało się zalogować ponownie
              return handler.reject(error);
            }
          } else {
            return handler.next(error);
          }
        },
      ),
    );
  }

  void setIdToken(String token) {
    _idToken = token;
  }

  void clearIdToken() {
    _idToken = null;
  }

  Future<bool> _tryReauthenticate() async {
    try {
      final authService = AuthService();
      await authService.signInWithGoogle();
      return _idToken != null;
    } catch (e) {
      print('Ponowne logowanie nie powiodło się: $e');
      return false;
    }
  }
}
