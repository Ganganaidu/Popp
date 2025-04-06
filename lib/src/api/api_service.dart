import 'dart:convert';
import 'dart:developer';
import 'package:poppflutter/src/api/api_url.dart';
import 'package:http/http.dart' as http;

// https://medium.com/codex/simplifying-api-calls-in-flutter-c39311172b6f

class ApiService {
  Uri _getUri(String endpoint) {
    return Uri.parse('${ApiUrl.baseUrl}$endpoint');
  }

  String _accessToken() {
    return "";
  }

  Map<String, String> _headers() {
    return {
      "Content-Type": "application/json",
      "token": _accessToken(),
    };
  }

  Future<http.Response> _sendRequest(
      Future<http.Response> Function() requestFunc, Uri uri,
      {dynamic body}) async {
    try {
      _logRequest(uri, body);
      final response = await requestFunc();
      _logResponse(uri, response);
      if (_isUnauthorized(response.statusCode)) {
        _handleUnauthorizedAccess();
      }
      return response;
    } catch (e) {
      log("Error during API call to $uri: $e");
      rethrow;
    }
  }

  void _logRequest(Uri uri, dynamic body) {
    log("Request URL: $uri");
    if (body != null) log("Request Body: ${jsonEncode(body)}");
  }

  void _logResponse(Uri uri, http.Response response) {
    log("Response for URL: $uri");
    log("Status Code: ${response.statusCode}");
    log("Response Body: ${response.body}");
  }

  bool _isUnauthorized(int statusCode) {
    return statusCode == 401 || statusCode == 403;
  }

  void _handleUnauthorizedAccess() {
    log("Unauthorized access detected.");
  }

  Future<http.Response> get(String endpoint) async {
    Uri uri = _getUri(endpoint);
    return _sendRequest(() => http.get(uri, headers: _headers()), uri);
  }

  Future<http.Response> post(String endpoint, dynamic body) async {
    Uri uri = _getUri(endpoint);
    return _sendRequest(
        () => http.post(uri, headers: _headers(), body: jsonEncode(body)), uri,
        body: body);
  }

  Future<http.Response> put(String endpoint, dynamic body) async {
    Uri uri = _getUri(endpoint);
    return _sendRequest(
        () => http.put(uri, headers: _headers(), body: jsonEncode(body)), uri,
        body: body);
  }

  Future<http.Response> patch(String endpoint, dynamic body) async {
    Uri uri = _getUri(endpoint);
    return _sendRequest(
        () => http.patch(uri, headers: _headers(), body: jsonEncode(body)), uri,
        body: body);
  }

  Future<http.Response> delete(String endpoint, {dynamic body}) async {
    Uri uri = _getUri(endpoint);
    return _sendRequest(
        () => http.delete(uri, headers: _headers(), body: jsonEncode(body)),
        uri,
        body: body);
  }

  Future<http.Response> updateProfileImage(String imagePath, endpoint) async {
    final uri = _getUri(endpoint);
    var request = http.MultipartRequest('PATCH', uri);
    request.files.add(await http.MultipartFile.fromPath('image', imagePath));
    request.headers.addAll(_headers());

    _logRequest(uri, {"imagePath": imagePath});

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    _logResponse(uri, response);

    return response;
  }
}

/*

EX: ways to call

Future<void> fetchUserData() async {
 final response = await apiService.get('/users');
 // Process the response data here…
}

Future<void> createUser(Map<String, dynamic> userData) async {
  final response = await apiService.post('/users', userData);
  // Handle the response accordingly...
}

* */