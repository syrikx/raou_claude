import 'package:flutter/material.dart';
import '../models/user.dart';
import '../utils/app_config.dart';
import 'base_view_model.dart';

class AuthViewModel extends BaseViewModel {
  User? _currentUser;
  bool _isAuthenticated = false;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;

  AuthViewModel() {
    if (AppConfig.isFirebaseEnabled) {
      _initializeFirebaseAuth();
    } else {
      // Firebase 비활성화 시 기본 상태
      _setupMockAuth();
    }
  }

  void _initializeFirebaseAuth() {
    // Firebase가 활성화된 경우에만 실행
    if (!AppConfig.isFirebaseEnabled) return;
    
    // TODO: Firebase 초기화 코드
    // _checkAuthState();
    print('Firebase Auth가 활성화되었지만 패키지가 아직 설치되지 않았습니다.');
  }

  void _setupMockAuth() {
    // Firebase 비활성화 시 기본 사용자 상태
    print('Firebase Auth가 비활성화되었습니다. Mock auth 사용 중.');
  }

  // Google Sign-In
  Future<bool> signInWithGoogle(BuildContext context) async {
    if (!AppConfig.isGoogleSignInEnabled) {
      _showFeatureDisabledMessage(context, 'Google Sign-In');
      return false;
    }

    return await handleAsyncOperation(() async {
      // TODO: 실제 Google Sign-In 구현
      // Firebase 패키지가 활성화되면 이 부분을 구현
      _showComingSoonMessage(context, 'Google Sign-In');
      return false;
    }) ?? false;
  }

  // Apple Sign-In
  Future<bool> signInWithApple(BuildContext context) async {
    if (!AppConfig.isAppleSignInEnabled) {
      _showFeatureDisabledMessage(context, 'Apple Sign-In');
      return false;
    }

    return await handleAsyncOperation(() async {
      // TODO: 실제 Apple Sign-In 구현
      _showComingSoonMessage(context, 'Apple Sign-In');
      return false;
    }) ?? false;
  }

  // 이메일/비밀번호 로그인
  Future<bool> signInWithEmailAndPassword(
    String email, 
    String password, 
    BuildContext context
  ) async {
    if (!AppConfig.isFirebaseEnabled) {
      _showFeatureDisabledMessage(context, 'Email Sign-In');
      return false;
    }

    return await handleAsyncOperation(() async {
      // TODO: Firebase Auth 구현
      _showComingSoonMessage(context, 'Email Sign-In');
      return false;
    }) ?? false;
  }

  // 로그아웃
  Future<void> signOut(BuildContext context) async {
    if (!AppConfig.isFirebaseEnabled) {
      _showFeatureDisabledMessage(context, 'Sign Out');
      return;
    }

    await handleAsyncOperation(() async {
      // TODO: Firebase 로그아웃 구현
      _currentUser = null;
      _isAuthenticated = false;
      notifyListeners();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그아웃되었습니다.')),
        );
      }
    });
  }

  // Mock 로그인 (테스트용)
  Future<void> signInAsMockUser(BuildContext context) async {
    await handleAsyncOperation(() async {
      _currentUser = User(
        id: 'mock_user_123',
        email: 'test@example.com',
        name: 'Test User',
        joinedAt: DateTime.now(),
      );
      _isAuthenticated = true;
      notifyListeners();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('테스트 사용자로 로그인되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  void _showFeatureDisabledMessage(BuildContext context, String feature) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$feature 기능이 비활성화되어 있습니다.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _showComingSoonMessage(BuildContext context, String feature) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$feature 기능이 곧 제공될 예정입니다.'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  // Firebase 기능 활성화 상태 확인
  bool get isFirebaseAvailable => AppConfig.isFirebaseEnabled;
  bool get isGoogleSignInAvailable => AppConfig.isGoogleSignInEnabled;
  bool get isAppleSignInAvailable => AppConfig.isAppleSignInEnabled;
}