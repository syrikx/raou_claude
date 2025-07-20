# MVVM Flutter App

## 프로젝트 개요
iOS/Android/Chrome에서 실행 가능한 MVVM 아키텍처의 Flutter 애플리케이션

## 아키텍처
- **MVVM 패턴** 사용
- **Provider**를 통한 상태 관리
- **JSON 직렬화** 지원

## 폴더 구조
```
lib/
├── models/          # 데이터 모델 (User, ApiResponse)
├── viewmodels/      # 비즈니스 로직 (BaseViewModel, UserViewModel)
├── views/           # UI 화면 (HomePage)
├── services/        # API 서비스 (UserService)
└── utils/           # 유틸리티 (Constants)
```

## 주요 파일
- `lib/main.dart`: 앱 진입점, Provider 설정
- `lib/models/user.dart`: 사용자 모델
- `lib/viewmodels/user_view_model.dart`: 사용자 관련 비즈니스 로직
- `lib/views/home_page.dart`: 메인 화면
- `lib/services/user_service.dart`: API 통신

## 개발 명령어
- 의존성 설치: `flutter pub get`
- 코드 생성: `dart run build_runner build`
- 실행: `flutter run`
- iOS: `flutter run -d ios`
- Android: `flutter run -d android`
- Web: `flutter run -d chrome`

## 현재 구현된 기능
- 사용자 목록 조회
- 사용자 생성/수정/삭제 (UI만, API 연동 완료)
- 에러 처리 및 로딩 상태 관리
- Pull-to-refresh

## 추후 개발 예정
- 사용자 상세 페이지
- 사용자 추가/편집 폼
- 라우팅 설정
- 테마 관리
- 오프라인 지원

## 사용 중인 패키지
- provider: 상태 관리
- http: API 통신
- json_annotation: JSON 직렬화
- build_runner: 코드 생성