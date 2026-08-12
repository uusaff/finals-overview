import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'screens/login_screen.dart';
import 'models/app_state.dart';
import 'services/auth_service.dart';
import 'services/coupon_service.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await CouponService().initializeDefaultCoupon();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: const FinalsOverviewApp(),
    ),
  );
}

class FinalsOverviewApp extends StatelessWidget {
  const FinalsOverviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return MaterialApp(
          title: 'Finals Overview',
          debugShowCheckedModeBanner: false,
          themeMode: appState.themeMode,
          theme: NothingTheme.getTheme(
            isDark: false,
            accent: appState.accentColor,
            customBackground: appState.customBackgroundColor,
          ),
          darkTheme: NothingTheme.getTheme(
            isDark: true,
            accent: appState.accentColor,
            customBackground: appState.customBackgroundColor,
          ),
          home: const LoginScreen(),
        );
      },
    );
  }
}
