import 'package:flutter/material.dart';
import 'package:hemophilia_manager/routes/routes.dart';
import 'package:hemophilia_manager/screens/registration/authentication_landing_screen.dart';
import 'package:hemophilia_manager/screens/onboarding/onboarding_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hemophilia_manager/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hemophilia_manager/screens/main_screen/patient_screens/main_screen_hud.dart';
import 'package:hemophilia_manager/screens/main_screen/healthcare_provider_screen/healthcare_main_screen.dart';
import 'package:hemophilia_manager/services/openai_service.dart';
import 'package:hemophilia_manager/services/notification_service.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize OpenAI service
  try {
    await OpenAIService.initialize();
  } catch (e) {
    print('Warning: Failed to initialize OpenAI service: $e');
  }

  // Initialize Notification service
  try {
    await NotificationService().initialize();
    print('Notification service initialized successfully');
  } catch (e) {
    print('Warning: Failed to initialize Notification service: $e');
    // App can still function without notifications
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, _) {
        return MaterialApp(
          title: 'RedSyncPH',
          theme: ThemeData(
            fontFamily: 'Poppins',
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.redAccent,
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: Colors.white,
            cardColor: Colors.grey[50],
            dividerColor: Colors.grey[300],
          ),
          darkTheme: ThemeData(
            fontFamily: 'Poppins',
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.redAccent,
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: Colors.black,
            cardColor: Colors.grey[900],
            canvasColor: Colors.grey[900],
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.white, fontSize: 16),
              bodyMedium: TextStyle(color: Colors.white, fontSize: 14),
              bodySmall: TextStyle(color: Colors.white70, fontSize: 12),
              headlineLarge: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              headlineMedium: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              titleLarge: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              titleMedium: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              titleSmall: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              labelLarge: TextStyle(color: Colors.white),
              labelMedium: TextStyle(color: Colors.white),
              labelSmall: TextStyle(color: Colors.white70),
            ),
            iconTheme: const IconThemeData(color: Colors.white, size: 24),
            primaryIconTheme: const IconThemeData(color: Colors.redAccent),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              iconTheme: IconThemeData(color: Colors.white),
              actionsIconTheme: IconThemeData(color: Colors.white),
              titleTextStyle: TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: Colors.grey[900],
              selectedItemColor: Colors.redAccent,
              unselectedItemColor: Colors.grey[400],
              type: BottomNavigationBarType.fixed,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                elevation: 2,
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.grey[800],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[600]!),
              ),
              labelStyle: const TextStyle(color: Colors.white70),
              hintStyle: const TextStyle(color: Colors.grey),
            ),
            dividerTheme: DividerThemeData(
              color: Colors.grey[700],
              thickness: 1,
            ),
            dialogTheme: DialogThemeData(backgroundColor: Colors.grey[850]),
          ),
          themeMode: currentMode,
          debugShowCheckedModeBanner: false,
          home: AppInitializer(),
          routes: AppRoutes.routes,
        );
      },
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  _AppInitializerState createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Check onboarding status
      final prefs = await SharedPreferences.getInstance();
      final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;

      if (!onboardingComplete) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => OnboardingScreen()),
        );
        return;
      }

      // Check login status from secure storage
      final isLoggedIn = await _secureStorage.read(key: 'isLoggedIn');
      final userRole = await _secureStorage.read(key: 'userRole');

      if (isLoggedIn == 'true' && userRole != null && userRole.isNotEmpty) {
        // User is logged in, navigate to appropriate screen
        Widget targetScreen;
        switch (userRole) {
          case 'patient':
          case 'caregiver':
            targetScreen = MainScreenDisplay();
            break;
          case 'medical':
            targetScreen = HealthcareMainScreen();
            break;
          default:
            targetScreen = AuthenticationLandingScreen();
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => targetScreen),
        );
      } else {
        // User is not logged in, go to homepage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AuthenticationLandingScreen(),
          ),
        );
      }
    } catch (e) {
      // If any error occurs, default to homepage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AuthenticationLandingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'RedSyncPH',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(color: Colors.redAccent),
          ],
        ),
      ),
    );
  }
}
