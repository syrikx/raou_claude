# Raou 앱 APK 다운로드 - 쿠팡 주문 Intercept 기능 테스트

## 📱 APK 파일 정보
- **앱 이름**: Raou (쇼핑몰 앱)  
- **Bundle ID**: com.raou.claude.app
- **버전**: 1.0.0+1
- **빌드 날짜**: 2025-07-22
- **아키텍처**: MVVM with Provider
- **주요 기능**: 쿠팡 주문 intercept 및 대행 서비스

## 🔗 다운로드 링크

### Debug APK (테스트용)
**파일명**: `app-debug.apk`  
**파일 크기**: 210MB  
**GitHub Raw URL**:
```
https://github.com/syrikx/raou_claude/raw/main/build/app/outputs/flutter-apk/app-debug.apk
```

### Release APK (배포용)
**파일명**: `app-release.apk`  
**파일 크기**: 50MB  
**GitHub Raw URL**:
```
https://github.com/syrikx/raou_claude/raw/main/build/app/outputs/flutter-apk/app-release.apk
```

## 📋 설치 및 테스트 가이드

### 1. APK 설치
1. Android 기기에서 위 링크를 통해 APK 다운로드
2. "알 수 없는 출처" 앱 설치 허용 (설정 > 보안)
3. 다운로드된 APK 파일 실행하여 설치

### 2. 핵심 기능 테스트: 쿠팡 주문 Intercept

#### 🎯 테스트 시나리오
1. **앱 실행** → Firebase 초기화 로그 확인
2. **Coupang 탭** 이동 → WebView에서 쿠팡 사이트 로딩
3. 임의 상품 페이지로 이동
4. **하단 빨간 테두리 영역** 탭 (주문 대행 영역)
   ```
   🛒 주문 대행 영역 (쿠팡 주문 버튼 덮개)
   ```
5. 상품 정보 추출 및 주문 대행 다이얼로그 확인
6. **Order 탭**에서 intercept된 주문 내역 확인

#### ✅ 기대 결과
- 쿠팡 주문 버튼 클릭 시 실제 쿠팡으로 주문이 가지 않음
- 상품 정보가 추출되어 자체 시스템에 저장됨
- "주문 대행 접수" 성공 다이얼로그 표시
- Order 탭에서 intercept된 주문 내역 확인 가능

### 3. 기본 기능 테스트

#### Google Sign-In (이전 검증 완료)
- **Profile 탭** → "Sign in with Google" 버튼
- Google 계정 선택 및 인증
- 사용자 정보 표시 확인

#### UI/UX 검증
- ✅ WebView 전체화면 레이어링
- ✅ 상단 AppBar 오버레이
- ✅ 하단 네비게이션 오버레이  
- ✅ 5개 탭 네비게이션 (Profile, Home, Cart, Order, Coupang)

## 🚀 최신 업데이트 (2025-07-22)

### 새로 구현된 기능
- **쿠팡 주문 Intercept 시스템**: 원본 Raou 앱의 핵심 기능 완전 구현
- **WebView 레이어링 구조**: 전체화면 WebView + 오버레이 네비게이션
- **상품 정보 추출**: JavaScript를 통한 쿠팡 페이지 데이터 추출
- **주문 대행 처리**: 추출된 정보를 자체 DB에 저장하는 시스템

### Git 히스토리
```bash
98db00c - fix: OrderViewModel 모델 필드명 불일치 수정
fff481f - feat: 쿠팡 주문 intercept 시스템 완전 구현  
70dc68f - docs: Android 앱 개발 문제 해결 보고서 추가
717ac24 - fix: Android 앱 크래시 문제 완전 해결 및 Google Sign-In 정상화
b15ae26 - feat: Google Sign-In 완전 구현 및 Firebase iOS SDK 통합
```

## ⚠️ 참고사항

### 보안 설정
- 앱에서 쿠팡 사이트 접근을 위한 네트워크 보안 설정 포함
- clearTextTraffic 허용 (개발/테스트 목적)

### 권한
- 인터넷 접근
- 네트워크 상태 확인
- Firebase 및 Google 서비스 연동

### 로그 확인
Android 로그를 통해 상세한 디버그 정보 확인 가능:
```bash
adb logcat | grep -E "(flutter|🚀|✅|❌|🛒)"
```

---

**개발자**: wykim  
**프로젝트**: https://github.com/syrikx/raou_claude  
**테스트 문의**: GitHub Issues 활용