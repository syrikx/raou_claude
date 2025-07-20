class AppConstants {
  static const String appName = 'MVVM Flutter App';
  static const String baseApiUrl = 'https://jsonplaceholder.typicode.com';
  
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration animationDuration = Duration(milliseconds: 300);
  
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  
  static const double defaultBorderRadius = 8.0;
  static const double cardElevation = 4.0;
}

class RouteConstants {
  static const String home = '/';
  static const String userDetail = '/user-detail';
  static const String addUser = '/add-user';
  static const String editUser = '/edit-user';
}