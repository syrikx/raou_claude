# Raou Android 앱 개발 문제 해결 보고서

## 📋 프로젝트 개요
- **프로젝트명**: Raou (쇼핑몰 앱)
- **플랫폼**: Android
- **아키텍처**: MVVM with Provider
- **주요 기능**: Google Sign-In, Firebase 연동, Coupang WebView

---

## 🚨 발생한 주요 문제들과 해결 방법

### 1. 앱 시작 즉시 크래시 (치명적 문제)

#### 🔍 문제 상황
- APK 설치 후 앱 실행 시 즉시 크래시
- 로그 출력 없이 앱이 종료됨
- 실제 디바이스와 에뮬레이터 모두에서 동일한 현상

#### 🔧 해결 과정

##### 1단계: Firebase 설정 문제 의심
```dart
// 잘못된 접근 - Firebase 비활성화 시도
static const bool enableFirebase = bool.fromEnvironment(
  'ENABLE_FIREBASE',
  defaultValue: false, // ❌ 릴리즈에서 비활성화
);
```

##### 2단계: 네트워크 권한 문제 발견
```xml
<!-- AndroidManifest.xml에 누락된 권한들 추가 -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
```

##### 3단계: Firebase 설정 불일치 수정
```dart
// firebase_options.dart Android 설정 수정
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'AIzaSyAL3B9SimAP5guT3XL3kPInkk4xQtC60gQ', // ✅ 올바른 키
  appId: '1:664498886284:android:43fc9601103afbb659cda9', // ✅ 올바른 앱 ID
);
```

##### 4단계: MainActivity 패키지명 불일치 발견 (핵심 원인!)
```
문제: 
- build.gradle.kts: com.raou.claude.app
- MainActivity.kt: com.example.mvvm_app ❌

해결:
1. MainActivity.kt 패키지명 변경: com.raou.claude.app
2. 파일 경로 이동: kotlin/com/raou/claude/app/MainActivity.kt
```

#### ✅ 해결 결과
- 앱 정상 시작
- Firebase 초기화 성공
- 모든 ViewModel 정상 생성

---

### 2. Google Sign-In OAuth 오류

#### 🔍 문제 상황
- Google 계정 선택까지는 정상 진행
- "Google 로그인 중 오류가 발생하였습니다" 메시지 표시
- OAuth 인증 실패

#### 🔧 해결 과정

##### 1단계: 상세 로그 추가
```dart
} catch (error) {
  print('🔴 Google Sign-In 상세 오류: $error');
  print('🔴 오류 타입: ${error.runtimeType}');
  print('🔴 오류 문자열: ${error.toString()}');
  
  // 오류 타입별 메시지 분류
  if (errorString.contains('invalid_client') || errorString.contains('oauth')) {
    errorMessage = 'Google 인증 설정 오류입니다. 개발자에게 문의하세요.';
  }
}
```

##### 2단계: SHA1 인증서 지문 확인
```bash
# Android Debug Keystore SHA1 추출
keytool -list -v -alias androiddebugkey -keystore ~/.android/debug.keystore

# 결과: 2D:28:D8:2F:54:67:09:A7:E0:49:C9:AD:A5:5F:F6:62:B5:33:9F:E1
```

##### 3단계: Firebase Console 설정
```
Firebase Console > 프로젝트 설정 > 앱 > SHA 인증서 지문
- SHA1 지문 등록: 2D:28:D8:2F:54:67:09:A7:E0:49:C9:AD:A5:5F:F6:62:B5:33:9F:E1 ✅
```

#### ✅ 해결 결과
- Google Sign-In 완전 정상화
- 사용자 정보 정상 조회
- Firebase Auth 연동 성공

---

### 3. 빌드 및 설정 관련 문제들

#### 🔧 Android NDK 버전 충돌
```gradle
// build.gradle.kts 수정
android {
    ndkVersion = "27.0.12077973" // ✅ Firebase 요구사항 만족
    minSdk = 23 // ✅ Firebase Auth 최소 요구사항
}
```

#### 🔧 Gradle 빌드 설정
```gradle
// android/build.gradle.kts
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.google.gms:google-services:4.4.2") // ✅ Google Services 플러그인
    }
}
```

---

## 🛠️ 적용된 디버깅 전략

### 1. 단계별 로그 추가
```dart
void main() async {
  print('🚀 앱 시작 - main() 호출됨');
  print('📱 WidgetsFlutterBinding 초기화 중...');
  print('🔥 Firebase 초기화 시작...');
  // ... 각 단계별 상세 로그
}
```

### 2. 에러 핸들링 강화
```dart
try {
  // 초기화 로직
} catch (e, stackTrace) {
  print('💥 초기화 오류: $e');
  print('스택 트레이스: $stackTrace');
  // 기본 모드로 복구 시도
}
```

### 3. 실시간 로그 모니터링
```bash
# Android 로그캣을 통한 실시간 디버깅
adb logcat | grep -E "(flutter|🚀|✅|❌|💥)"
```

---

## 📊 최종 검증 결과

### ✅ 정상 작동 기능
- [x] 앱 시작 및 Firebase 초기화
- [x] Google Sign-In 완전 기능
- [x] Apple Sign-In 코드 구현 (테스트 대기)
- [x] MVVM 아키텍처 및 Provider 상태 관리
- [x] 하단 탭 네비게이션 (Profile, Home, Cart, Order, Coupang)
- [x] Coupang WebView 통합
- [x] 네트워크 권한 및 Firebase 연결

### 🔧 배운 교훈
1. **패키지명 일치의 중요성**: Android 앱에서 모든 구성 요소의 패키지명이 일치해야 함
2. **권한 설정의 필수성**: 네트워크 관련 기능에는 반드시 매니페스트 권한 필요
3. **SHA1 인증서 등록**: OAuth 기반 인증은 반드시 인증서 지문 등록 필요
4. **단계별 디버깅**: 복합적인 문제는 단계별로 나누어 해결하는 것이 효과적
5. **실환경 테스트의 중요성**: 에뮬레이터와 실제 디바이스 모두에서 테스트 필요

---

## 🚀 향후 개발 가이드

### 새로운 기능 추가 시 체크리스트
- [ ] 필요한 권한이 AndroidManifest.xml에 등록되었는지 확인
- [ ] 패키지명이 모든 파일에서 일치하는지 확인
- [ ] Firebase Console에서 필요한 서비스가 활성화되었는지 확인
- [ ] SHA1 인증서가 등록되었는지 확인 (OAuth 사용 시)
- [ ] 단계별 로그를 추가하여 디버깅 용이성 확보
- [ ] 에러 핸들링 및 사용자 친화적 메시지 제공

### 릴리즈 전 필수 확인사항
1. Release APK에서 정상 작동 확인
2. 모든 권한 및 설정 파일 검증
3. Firebase Console 설정 최종 확인
4. 실제 디바이스에서 전체 기능 테스트

---

**작성일**: 2025-07-21  
**최종 커밋**: 717ac24 - fix: Android 앱 크래시 문제 완전 해결 및 Google Sign-In 정상화  
**상태**: ✅ 모든 주요 문제 해결 완료