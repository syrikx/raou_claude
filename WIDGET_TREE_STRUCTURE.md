# 📱 Raou 앱 위젯 트리 구조 문서

## 📋 개요

본 문서는 Raou Flutter 앱의 완전한 위젯 트리 구조를 설명합니다. 이 앱은 원본 [syrikx/raou](https://github.com/syrikx/raou)의 UI 구조를 100% 복원하면서 MVVM 패턴을 적용한 현대적 Flutter 앱입니다.

## 🏗️ 전체 위젯 트리 구조

```
MaterialApp
├── title: "Raou"
├── theme: ThemeData(Material3 + DeepPurple)
└── home: Builder
    └── MyHomePage
        └── SafeArea
            └── WillPopScope
                └── Scaffold
                    └── Stack
                        ├── Positioned.fill
                        │   └── WebViewWidget(controller: controller)
                        │       ├── JavaScript: enabled
                        │       ├── Background: Colors.white
                        │       ├── UserAgent: Chrome Mobile
                        │       └── URL: https://www.coupang.com/
                        │
                        └── Align(alignment: Alignment.bottomCenter)
                            └── Consumer<CartViewModel>
                                └── RaouNavigationBar
                                    ├── Container
                                    │   ├── color: Color(0xFF2C2C54).withOpacity(0.9)
                                    │   ├── padding: EdgeInsets.symmetric(h:12, v:6)
                                    │   └── Row(mainAxisAlignment: spaceBetween)
                                    │       ├── Text("Raou") // 브랜드 라벨
                                    │       ├── SizedBox(width: 16)
                                    │       ├── GestureDetector // 쿠팡
                                    │       │   └── Column
                                    │       │       ├── Icon(Icons.storefront_outlined)
                                    │       │       └── Text("쿠팡")
                                    │       ├── GestureDetector // 주문  
                                    │       │   └── Column
                                    │       │       ├── Icon(Icons.shopping_bag_outlined)
                                    │       │       └── Text("주문")
                                    │       ├── GestureDetector // 장바구니
                                    │       │   └── Stack
                                    │       │       ├── Column
                                    │       │       │   ├── Icon(Icons.shopping_cart_outlined)
                                    │       │       │   └── Text("장바구니")
                                    │       │       └── Positioned(right: -6, top: -6)
                                    │       │           └── Container // 빨간 뱃지
                                    │       │               └── Text("3") // 카운트
                                    │       └── Consumer<AuthViewModel>
                                    │           └── GestureDetector // 프로필
                                    │               └── [CircleAvatar OR Column]
                                    │                   ├── CircleAvatar(user.profileImageUrl) // 로그인 시
                                    │                   └── Column // 미로그인 시
                                    │                       ├── Icon(Icons.person_outline)
                                    │                       └── Text("로그인")
                                    └── [State Management Context]
                                        ├── AuthViewModel (사용자 상태)
                                        ├── CartViewModel (장바구니 카운트)
                                        ├── OrderViewModel (주문 관리)
                                        ├── ProductViewModel (상품 정보)
                                        └── AddressViewModel (주소 관리)
```

## 📐 레벨별 상세 분석

### 🔝 최상위 레벨 (App Level)

#### MaterialApp
- **역할**: Flutter 앱의 최상위 진입점
- **설정**:
  - `title: "Raou"`
  - `theme: Material3 + DeepPurple ColorScheme`
  - `useMaterial3: true`
- **파일**: `lib/main.dart`

#### MultiProvider (MaterialApp 상위)
- **역할**: MVVM 패턴의 상태 관리 제공
- **제공하는 ViewModel들**:
  - `AuthViewModel`: 사용자 인증 상태
  - `CartViewModel`: 장바구니 상태 및 아이템 카운트
  - `OrderViewModel`: 주문 관리
  - `ProductViewModel`: 상품 정보 처리
  - `AddressViewModel`: 배송 주소 관리

### 🏠 페이지 레벨 (Page Level)

#### MyHomePage
- **역할**: 메인 화면 위젯 (Stateful)
- **상태**: WebViewController 관리
- **파일**: `lib/views/home/home_page.dart`

#### SafeArea
- **역할**: 시스템 UI(상태바, 네비게이션바)와 충돌 방지
- **적용 범위**: 전체 화면
- **특징**: 원본 구조와 100% 일치

#### WillPopScope
- **역할**: 하드웨어 뒤로가기 버튼 처리
- **동작**: WebView 히스토리가 있으면 WebView 뒤로가기, 없으면 앱 종료
- **구현**: `controller.canGoBack()` 및 `controller.goBack()` 활용

### 🖼️ 레이아웃 레벨 (Layout Level)

#### Scaffold
- **역할**: Material Design 기본 화면 구조
- **배경**: 기본값 (흰색)
- **AppBar**: 없음 (전체화면 WebView 구현)

#### Stack
- **역할**: WebView와 네비게이션바를 레이어링
- **구성요소**: 
  - WebView (하단 레이어)
  - NavigationBar (상단 오버레이)

### 🌐 콘텐츠 레벨 (Content Level)

#### Positioned.fill + WebViewWidget
- **역할**: 전체화면 웹 브라우저
- **URL**: `https://www.coupang.com/`
- **설정**:
  - JavaScript 활성화
  - Chrome Mobile User-Agent
  - 흰색 배경
  - 외부 앱 리디렉션 차단
- **최적화**: 앱 배너 자동 숨김, 가격 정보 추출

#### Align + RaouNavigationBar
- **역할**: 하단 오버레이 네비게이션
- **위치**: `Alignment.bottomCenter`
- **투명도**: 90% (opacity 0.9)
- **파일**: `lib/widgets/raou_navigation_bar.dart`

### 🧭 네비게이션 레벨 (Navigation Level)

#### RaouNavigationBar 내부 구조
```
Container (배경 + 패딩)
└── Row (5개 네비게이션 아이템)
    ├── Text("Raou") // 브랜드
    ├── NavItem("쿠팡") // 쿠팡 페이지
    ├── NavItem("주문") // 주문 페이지  
    ├── CartWithBadge("장바구니") // 뱃지 카운트
    └── ProfileIcon // 로그인 상태별 표시
```

#### 네비게이션 아이템 상세
- **쿠팡**: `Icons.storefront_outlined` + "쿠팡"
- **주문**: `Icons.shopping_bag_outlined` + "주문"
- **장바구니**: `Icons.shopping_cart_outlined` + "장바구니" + 빨간 뱃지
- **프로필**: 로그인 시 `CircleAvatar`, 미로그인 시 `Icons.person_outline`

## 🔧 상태 관리 구조 (MVVM Pattern)

### Provider 계층
```
MultiProvider
├── ChangeNotifierProvider<AuthViewModel>
├── ChangeNotifierProvider<CartViewModel>
├── ChangeNotifierProvider<OrderViewModel>
├── ChangeNotifierProvider<ProductViewModel>
└── ChangeNotifierProvider<AddressViewModel>
```

### Consumer 사용 위치
- **CartViewModel**: RaouNavigationBar에서 장바구니 카운트 실시간 업데이트
- **AuthViewModel**: 프로필 아이콘에서 로그인 상태 표시

## 📱 화면 구성 및 동작

### 전체화면 레이아웃
```
┌─────────────────────────────────────┐ ← SafeArea 경계
│ ┌─────────────────────────────────┐ │
│ │                                 │ │
│ │        WebViewWidget            │ │ ← Positioned.fill
│ │      (쿠팡 모바일 사이트)        │ │   전체 화면 차지
│ │                                 │ │
│ │                                 │ │
│ │                                 │ │
│ │ ┌─────────────────────────────┐ │ │ ← Align(bottomCenter)
│ │ │    RaouNavigationBar        │ │ │   WebView 위에 오버레이
│ │ │ Raou [🏪] [📦] [🛒3] [👤] │ │ │ ← 높이 ~46px, 반투명
│ │ └─────────────────────────────┘ │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

### 네비게이션 동작
- **Home/Coupang**: WebView에서 쿠팡 사이트 로드
- **주문/장바구니/프로필**: Navigator.push로 새 페이지 이동
- **뒤로가기**: WebView 히스토리 우선, 없으면 앱 종료

## 🎯 설계 원칙

### 1. 원본 구조 100% 복원
- 위젯 트리 구조가 원본 [syrikx/raou](https://github.com/syrikx/raou)와 완전 일치
- SafeArea > WillPopScope > Scaffold > Stack 순서 유지
- 네비게이션바 오버레이 방식 동일

### 2. MVVM 패턴 적용
- View (위젯)와 Model (데이터) 분리
- ViewModel을 통한 비즈니스 로직 처리
- Provider 패턴으로 상태 관리

### 3. 반응형 UI
- Consumer를 통한 실시간 상태 업데이트
- 장바구니 카운트 자동 갱신
- 로그인 상태별 프로필 아이콘 변경

## 📁 관련 파일 구조

```
lib/
├── main.dart                          # MaterialApp + MultiProvider
├── views/home/home_page.dart          # MyHomePage 메인 화면
├── widgets/raou_navigation_bar.dart   # 하단 네비게이션바
├── viewmodels/                        # MVVM ViewModels
│   ├── auth_view_model.dart
│   ├── cart_view_model.dart
│   ├── order_view_model.dart
│   ├── product_view_model.dart
│   └── address_view_model.dart
├── views/                            # 각 페이지 View들
│   ├── auth/profile_page.dart
│   ├── cart/cart_page.dart
│   └── order/order_page.dart
└── models/                           # 데이터 모델들
    ├── user.dart
    ├── cart_item.dart
    └── order.dart
```

## 🔍 개발 참고사항

### WebView 설정
```dart
WebViewController()
  ..setJavaScriptMode(JavaScriptMode.unrestricted)
  ..setBackgroundColor(Colors.white)
  ..setUserAgent('Chrome Mobile User-Agent')
  ..setNavigationDelegate(/* 외부 앱 차단 */)
  ..loadRequest(Uri.parse('https://www.coupang.com/'))
```

### 네비게이션바 스타일
```dart
Container(
  color: Color(0xFF2C2C54).withOpacity(0.9),
  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  height: ~46px, // 아이콘(20px) + 텍스트(12px) + 패딩(14px)
)
```

### 상태 관리 사용법
```dart
// 장바구니 카운트 업데이트
Consumer<CartViewModel>(
  builder: (context, cartViewModel, child) {
    return Text('${cartViewModel.itemCount}');
  },
)

// 로그인 상태 확인
context.read<AuthViewModel>().currentUser
```

---

**문서 작성일**: 2025-07-22  
**앱 버전**: v1.0.6-perfect  
**Flutter 버전**: 3.29.3+  
**아키텍처**: MVVM Pattern with Provider  
**기반**: [syrikx/raou](https://github.com/syrikx/raou) 원본 구조 100% 복원