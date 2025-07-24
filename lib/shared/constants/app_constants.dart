/// 앱 전체에서 사용하는 상수들을 관리하는 클래스
class AppConstants {
  
  // ==================== 앱 정보 ====================
  static const String appName = 'Raou';
  static const String appVersion = '1.3.0';
  static const String bundleId = 'com.raou.claude.app';
  
  // ==================== 서버 정보 ====================
  static const String baseUrl = 'https://gunsiya.com';
  static const String serverPath = '/raou';
  static const String apiUrl = '$baseUrl$serverPath';
  
  // API 엔드포인트
  static const String postCoupangEndpoint = '$apiUrl/post_coupang';
  static const String listEndpoint = '$apiUrl/list';
  static const String searchEndpoint = '$apiUrl/search';
  static const String viewEndpoint = '$apiUrl/view';
  static const String healthEndpoint = '$apiUrl/health';
  
  // ==================== UI 관련 상수 ====================
  // 공통 패딩
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  
  // 공통 반지름
  static const double radiusS = 4.0;
  static const double radiusM = 8.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  
  // 아이콘 크기
  static const double iconS = 16.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;
  
  // 폰트 크기
  static const double fontXS = 10.0;
  static const double fontS = 12.0;
  static const double fontM = 14.0;
  static const double fontL = 16.0;
  static const double fontXL = 18.0;
  static const double fontXXL = 20.0;
  static const double fontTitle = 24.0;
  static const double fontHeader = 28.0;
  
  // ==================== 애니메이션 ====================
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  
  // ==================== 네트워크 ====================
  static const Duration networkTimeout = Duration(seconds: 30);
  static const Duration shortTimeout = Duration(seconds: 10);
  static const int maxRetryCount = 3;
  
  // HTTP 관련
  static const int httpOk = 200;
  static const int httpCreated = 201;
  static const int httpBadRequest = 400;
  static const int httpUnauthorized = 401;
  static const int httpForbidden = 403;
  static const int httpNotFound = 404;
  static const int httpInternalServerError = 500;
  
  // ==================== 쿠팡 관련 ====================
  static const String coupangBaseUrl = 'https://www.coupang.com';
  static const String coupangDomain = 'coupang.com';
  
  // HTML 캡처 관련
  static const String captureModeFull = 'full_html';
  static const String captureModeProduct = 'product_sections';
  static const int maxHtmlSize = 10 * 1024 * 1024; // 10MB
  
  // ==================== 로컬 저장소 키 ====================
  static const String htmlCaptureModeKey = 'html_capture_mode';
  static const String userPreferencesKey = 'user_preferences';
  static const String lastSyncTimeKey = 'last_sync_time';
  static const String appThemeKey = 'app_theme';
  
  // ==================== 메시지 ====================
  // 성공 메시지
  static const String msgHtmlCaptureSuccess = 'HTML 캡처가 성공적으로 저장되었습니다!';
  static const String msgSettingsSaved = '설정이 저장되었습니다.';
  static const String msgSignInSuccess = '로그인에 성공했습니다.';
  static const String msgSignOutSuccess = '로그아웃되었습니다.';
  
  // 오류 메시지
  static const String msgNetworkError = '네트워크 연결을 확인해주세요.';
  static const String msgServerError = '서버 오류가 발생했습니다.';
  static const String msgUnknownError = '알 수 없는 오류가 발생했습니다.';
  static const String msgInvalidUrl = '올바른 URL을 입력해주세요.';
  static const String msgCaptureError = 'HTML 캡처 중 오류가 발생했습니다.';
  static const String msgSettingsError = '설정 저장에 실패했습니다.';
  static const String msgSignInError = '로그인에 실패했습니다.';
  
  // 확인 메시지
  static const String msgSignOutConfirm = '정말 로그아웃하시겠습니까?';
  static const String msgDeleteConfirm = '정말 삭제하시겠습니까?';
  static const String msgClearDataConfirm = '모든 데이터를 삭제하시겠습니까?';
  
  // 일반 메시지
  static const String msgComingSoon = 'Coming soon!';
  static const String msgLoading = '로딩 중...';
  static const String msgNoData = '데이터가 없습니다.';
  static const String msgTryAgain = '다시 시도해주세요.';
  
  // ==================== 정규식 패턴 ====================
  static const String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String phonePattern = r'^01[0-9]-?[0-9]{3,4}-?[0-9]{4}$';
  static const String urlPattern = r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$';
  
  // ==================== 파일 관련 ====================
  static const List<String> imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'];
  static const List<String> htmlExtensions = ['html', 'htm'];
  static const int maxFileSize = 50 * 1024 * 1024; // 50MB
  
  // ==================== 디버그 설정 ====================
  static const bool enableDetailedLogging = true;
  static const bool enablePerformanceLogging = true;
  static const bool enableNetworkLogging = true;
  
  // ==================== 기타 ====================
  static const String dateFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String dateFormatShort = 'MM/dd HH:mm';
  static const String timeFormat = 'HH:mm:ss';
  
  // 페이지네이션
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // 캐시 관련
  static const Duration cacheExpiration = Duration(hours: 1);
  static const int maxCacheSize = 100;
}