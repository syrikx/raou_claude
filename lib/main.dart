import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:firebase_core/firebase_core.dart'; // Temporarily disabled
// import 'firebase_options.dart'; // Temporarily disabled
import 'utils/app_config.dart';
import 'viewmodels/auth_view_model.dart';
import 'viewmodels/cart_view_model.dart';
import 'viewmodels/address_view_model.dart';
import 'viewmodels/order_view_model.dart';
import 'viewmodels/product_view_model.dart';
import 'views/home/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 앱 설정 정보 출력 (디버그용)
  AppConfig.printConfig();
  
  // Firebase 초기화 (활성화된 경우에만)
  if (AppConfig.isFirebaseEnabled) {
    // TODO: Firebase 패키지가 활성화되면 초기화 코드 추가
    // await Firebase.initializeApp(
    //   options: DefaultFirebaseOptions.currentPlatform,
    // );
    print('Firebase 초기화가 예정되어 있지만 패키지가 아직 설치되지 않았습니다.');
  }
  
  runApp(const RaouApp());
}

class RaouApp extends StatelessWidget {
  const RaouApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => CartViewModel()),
        ChangeNotifierProvider(create: (_) => AddressViewModel()),
        ChangeNotifierProvider(create: (_) => OrderViewModel()),
        ChangeNotifierProvider(create: (_) => ProductViewModel()),
      ],
      child: MaterialApp(
        title: 'Raou',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const HomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}