class Constants {
  // Use 10.0.2.2 for Android emulator to access localhost, or change to host IP
  static const String baseUrl =
      'https://app.azzakarunia.my.id/api/v1'; // Production URL
  // static const String baseUrl =
  //     'https://implicitly-genuine-kiwi.ngrok-free.app/api/v1'; // Production URL
  static const int connectTimeout = 30; // seconds
  static const int receiveTimeout = 30; // seconds

  // Backend serves uploaded photos from the public root (not /api/v1), so
  // strip the API path suffix to build the host used for media/photo URLs.
  static String get mediaBaseUrl =>
      baseUrl.replaceFirst(RegExp(r'/api/v\d+/?$'), '');
}
