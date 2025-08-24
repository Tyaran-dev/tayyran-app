class AppConstants {
  // App Name
  static const String appName = 'Tayyran App';

  // API Base URL
  static const String apiBaseUrl = 'https://api.tayyran.com';

  // Timeout durations
  static const Duration apiTimeout = Duration(seconds: 30);

  // Shared Preferences Keys
  static const String prefUserToken = 'user_token';
  static const String prefIsFirstLaunch = 'is_first_launch';

  // Supported Locales
  static const List<String> supportedLocales = ['en', 'ar'];

  // Default Pagination Limit
  static const int defaultPageSize = 20;

  // Asset Paths
  static const String logoAsset = 'assets/images/logo.png';

  // Other constants can be added here
}
