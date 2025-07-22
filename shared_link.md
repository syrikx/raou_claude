# 📱 Raou 앱 APK 다운로드 - 쿠팡 주문 Intercept 기능 테스트

## 🔗 다운로드 링크
**GitHub Release**: https://github.com/syrikx/raou_claude/releases/tag/v1.0.0-intercept

## 📦 APK 파일 옵션

### 1. **app-release.apk** (권장)
- **파일 크기**: 50MB
- **용도**: 최적화된 배포용 버전
- **추천 대상**: 일반 테스트용

### 2. **app-debug.apk**
- **파일 크기**: 210MB  
- **용도**: 디버그 정보 포함 개발용
- **추천 대상**: 상세 로그 확인 필요 시

## 🎯 핵심 기능 테스트 가이드

### **쿠팡 주문 Intercept 시스템 검증**

1. **APK 설치**
   - Android 기기에서 다운로드
   - "알 수 없는 출처" 설치 허용 후 설치

2. **앱 실행**
   - Firebase 초기화 성공 확인
   - 5개 탭 네비게이션 확인

3. **쿠팡 주문 Intercept 테스트**
   ```
   Coupang 탭 → 상품 페이지 → 하단 빨간 테두리 영역 탭
   ```
   - **하단 빨간 테두리 영역**: "🛒 주문 대행 영역 (쿠팡 주문 버튼 덮개)"
   - 탭하면 상품 정보 추출 시작
   - "🎉 주문이 성공적으로 intercept되었습니다!" 다이얼로그 확인

4. **결과 확인**
   - Order 탭 이동
   - Intercept된 주문 내역 표시 확인
   - 추출된 상품 정보 확인

## ✅ 이전 검증 완료 기능

### Google Sign-In (syrikx@gmail.com 테스트 완료)
- Profile 탭 → "Sign in with Google"
- 계정 선택 및 인증 완료
- 사용자 정보 정상 표시

### Android 플랫폼 안정성
- 앱 크래시 문제 모두 해결
- Firebase 통합 완료
- 실기기 테스트 검증 완료

## 🚀 최신 구현 기능 (2025-07-22)

### WebView 레이어링 시스템
- **전체화면 WebView**: 쿠팡 사이트 완전 표시
- **오버레이 네비게이션**: 상단 AppBar + 하단 탭바
- **주문 Intercept 레이어**: 쿠팡 주문 버튼 위에 투명 레이어

### JavaScript 기반 데이터 추출
```javascript
// 상품명, 가격, 판매자, 이미지 URL 실시간 추출
const productName = document.querySelector('.prod-buy-header__title')?.textContent;
const price = document.querySelector('.total-price')?.textContent;
```

### MVVM 아키텍처 통합
- **OrderViewModel**: Intercept된 주문 처리
- **Order 모델**: `intercepted` 상태 추가
- **Provider 상태 관리**: 실시간 UI 업데이트

## 📱 앱 정보
- **앱 이름**: Raou
- **Bundle ID**: com.raou.claude.app
- **버전**: 1.0.0+1
- **아키텍처**: MVVM with Provider
- **주요 기능**: 쿠팡 주문 대행 및 구매 대행 서비스

## ⚠️ 테스트 시 참고사항

### 네트워크 설정
- 쿠팡 사이트 접근을 위한 clearTextTraffic 허용
- HTTP/HTTPS 혼용 지원

### 로그 확인 (개발자용)
```bash
adb logcat | grep -E "(flutter|🚀|✅|❌|🛒|🎉)"
```

### 예상 동작
- ✅ 쿠팡 실제 주문 차단
- ✅ 상품 정보 추출 성공
- ✅ 자체 시스템 주문 저장
- ✅ 사용자 피드백 제공

---

**개발**: wykim + Claude Code  
**GitHub**: https://github.com/syrikx/raou_claude  
**최종 업데이트**: 2025-07-22  
**테스트 문의**: GitHub Issues