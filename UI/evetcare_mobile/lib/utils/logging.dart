class ApiLogger {
  static void logRequest({
    required String method,
    required String url,
    Map<String, String>? headers,
    dynamic body,
  }) {
    print('--- API REQUEST ---');
    print('Method: $method');
    print('URL: $url');
    if (headers != null) print('Headers: $headers');
    if (body != null) print('Body: $body');
    print('-------------------');
  }

  static void logResponse({
    required int statusCode,
    required String url,
    dynamic body,
  }) {
    print('--- API RESPONSE ---');
    print('URL: $url');
    print('Status Code: $statusCode');
    print('Body: $body');
    print('--------------------');
  }
}
