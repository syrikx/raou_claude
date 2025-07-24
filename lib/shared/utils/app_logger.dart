import 'package:flutter/foundation.dart';

/// 앱 전체에서 사용할 통합 로거 클래스
/// - 개발 모드에서만 로그 출력
/// - 다양한 로그 레벨 지원
/// - 구조화된 로그 포맷
class AppLogger {
  static const bool _isDebugMode = kDebugMode;
  
  /// 🟢 일반 정보 로그
  static void info(String message, {String? tag}) {
    if (!_isDebugMode) return;
    final logTag = tag ?? 'INFO';
    print('✅ [$logTag] $message');
  }
  
  /// 🟡 경고 로그
  static void warning(String message, {String? tag}) {
    if (!_isDebugMode) return;
    final logTag = tag ?? 'WARNING';
    print('⚠️ [$logTag] $message');
  }
  
  /// 🔴 오류 로그
  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    if (!_isDebugMode) return;
    final logTag = tag ?? 'ERROR';
    print('❌ [$logTag] $message');
    if (error != null) {
      print('   Error: $error');
    }
    if (stackTrace != null) {
      print('   StackTrace: $stackTrace');
    }
  }
  
  /// 🔵 디버그 로그
  static void debug(String message, {String? tag}) {
    if (!_isDebugMode) return;
    final logTag = tag ?? 'DEBUG';
    print('🔍 [$logTag] $message');
  }
  
  /// 🟣 네트워크 관련 로그
  static void network(String message, {String? method, String? url, int? statusCode}) {
    if (!_isDebugMode) return;
    final methodTag = method != null ? '[$method]' : '';
    final statusTag = statusCode != null ? '($statusCode)' : '';
    print('🌐 [NETWORK]$methodTag$statusTag $message');
    if (url != null) {
      print('   URL: $url');
    }
  }
  
  /// 📱 UI 관련 로그
  static void ui(String message, {String? widget}) {
    if (!_isDebugMode) return;
    final widgetTag = widget != null ? '[$widget]' : '';
    print('🎨 [UI]$widgetTag $message');
  }
  
  /// 💾 데이터 관련 로그
  static void data(String message, {String? operation, dynamic value}) {
    if (!_isDebugMode) return;
    final opTag = operation != null ? '[$operation]' : '';
    print('💾 [DATA]$opTag $message');
    if (value != null) {
      print('   Value: $value');
    }
  }
  
  /// 🔄 상태 변경 로그
  static void state(String message, {String? from, String? to}) {
    if (!_isDebugMode) return;
    final transition = (from != null && to != null) ? ' ($from → $to)' : '';
    print('🔄 [STATE]$transition $message');
  }
  
  /// 📊 성능 측정 로그
  static void performance(String message, {Duration? duration}) {
    if (!_isDebugMode) return;
    final durationTag = duration != null ? ' (${duration.inMilliseconds}ms)' : '';
    print('⚡ [PERFORMANCE]$durationTag $message');
  }
  
  /// 🎯 사용자 액션 로그
  static void userAction(String action, {Map<String, dynamic>? params}) {
    if (!_isDebugMode) return;
    print('👆 [USER_ACTION] $action');
    if (params != null && params.isNotEmpty) {
      params.forEach((key, value) {
        print('   $key: $value');
      });
    }
  }
  
  /// 📏 구분선 출력
  static void divider([String? title]) {
    if (!_isDebugMode) return;
    final titleStr = title != null ? ' $title ' : '';
    print('${'=' * 20}$titleStr${'=' * 20}');
  }
  
  /// 🚀 앱 시작 로그
  static void appStart(String message) {
    if (!_isDebugMode) return;
    divider('APP START');
    print('🚀 $message');
    divider();
  }
  
  /// 🛑 앱 종료 로그  
  static void appStop(String message) {
    if (!_isDebugMode) return;
    divider('APP STOP');
    print('🛑 $message');
    divider();
  }
}