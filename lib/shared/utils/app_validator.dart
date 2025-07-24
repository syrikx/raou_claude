/// 앱 전체에서 사용할 입력 검증 유틸리티 클래스
class AppValidator {
  
  /// 이메일 형식 검증
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }
  
  /// 휴대폰 번호 검증 (한국 형식)
  static bool isValidKoreanPhone(String phone) {
    if (phone.isEmpty) return false;
    // 01X-XXXX-XXXX 또는 01XXXXXXXXX 형식
    final phoneRegex = RegExp(r'^01[0-9]-?[0-9]{3,4}-?[0-9]{4}$');
    return phoneRegex.hasMatch(phone);
  }
  
  /// URL 형식 검증
  static bool isValidUrl(String url) {
    if (url.isEmpty) return false;
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }
  
  /// 쿠팡 URL 검증
  static bool isCoupangUrl(String url) {
    if (!isValidUrl(url)) return false;
    try {
      final uri = Uri.parse(url);
      return uri.host.contains('coupang.com');
    } catch (e) {
      return false;
    }
  }
  
  /// 쿠팡 상품 페이지 URL 검증
  static bool isCoupangProductUrl(String url) {
    if (!isCoupangUrl(url)) return false;
    try {
      final uri = Uri.parse(url);
      return uri.path.contains('/vp/products/') || 
             uri.path.contains('/products/') ||
             uri.queryParameters.containsKey('itemId') ||
             uri.queryParameters.containsKey('vendorItemId');
    } catch (e) {
      return false;
    }
  }
  
  /// 비밀번호 강도 검증
  static PasswordStrength getPasswordStrength(String password) {
    if (password.isEmpty) return PasswordStrength.empty;
    if (password.length < 6) return PasswordStrength.weak;
    
    bool hasLower = password.contains(RegExp(r'[a-z]'));
    bool hasUpper = password.contains(RegExp(r'[A-Z]'));
    bool hasDigit = password.contains(RegExp(r'[0-9]'));
    bool hasSpecial = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    
    int strengthCount = 0;
    if (hasLower) strengthCount++;
    if (hasUpper) strengthCount++;
    if (hasDigit) strengthCount++;
    if (hasSpecial) strengthCount++;
    
    if (password.length >= 12 && strengthCount >= 3) return PasswordStrength.veryStrong;
    if (password.length >= 8 && strengthCount >= 3) return PasswordStrength.strong;
    if (password.length >= 6 && strengthCount >= 2) return PasswordStrength.medium;
    
    return PasswordStrength.weak;
  }
  
  /// 문자열이 비어있거나 공백만 있는지 검증
  static bool isEmpty(String? value) {
    return value == null || value.trim().isEmpty;
  }
  
  /// 문자열 길이 범위 검증
  static bool isLengthInRange(String value, int min, int max) {
    return value.length >= min && value.length <= max;
  }
  
  /// 숫자 형식 검증
  static bool isNumeric(String value) {
    if (value.isEmpty) return false;
    return double.tryParse(value) != null;
  }
  
  /// 정수 형식 검증
  static bool isInteger(String value) {
    if (value.isEmpty) return false;
    return int.tryParse(value) != null;
  }
  
  /// 가격 형식 검증 (양수)
  static bool isValidPrice(String value) {
    if (!isNumeric(value)) return false;
    final price = double.tryParse(value);
    return price != null && price > 0;
  }
  
  /// 한국어 포함 여부 검증
  static bool containsKorean(String value) {
    return RegExp(r'[ㄱ-ㅎ가-힣]').hasMatch(value);
  }
  
  /// 영어만 포함 여부 검증
  static bool isEnglishOnly(String value) {
    return RegExp(r'^[a-zA-Z\s]+$').hasMatch(value);
  }
  
  /// 파일 확장자 검증
  static bool hasValidExtension(String fileName, List<String> allowedExtensions) {
    if (fileName.isEmpty) return false;
    final extension = fileName.split('.').last.toLowerCase();
    return allowedExtensions.contains(extension);
  }
  
  /// HTML 파일 검증
  static bool isHtmlFile(String fileName) {
    return hasValidExtension(fileName, ['html', 'htm']);
  }
  
  /// 이미지 파일 검증
  static bool isImageFile(String fileName) {
    return hasValidExtension(fileName, ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp']);
  }
  
  /// Form 검증을 위한 헬퍼 메서드들
  static String? validateRequired(String? value, [String fieldName = '필수 항목']) {
    if (isEmpty(value)) {
      return '$fieldName을(를) 입력해주세요.';
    }
    return null;
  }
  
  static String? validateEmail(String? value) {
    if (isEmpty(value)) {
      return '이메일을 입력해주세요.';
    }
    if (!isValidEmail(value!)) {
      return '올바른 이메일 형식을 입력해주세요.';
    }
    return null;
  }
  
  static String? validatePassword(String? value) {
    if (isEmpty(value)) {
      return '비밀번호를 입력해주세요.';
    }
    final strength = getPasswordStrength(value!);
    if (strength == PasswordStrength.weak || strength == PasswordStrength.empty) {
      return '비밀번호는 최소 6자 이상이어야 합니다.';
    }
    return null;
  }
  
  static String? validatePhone(String? value) {
    if (isEmpty(value)) {
      return '휴대폰 번호를 입력해주세요.';
    }
    if (!isValidKoreanPhone(value!)) {
      return '올바른 휴대폰 번호를 입력해주세요. (예: 010-1234-5678)';
    }
    return null;
  }
  
  static String? validateUrl(String? value) {
    if (isEmpty(value)) {
      return 'URL을 입력해주세요.';
    }
    if (!isValidUrl(value!)) {
      return '올바른 URL을 입력해주세요.';
    }
    return null;
  }
}

/// 비밀번호 강도 열거형
enum PasswordStrength {
  empty,
  weak,
  medium,
  strong,
  veryStrong;
  
  String get displayName {
    switch (this) {
      case PasswordStrength.empty:
        return '없음';
      case PasswordStrength.weak:
        return '약함';
      case PasswordStrength.medium:
        return '보통';
      case PasswordStrength.strong:
        return '강함';
      case PasswordStrength.veryStrong:
        return '매우 강함';
    }
  }
  
  /// 비밀번호 강도에 따른 색상
  String get colorHex {
    switch (this) {
      case PasswordStrength.empty:
        return '#9E9E9E'; // Gray
      case PasswordStrength.weak:
        return '#F44336'; // Red
      case PasswordStrength.medium:
        return '#FF9800'; // Orange
      case PasswordStrength.strong:
        return '#4CAF50'; // Green  
      case PasswordStrength.veryStrong:
        return '#2196F3'; // Blue
    }
  }
}