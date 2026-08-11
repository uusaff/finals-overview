import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'screens/login_screen.dart';
import 'models/app_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase.initializeApp() will go here later
  
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: const FinalsOverviewApp(),
    ),
  );
}

class FinalsOverviewApp extends StatelessWidget {
  const FinalsOverviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, child) {
        return MaterialApp(
          title: 'Finals Overview',
          debugShowCheckedModeBanner: false,
          theme: NothingTheme.getTheme(isDark: false),
          darkTheme: NothingTheme.getTheme(isDark: true),
          themeMode: state.themeMode,
          home: const LoginScreen(),
        );
      },
    );
  }
}
