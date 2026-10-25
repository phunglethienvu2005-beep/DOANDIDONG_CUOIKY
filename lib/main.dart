import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF131629),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0E21),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6C63FF),
          secondary: Color(0xFF00E5A0),
          surface: Color(0xFF131629),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white70),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A0E21),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
          iconTheme: IconThemeData(color: Colors.white),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF131629),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.06),
              width: 1,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF131629),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: Colors.white.withOpacity(0.08),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFF6C63FF),
              width: 1.5,
            ),
          ),
          labelStyle: const TextStyle(color: Colors.white54),
          hintStyle: const TextStyle(color: Colors.white30),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6C63FF),
            foregroundColor: Colors.white,
            padding:
                const EdgeInsets.symmetric(vertical: 15, horizontal: 32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Color(0xFF1D2036),
          contentTextStyle: TextStyle(color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
