import 'package:authentication_firebase/features/user_auth/presentation/pages/dashboard.dart';
import 'package:authentication_firebase/features/user_auth/presentation/pages/income_and_expense.dart';
import 'package:authentication_firebase/features/user_auth/presentation/pages/profile.dart';
import 'package:authentication_firebase/features/user_auth/presentation/pages/report_and_analysis.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:authentication_firebase/features/app/splash_screen/splash_screen.dart';
import 'package:authentication_firebase/features/user_auth/presentation/pages/budgeting.dart';
import 'package:authentication_firebase/features/user_auth/presentation/pages/home_page.dart';
import 'package:authentication_firebase/features/user_auth/presentation/pages/login_page.dart';
import 'package:authentication_firebase/features/user_auth/presentation/pages/sign_up_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  dotenv.load(fileName: ".env");

  // Initialize Firebase for Web and other platforms
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: dotenv.env['FIREBASE_API_KEY'] ?? '',
        appId: dotenv.env['FIREBASE_APP_ID'] ?? '',
        messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '',
        projectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? '',
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(child: LoginPage()), // Splash and navigate to login
        '/login': (context) => LoginPage(),
        '/signUp': (context) => SignUpPage(),
        '/home': (context) => HomeScreen(),
        '/income_expenses': (context) => IncomeExpenseScreen(),
        '/report_analysis': (context) => ReportAnalysisScreen(),
        '/dashboard': (context) => DashboardScreen(),
        '/profile': (context) => SettingsPage(),// Profile page
        '/budgeting' : (context) => BudgetingPage(),
      },
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.transparent, // Remove default solid background
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFFE0F2F1), // Soft mint green
          elevation: 0, // Optional: Remove shadow under the AppBar
        ),
      ),
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFE0F2F1),
                Color(0xFFFFF9C4), // Custom pastel yellow color
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: child,
        );
      },
    );
  }
}
