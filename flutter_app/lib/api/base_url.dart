class BaseUrl {
  // Use empty string for relative URLs when served through nginx
  // This allows the Flutter app to make requests to /api/* which nginx proxies to the backend
  static const String baseUrl = '';

  static String getUrl() {
    return baseUrl;
  }
}
