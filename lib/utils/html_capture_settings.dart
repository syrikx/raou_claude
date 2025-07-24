import 'package:shared_preferences/shared_preferences.dart';

// HTML 캡처 모드 열거형
enum CaptureMode {
  fullHtml('full_html', '전체 HTML', '모든 페이지 요소 포함 (용량 큼)'),
  productSections('product_sections', '핵심 정보만', '상품 정보만 추출 (80-90% 절약)');
  
  const CaptureMode(this.value, this.displayName, this.description);
  
  final String value;
  final String displayName;
  final String description;
  
  static CaptureMode fromString(String value) {
    return CaptureMode.values.firstWhere(
      (mode) => mode.value == value,
      orElse: () => CaptureMode.productSections, // 기본값
    );
  }
}

class HtmlCaptureSettings {
  static const String _htmlCaptureModeKey = 'html_capture_mode';
  
  // 현재 설정된 캡처 모드 가져오기
  static Future<CaptureMode> getCaptureMode() async {
    final prefs = await SharedPreferences.getInstance();
    final modeString = prefs.getString(_htmlCaptureModeKey);
    
    if (modeString == null) {
      // 기본값 설정 후 저장
      await setCaptureMode(CaptureMode.productSections);
      return CaptureMode.productSections;
    }
    
    return CaptureMode.fromString(modeString);
  }
  
  // 캡처 모드 설정
  static Future<void> setCaptureMode(CaptureMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_htmlCaptureModeKey, mode.value);
  }
  
  // 전체 HTML 모드인지 확인 (기존 코드 호환성)
  static Future<bool> isFullHtmlMode() async {
    final mode = await getCaptureMode();
    return mode == CaptureMode.fullHtml;
  }
  
  // 설정 초기화
  static Future<void> resetSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_htmlCaptureModeKey);
  }
  
  // 설정 정보 출력 (디버그용)
  static Future<void> printCurrentSettings() async {
    final mode = await getCaptureMode();
    print('🔧 HTML 캡처 모드: ${mode.displayName} (${mode.value})');
    print('📝 설명: ${mode.description}');
  }
}