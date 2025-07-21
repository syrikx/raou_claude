import 'package:flutter/foundation.dart';

class AppConfig {
  // Firebase 기능 활성화 여부
  static const bool enableFirebase = bool.fromEnvironment(
    'ENABLE_FIREBASE',
    defaultValue: true, // 기본값: Firebase 활성화 (Release 버전에서도)
  );
  
  // Google Sign-In 기능 활성화 여부
  static const bool enableGoogleSignIn = bool.fromEnvironment(
    'ENABLE_GOOGLE_SIGNIN',
    defaultValue: true, // Firebase 연동으로 다시 활성화
  );
  
  // Apple Sign-In 기능 활성화 여부
  static const bool enableAppleSignIn = bool.fromEnvironment(
    'ENABLE_APPLE_SIGNIN',
    defaultValue: true, // Apple Sign-In 기본 활성화
  );
  
  // 개발 모드에서는 Firebase 기능을 활성화할지 여부
  static const bool enableFirebaseInDebug = bool.fromEnvironment(
    'ENABLE_FIREBASE_DEBUG',
    defaultValue: true, // 개발 시에는 기본적으로 활성화
  );
  
  // 현재 Firebase가 사용 가능한지 확인
  static bool get isFirebaseEnabled {
    // 릴리즈 모드에서는 ENABLE_FIREBASE 환경변수에 따라
    // 디버그 모드에서는 ENABLE_FIREBASE_DEBUG에 따라
    if (kReleaseMode) {
      return enableFirebase;
    } else {
      return enableFirebaseInDebug;
    }
  }
  
  // Google Sign-In 사용 가능 여부
  static bool get isGoogleSignInEnabled {
    return enableGoogleSignIn; // Firebase 종속성 제거
  }
  
  // Apple Sign-In 사용 가능 여부  
  static bool get isAppleSignInEnabled {
    return enableAppleSignIn; // Firebase 종속성 제거
  }
  
  // 환경 설정 정보 출력 (디버그용)
  static void printConfig() {
    print('=== App Config ===');
    print('Firebase Enabled: $isFirebaseEnabled');
    print('Google Sign-In Enabled: $isGoogleSignInEnabled');
    print('Apple Sign-In Enabled: $isAppleSignInEnabled');
    print('==================');
  }
}