# Raou Flutter App - 개발 가이드

## 프로젝트 개요
- **앱 이름**: Raou
- **Bundle ID**: com.raou.claude.app
- **아키텍처**: MVVM (Model-View-ViewModel) with Provider
- **플랫폼**: iOS, Android
- **주요 기능**: 쇼핑몰 앱 (Profile, Home, Cart, Order, Coupang 연동)

## 현재 구현 상태

### ✅ 완료된 기능
1. **MVVM 아키텍처 구현**
   - Provider를 사용한 상태 관리
   - BaseViewModel 추상 클래스
   - 각 기능별 ViewModel 분리

2. **Firebase 통합**
   - Firebase Core, Auth, Firestore 설정 완료
   - Google Sign-In 완전 구현 및 테스트 완료
   - Apple Sign-In 구현 완료 (Apple Developer Console 설정 필요)

3. **인증 시스템**
   - Google Sign-In 정상 작동
   - Apple Sign-In 코드 구현 완료
   - Mock 로그인 기능

4. **UI/UX**
   - 하단 탭 네비게이션 (Profile, Home, Cart, Order, Coupang)
   - 각 탭별 기본 화면 구현
   - Coupang WebView 통합

### 🚧 진행 중/대기 중인 작업
1. **Firebase Console 설정**
   - Authentication > Sign-in method에서 Google 활성화 필요
   - Apple Developer Console 설정 필요

2. **기능 확장**
   - 상품 관리 시스템
   - 장바구니 기능 확장
   - 주문 관리 시스템

## 개발 환경 설정

### 필수 요구사항
- Flutter SDK 3.29.3+
- Xcode 16.3+
- iOS 13.0+
- CocoaPods

### 빌드 및 실행
```bash
# 의존성 설치
flutter pub get

# iOS CocoaPods 설치
cd ios && pod install && cd ..

# 앱 실행
flutter run

# 린트 검사 (구현 예정)
# flutter analyze

# 타입 체크 (구현 예정)  
# dart analyze
```

## 프로젝트 구조

```
lib/
├── main.dart                 # 앱 진입점
├── firebase_options.dart     # Firebase 설정
├── models/                   # 데이터 모델
│   ├── user.dart
│   ├── product.dart
│   ├── cart_item.dart
│   ├── address.dart
│   └── order.dart
├── viewmodels/              # MVVM ViewModel 레이어
│   ├── base_view_model.dart
│   ├── auth_view_model.dart
│   ├── product_view_model.dart
│   ├── cart_view_model.dart
│   ├── address_view_model.dart
│   └── order_view_model.dart
├── views/                   # UI 화면
│   ├── home/
│   │   └── home_page.dart
│   ├── auth/
│   │   └── profile_page.dart
│   ├── cart/
│   │   └── cart_page.dart
│   ├── order/
│   │   └── order_page.dart
│   ├── coupang/
│   │   └── coupang_page.dart
│   └── shared/
│       └── loading_widget.dart
└── utils/
    └── app_config.dart      # 앱 설정 및 기능 토글
```

## 주요 설정 파일

### Firebase 설정
- `lib/firebase_options.dart`: 플랫폼별 Firebase 설정
- `ios/Runner/GoogleService-Info.plist`: iOS Firebase 설정
- `android/app/google-services.json`: Android Firebase 설정 (추가 필요)

### iOS 설정
- **Bundle ID**: com.raou.claude.app
- **Display Name**: Raou
- **Google Sign-In URL Scheme**: com.googleusercontent.apps.664498886284-n8b9pe90bghc5enu9aajkv0nldlkr1mk
- **Apple Sign-In Entitlements**: ios/Runner/Runner.entitlements

### 기능 토글 시스템
`lib/utils/app_config.dart`에서 환경변수로 기능 제어:
```dart
static const bool enableGoogleSignIn = bool.fromEnvironment('ENABLE_GOOGLE_SIGNIN', defaultValue: true);
static const bool enableAppleSignIn = bool.fromEnvironment('ENABLE_APPLE_SIGNIN', defaultValue: true);
static const bool enableFirebase = bool.fromEnvironment('ENABLE_FIREBASE', defaultValue: false);
```

## 의존성 패키지

### 핵심 패키지
```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.2              # 상태 관리
  
  # Firebase
  firebase_core: ^3.15.1
  firebase_auth: ^5.6.2
  cloud_firestore: ^5.6.11
  
  # 인증
  google_sign_in: ^6.1.4
  sign_in_with_apple: ^6.1.2
  
  # UI/기타
  webview_flutter: ^4.2.2
  http: ^1.3.0
  json_annotation: ^4.9.0
  uuid: ^4.5.1
```

## 인증 시스템 사용법

### Google Sign-In 테스트
1. Profile 탭으로 이동
2. "Sign in with Google" 버튼 클릭
3. Google 계정 선택 및 인증
4. 성공 시 사용자 정보 표시

### Apple Sign-In (설정 완료 후)
1. Apple Developer Console에서 Bundle ID 등록 필요
2. Sign in with Apple 서비스 활성화 필요

## 디버깅 및 문제 해결

### 일반적인 문제
1. **CocoaPods 충돌**: `rm ios/Podfile.lock && cd ios && pod install`
2. **Firebase 초기화 실패**: GoogleService-Info.plist 경로 확인
3. **Google Sign-In 실패**: URL Scheme 설정 확인

### 로그 확인
```bash
# Flutter 로그
flutter logs

# iOS 시뮬레이터 로그
xcrun simctl spawn booted log show --predicate 'process == "Runner"' --info --last 5m
```

## Git 브랜치 전략
- `main`: 안정적인 릴리즈 브랜치
- 기능별 브랜치 생성 후 main으로 병합

## 향후 개발 계획

### 단기 목표
1. Firebase Console Authentication 설정 완료
2. Apple Sign-In 테스트 완료
3. 상품 관리 기능 구현

### 중기 목표
1. Android 플랫폼 지원
2. 결제 시스템 통합
3. 푸시 알림 기능

## 팀 협업

### 코드 스타일
- Dart/Flutter 표준 컨벤션 준수
- 모든 public 메서드에 문서화 주석 추가
- MVVM 패턴 엄격히 준수

### 커밋 메시지 형식
```
type: 간단한 설명

상세 설명 (선택사항)

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

## 연락처 및 지원
- 프로젝트 관리자: wykim
- 개발 문의: GitHub Issues 활용

---
**최종 업데이트**: 2025-07-20  
**버전**: 1.0.0  
**상태**: Google Sign-In 구현 완료