import 'dart:ui';
import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/main_navigation.dart';
import 'config/app_theme.dart';
import 'providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'config/env_config.dart';
import 'screens/global_error_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  EnvConfig.init();

  // Global Error Screen for rendering failures
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return GlobalErrorScreen(details: details);
  };

  // Global handler for asynchronous errors
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('UNCAUGHT ASYNC EXCEPTION: $error');
    debugPrint('STACKTRACE: $stack');
    return true;
  };

  runApp(const InvoiceApp());
}

class InvoiceApp extends StatelessWidget {
  const InvoiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Invoice App',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            initialRoute: '/',
            routes: {
              '/': (context) => const SplashScreen(),
              '/onboarding': (context) => const OnboardingScreen(),
              '/login': (context) => const LoginScreen(),
              '/signup': (context) => const SignupScreen(),
              '/dashboard': (context) => const MainNavigation(),
            },
          );
        },
      ),
    );
  }
}
