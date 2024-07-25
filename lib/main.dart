import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:project/views/home_screen.dart';
import 'package:project/views/login_screen.dart';
import 'package:project/views/profile_screen.dart';
import 'package:project/views/signup_screen.dart';
import 'package:project/views/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "MyApp",
      debugShowCheckedModeBanner: false,
      // restorationScopeId: "root",
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
        textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white)),
        appBarTheme: const AppBarTheme(
          foregroundColor: Colors.white,
          backgroundColor: Colors.black,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/profile') {
          final Map<String, String?> user =
              settings.arguments as Map<String, String?>;
          return MaterialPageRoute(
            builder: (context) {
              return ProfileScreen(user: user);
            },
          );
        }
        assert(false, 'Need to implement ${settings.name}');
        return null;
      },
    );
  }
}
