import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/user.dart';
import '../utils/app_config.dart';
import 'base_view_model.dart';

class AuthViewModel extends BaseViewModel {
  User? _currentUser;
  bool _isAuthenticated = false;
  
  // Google Sign-In 인스턴스 (단순화)
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;

  AuthViewModel() {
    _initializeAuth();
  }
  
  void _initializeAuth() async {
    try {
      if (AppConfig.isFirebaseEnabled) {
        _initializeFirebaseAuth();
      } else {
        // Firebase 비활성화 시 기본 상태
        _setupMockAuth();
      }
    } catch (e) {
      print('Auth 초기화 오류: $e');
      _setupMockAuth(); // 오류 시 기본 인증으로 대체
    }
  }

  void _initializeFirebaseAuth() {
    // Firebase가 활성화된 경우에만 실행
    if (!AppConfig.isFirebaseEnabled) return;
    
    // Firebase Auth 상태 변화 감지
    firebase_auth.FirebaseAuth.instance.authStateChanges().listen((firebase_auth.User? user) {
      if (user != null) {
        _currentUser = User(
          id: user.uid,
          email: user.email ?? '',
          name: user.displayName ?? 'Firebase User',
          profileImageUrl: user.photoURL,
          joinedAt: DateTime.now(),
        );
        _isAuthenticated = true;
      } else {
        _currentUser = null;
        _isAuthenticated = false;
      }
      notifyListeners();
    });
    
    print('Firebase Auth가 초기화되었습니다.');
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
      try {
        print('Google Sign-In 시작...');
        
        // Google Sign-In 시작 (간단하게)
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        print('Google Sign-In 결과: $googleUser');
        
        if (googleUser == null) {
          // 사용자가 취소한 경우
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Google 로그인이 취소되었습니다.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return false;
        }

        // 사용자 정보 생성
        _currentUser = User(
          id: googleUser.id,
          email: googleUser.email,
          name: googleUser.displayName ?? 'Google User',
          profileImageUrl: googleUser.photoUrl,
          joinedAt: DateTime.now(),
        );
        
        _isAuthenticated = true;
        notifyListeners();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_currentUser!.name}님, 환영합니다!'),
              backgroundColor: Colors.green,
            ),
          );
        }

        return true;
      } catch (error) {
        print('🔴 Google Sign-In 상세 오류: $error');
        print('🔴 오류 타입: ${error.runtimeType}');
        print('🔴 오류 문자열: ${error.toString()}');
        
        if (context.mounted) {
          String errorMessage = 'Google 로그인 중 오류가 발생했습니다.';
          
          // 다양한 오류 케이스 처리
          final errorString = error.toString().toLowerCase();
          if (errorString.contains('network_error') || errorString.contains('network')) {
            errorMessage = '네트워크 연결을 확인해주세요.';
          } else if (errorString.contains('sign_in_canceled') || errorString.contains('cancelled')) {
            errorMessage = 'Google 로그인이 취소되었습니다.';
          } else if (errorString.contains('sign_in_failed')) {
            errorMessage = 'Google 로그인에 실패했습니다. 다시 시도해주세요.';
          } else if (errorString.contains('invalid_client') || errorString.contains('oauth')) {
            errorMessage = 'Google 인증 설정 오류입니다. 개발자에게 문의하세요.';
          } else if (errorString.contains('permission') || errorString.contains('access')) {
            errorMessage = 'Google 계정 접근 권한이 없습니다.';
          }
          
          print('🔴 사용자 표시 메시지: $errorMessage');
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
        
        return false;
      }
    }) ?? false;
  }

  // Apple Sign-In
  Future<bool> signInWithApple(BuildContext context) async {
    if (!AppConfig.isAppleSignInEnabled) {
      _showFeatureDisabledMessage(context, 'Apple Sign-In');
      return false;
    }

    return await handleAsyncOperation(() async {
      try {
        // Apple Sign-In 가능 여부 확인
        final bool isAvailable = await SignInWithApple.isAvailable();
        if (!isAvailable) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Sign in with Apple이 이 기기에서 지원되지 않습니다. Mock 로그인을 사용합니다.'),
                backgroundColor: Colors.orange,
                action: SnackBarAction(
                  label: 'Mock 로그인',
                  onPressed: () => _signInWithMockApple(context),
                ),
              ),
            );
          }
          return false;
        }

        // Apple Sign-In 요청
        final credential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
        );

        // 사용자 정보 생성
        final String name = _formatAppleName(
          credential.givenName,
          credential.familyName,
        );
        
        _currentUser = User(
          id: credential.userIdentifier ?? DateTime.now().millisecondsSinceEpoch.toString(),
          email: credential.email ?? 'apple_user@private.com',
          name: name.isNotEmpty ? name : 'Apple User',
          joinedAt: DateTime.now(),
        );
        
        _isAuthenticated = true;
        notifyListeners();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_currentUser!.name}님, 환영합니다!'),
              backgroundColor: Colors.green,
            ),
          );
        }

        return true;
      } catch (error) {
        print('Apple Sign-In error: $error');
        
        if (context.mounted) {
          String errorMessage = 'Apple Sign-In 중 오류가 발생했습니다.';
          if (error.toString().contains('canceled')) {
            errorMessage = 'Apple Sign-In이 취소되었습니다.';
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
        
        return false;
      }
    }) ?? false;
  }

  // Apple 이름 포맷팅 헬퍼 메서드
  String _formatAppleName(String? givenName, String? familyName) {
    final given = givenName ?? '';
    final family = familyName ?? '';
    
    if (given.isEmpty && family.isEmpty) {
      return '';
    } else if (given.isEmpty) {
      return family;
    } else if (family.isEmpty) {
      return given;
    } else {
      return '$given $family';
    }
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
    await handleAsyncOperation(() async {
      try {
        // Google Sign-In 로그아웃
        if (AppConfig.isGoogleSignInEnabled) {
          await _googleSignIn.signOut();
        }
        
        // TODO: Firebase 로그아웃 추가
        // TODO: Apple Sign-In 로그아웃 추가 (필요시)
        
        _currentUser = null;
        _isAuthenticated = false;
        notifyListeners();
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('로그아웃되었습니다.'),
              backgroundColor: Colors.blue,
            ),
          );
        }
      } catch (error) {
        print('Sign out error: $error');
        
        // 에러가 발생해도 로컬 상태는 초기화
        _currentUser = null;
        _isAuthenticated = false;
        notifyListeners();
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('로그아웃되었습니다.'),
              backgroundColor: Colors.blue,
            ),
          );
        }
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

  // Mock Apple Sign-In (개발용)
  Future<void> _signInWithMockApple(BuildContext context) async {
    await handleAsyncOperation(() async {
      _currentUser = User(
        id: 'apple_mock_user_456',
        email: 'apple_user@privaterelay.appleid.com',
        name: 'Apple User',
        joinedAt: DateTime.now(),
      );
      _isAuthenticated = true;
      notifyListeners();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Apple Mock 사용자로 로그인되었습니다.'),
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