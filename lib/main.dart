import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'utils/app_config.dart';
import 'viewmodels/auth_view_model.dart';
import 'viewmodels/cart_view_model.dart';
import 'viewmodels/address_view_model.dart';
import 'viewmodels/order_view_model.dart';
import 'viewmodels/product_view_model.dart';
import 'views/home/home_page.dart';

void main() async {
  print('🚀 앱 시작 - main() 호출됨');
  
  try {
    print('📱 WidgetsFlutterBinding 초기화 중...');
    WidgetsFlutterBinding.ensureInitialized();
    print('✅ WidgetsFlutterBinding 초기화 완료');
    
    // 앱 설정 정보 출력 (디버그용)
    print('⚙️ 앱 설정 확인 중...');
    AppConfig.printConfig();
    print('✅ 앱 설정 확인 완료');
    
    // Firebase 초기화 (활성화된 경우에만)
    print('🔥 Firebase 초기화 시작...');
    try {
      if (AppConfig.isFirebaseEnabled) {
        print('🔥 Firebase 초기화 진행 중...');
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        print('✅ Firebase 초기화 성공!');
      } else {
        print('⚠️ Firebase가 비활성화됨');
      }
    } catch (e, stackTrace) {
      print('❌ Firebase 초기화 실패: $e');
      print('스택 트레이스: $stackTrace');
      print('⚠️ 기본 모드로 계속 진행합니다.');
    }
    
    print('🏗️ RaouApp 위젯 생성 중...');
    runApp(const RaouApp());
    print('✅ 앱 시작 완료!');
    
  } catch (e, stackTrace) {
    print('💥 main() 함수에서 치명적 오류 발생: $e');
    print('스택 트레이스: $stackTrace');
    
    // 최소한의 앱이라도 실행하려고 시도
    try {
      runApp(MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('앱 초기화 오류: $e'),
          ),
        ),
      ));
    } catch (finalError) {
      print('💀 완전한 앱 실행 실패: $finalError');
    }
  }
}

class RaouApp extends StatelessWidget {
  const RaouApp({super.key});

  @override
  Widget build(BuildContext context) {
    print('🏗️ RaouApp.build() 호출됨');
    
    try {
      print('🔧 Provider 생성 중...');
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) {
            print('👤 AuthViewModel 생성 중...');
            try {
              final authVM = AuthViewModel();
              print('✅ AuthViewModel 생성 성공');
              return authVM;
            } catch (e) {
              print('❌ AuthViewModel 생성 실패: $e');
              rethrow;
            }
          }),
          ChangeNotifierProvider(create: (_) {
            print('🛒 CartViewModel 생성 중...');
            try {
              final cartVM = CartViewModel();
              print('✅ CartViewModel 생성 성공');
              return cartVM;
            } catch (e) {
              print('❌ CartViewModel 생성 실패: $e');
              rethrow;
            }
          }),
          ChangeNotifierProvider(create: (_) {
            print('📍 AddressViewModel 생성 중...');
            try {
              final addressVM = AddressViewModel();
              print('✅ AddressViewModel 생성 성공');
              return addressVM;
            } catch (e) {
              print('❌ AddressViewModel 생성 실패: $e');
              rethrow;
            }
          }),
          ChangeNotifierProvider(create: (_) {
            print('📦 OrderViewModel 생성 중...');
            try {
              final orderVM = OrderViewModel();
              print('✅ OrderViewModel 생성 성공');
              return orderVM;
            } catch (e) {
              print('❌ OrderViewModel 생성 실패: $e');
              rethrow;
            }
          }),
          ChangeNotifierProvider(create: (_) {
            print('🛍️ ProductViewModel 생성 중...');
            try {
              final productVM = ProductViewModel();
              print('✅ ProductViewModel 생성 성공');
              return productVM;
            } catch (e) {
              print('❌ ProductViewModel 생성 실패: $e');
              rethrow;
            }
          }),
        ],
        child: MaterialApp(
          title: 'Raou',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: Builder(
            builder: (context) {
              print('🏠 HomePage 생성 중...');
              try {
                return const MyHomePage();
              } catch (e) {
                print('❌ HomePage 생성 실패: $e');
                return Scaffold(
                  body: Center(
                    child: Text('홈페이지 로드 오류: $e'),
                  ),
                );
              }
            },
          ),
          debugShowCheckedModeBanner: false,
        ),
      );
    } catch (e, stackTrace) {
      print('💥 RaouApp.build() 오류: $e');
      print('스택 트레이스: $stackTrace');
      
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('앱 빌드 오류'),
                const SizedBox(height: 8),
                Text('$e', style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ),
      );
    }
  }
}