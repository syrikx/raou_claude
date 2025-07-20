# Flutter Google Sign-In 구현 과정 문제 해결 보고서

## 개요
Flutter 앱에서 Google Sign-In 기능을 구현하는 과정에서 발생한 문제들과 해결 과정을 정리한 문서입니다.

## 프로젝트 정보
- **앱 이름**: Raou (com.raou.claude.app)
- **플랫폼**: iOS (시뮬레이터)
- **Flutter 버전**: 3.29.3
- **Firebase SDK 버전**: 11.15.0
- **Google Sign-In 패키지 버전**: 6.1.4

## 발생한 문제들과 해결 방법

### 1. 초기 앱 크래시 문제

**문제 상황:**
- Google Sign-In 버튼 클릭 시 앱이 즉시 크래시
- "Lost connection to device" 메시지 발생

**원인 분석:**
Firebase iOS SDK가 설치되지 않은 상태에서 Google Sign-In을 시도하여 발생

**해결 방법:**
```yaml
# pubspec.yaml에 Firebase 패키지 추가
dependencies:
  firebase_core: ^3.15.1
  firebase_auth: ^5.6.2
  cloud_firestore: ^5.6.11
  google_sign_in: ^6.1.4
```

### 2. CocoaPods 버전 충돌 문제

**문제 상황:**
```
CocoaPods could not find compatible versions for pod "GoogleUtilities/Environment"
```

**원인 분석:**
- Firebase SDK와 Google Sign-In 패키지 간의 GoogleUtilities 버전 충돌
- 구버전 Firebase 패키지 사용으로 인한 호환성 문제

**해결 방법:**
1. Podfile.lock 삭제
```bash
rm -f ios/Podfile.lock
```

2. 최신 Firebase 패키지로 업데이트
```yaml
firebase_core: ^3.15.1  # 2.13.0에서 업그레이드
firebase_auth: ^5.6.2   # 4.6.3에서 업그레이드
cloud_firestore: ^5.6.11 # 4.7.1에서 업그레이드
```

3. CocoaPods 재설치
```bash
cd ios && pod install --repo-update
```

### 3. User 클래스 Import 충돌

**문제 상황:**
```
Error: 'User' is imported from both 'package:firebase_auth/firebase_auth.dart' and 'package:mvvm_app/models/user.dart'.
```

**원인 분석:**
Firebase Auth의 User 클래스와 앱 내부 User 모델 클래스 간의 이름 충돌

**해결 방법:**
Firebase Auth import에 alias 적용
```dart
// auth_view_model.dart
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/user.dart';

// 사용 시
firebase_auth.FirebaseAuth.instance.authStateChanges().listen((firebase_auth.User? user) {
  // ...
});
```

### 4. GoogleService-Info.plist 인식 문제

**문제 상황:**
```
[FirebaseCore][I-COR000012] Could not locate configuration file: 'GoogleService-Info.plist'.
```

**원인 분석:**
- GoogleService-Info.plist 파일이 Xcode 프로젝트의 Resources BuildPhase에 포함되지 않음
- Firebase가 런타임에 설정 파일을 찾지 못함

**해결 방법:**
1. Xcode 프로젝트 파일 직접 수정
```xml
<!-- project.pbxproj에 파일 참조 추가 -->
<key>74858FAF1ED2DC5600515812</key>
<dict>
    <key>isa</key>
    <string>PBXFileReference</string>
    <key>fileEncoding</key>
    <string>4</string>
    <key>lastKnownFileType</key>
    <string>text.plist.xml</string>
    <key>path</key>
    <string>GoogleService-Info.plist</string>
    <key>sourceTree</key>
    <string>&lt;group&gt;</string>
</dict>
```

2. Resources BuildPhase에 추가
```xml
<!-- PBXResourcesBuildPhase 섹션에 추가 -->
74858FAF1ED2DC5600515811 /* GoogleService-Info.plist in Resources */,
```

### 5. URL Scheme 설정

**문제 상황:**
Google Sign-In 시도 시 리다이렉션 처리 실패

**해결 방법:**
Info.plist에 Google Sign-In URL scheme 추가
```xml
<!-- ios/Runner/Info.plist -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>com.raou.claude.app</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.664498886284-n8b9pe90bghc5enu9aajkv0nldlkr1mk</string>
        </array>
    </dict>
</array>
```

## 최종 구현 구조

### Firebase 옵션 설정
```dart
// firebase_options.dart
class DefaultFirebaseOptions {
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAVHW-hXZvKG23gZl9yNuDEq8Hkm8sSI1I',
    appId: '1:664498886284:ios:bd9aed2496bdeb9159cda9',
    messagingSenderId: '664498886284',
    projectId: 'raou-claude',
    storageBucket: 'raou-claude.firebasestorage.app',
    iosBundleId: 'com.raou.claude.app',
  );
}
```

### Google Sign-In 구현
```dart
// auth_view_model.dart
final GoogleSignIn _googleSignIn = GoogleSignIn();

Future<bool> signInWithGoogle(BuildContext context) async {
  final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
  
  if (googleUser != null) {
    _currentUser = User(
      id: googleUser.id,
      email: googleUser.email,
      name: googleUser.displayName ?? 'Google User',
      profileImageUrl: googleUser.photoUrl,
      joinedAt: DateTime.now(),
    );
    _isAuthenticated = true;
    notifyListeners();
    return true;
  }
  return false;
}
```

### 앱 설정 토글 시스템
```dart
// app_config.dart
class AppConfig {
  static const bool enableGoogleSignIn = bool.fromEnvironment(
    'ENABLE_GOOGLE_SIGNIN',
    defaultValue: true,
  );
  
  static bool get isGoogleSignInEnabled {
    return enableGoogleSignIn;
  }
}
```

## 성공 결과

최종적으로 다음과 같은 성공적인 Google Sign-In 결과를 얻었습니다:

```
GoogleSignInAccount:{
  displayName: Woonyong Kim, 
  email: syrikx@gmail.com, 
  id: 113929359474565148251, 
  photoUrl: https://lh3.googleusercontent.com/a/ACg8ocLOlW4SeWypfPBP26n8wa4BntRMrj8Q6_4GAJcD7OGtFHG6-Q=s1337, 
  serverAuthCode: null
}
```

## 교훈 및 권장사항

1. **Firebase 설정의 중요성**: GoogleService-Info.plist 파일이 Xcode 프로젝트에 정확히 포함되어야 함
2. **패키지 버전 호환성**: Firebase와 Google Sign-In 패키지의 버전 호환성을 항상 확인
3. **Import 충돌 해결**: 동일한 클래스명 사용 시 alias를 통한 충돌 해결
4. **URL Scheme 설정**: iOS에서는 반드시 Info.plist에 URL scheme 추가 필요
5. **단계별 디버깅**: 각 문제를 순차적으로 해결하며 로그를 통한 원인 분석의 중요성

## 관련 파일 목록

- `pubspec.yaml`: Firebase 및 Google Sign-In 패키지 설정
- `lib/firebase_options.dart`: Firebase 플랫폼별 설정
- `lib/viewmodels/auth_view_model.dart`: Google Sign-In 로직 구현
- `lib/utils/app_config.dart`: 기능 토글 설정
- `ios/Runner/Info.plist`: URL scheme 설정
- `ios/Runner/GoogleService-Info.plist`: Firebase iOS 설정
- `ios/Runner.xcodeproj/project.pbxproj`: Xcode 프로젝트 설정

---
**작성일**: 2025-07-20  
**작성자**: Claude Code Assistant  
**프로젝트**: Raou Flutter App