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
import 'package:hemophilia_manager/models/online/chat_message.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

// Global conversation state that persists across screens
class GlobalConversationState {
  static final GlobalConversationState _instance =
      GlobalConversationState._internal();
  factory GlobalConversationState() => _instance;
  GlobalConversationState._internal();

  final List<ChatMessage> _messages = [];
  final ValueNotifier<List<ChatMessage>> messagesNotifier = ValueNotifier([]);

  List<ChatMessage> get messages => List.unmodifiable(_messages);

  void addMessage(ChatMessage message) {
    _messages.add(message);
    messagesNotifier.value = List.from(_messages);
  }

  void clearMessages() {
    _messages.clear();
    messagesNotifier.value = [];
  }

  void initializeWithWelcomeMessage() {
    if (_messages.isEmpty) {
      addMessage(
        ChatMessage(
          text:
              "Hello! I'm HemoAssist, your AI companion for hemophilia care and management. I'm here to help you with information about hemophilia, its symptoms, treatments, and lifestyle recommendations. How can I assist you today?",
          isUser: false,
        ),
      );
    }
  }
}

// Function to save theme preference
Future<void> saveThemeMode(ThemeMode themeMode) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('theme_mode', themeMode.name);
}

// Function to load theme preference
Future<ThemeMode> loadThemeMode() async {
  final prefs = await SharedPreferences.getInstance();
  final themeName = prefs.getString('theme_mode');
  if (themeName == 'dark') {
    return ThemeMode.dark;
  } else if (themeName == 'light') {
    return ThemeMode.light;
  } else {
    return ThemeMode.system;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Load saved theme preference
  final savedTheme = await loadThemeMode();
  themeNotifier.value = savedTheme;

  // Initialize global conversation state
  GlobalConversationState().initializeWithWelcomeMessage();

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
    // Don't rethrow to prevent app startup crash
  }

  runApp(MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Set up notification tap handling
    NotificationService.setNavigationCallback(_handleNotificationTap);
  }

  void _handleNotificationTap(String payload) {
    print('Handling notification tap with payload: $payload');

    // Parse payload and navigate accordingly
    try {
      if (payload.startsWith('post_')) {
        // Handle post notifications (like, comment, share)
        final parts = payload.split(':');
        if (parts.length >= 2) {
          final postId = parts[1];
          _navigateToPost(postId);
        }
      } else if (payload.startsWith('message:')) {
        // Handle message notifications
        final parts = payload.split(':');
        if (parts.length >= 3) {
          final senderId = parts[1];
          final conversationId = parts[2];
          _navigateToMessage(senderId, conversationId);
        }
      } else if (payload.startsWith('medication_reminder:')) {
        // Handle medication reminder notifications
        final parts = payload.split(':');
        if (parts.length >= 2) {
          final scheduleId = parts[1];
          _navigateToMedication(scheduleId);
        }
      }
    } catch (e) {
      print('Error parsing notification payload: $e');
    }
  }

  void _navigateToPost(String postId) {
    print('Navigating to post: $postId');

    // Navigate to community screen with specific post
    navigatorKey.currentState?.pushNamed(
      '/community',
      arguments: {'openPostId': postId},
    );
  }

  void _navigateToMessage(String senderId, String conversationId) {
    print('Navigating to message: $senderId, $conversationId');

    // Navigate to messages screen with specific conversation
    navigatorKey.currentState?.pushNamed(
      '/messages',
      arguments: {
        'openChatWithUserId': senderId,
        'conversationId': conversationId,
      },
    );
  }

  void _navigateToMedication(String scheduleId) {
    print('Navigating to medication: $scheduleId');

    // Navigate to medication/dashboard screen
    navigatorKey.currentState?.pushNamed(
      '/medication',
      arguments: {'scheduleId': scheduleId},
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, _) {
        return MaterialApp(
          navigatorKey: navigatorKey,
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

      if (!mounted) return;

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

      if (!mounted) return;

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
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AuthenticationLandingScreen(),
          ),
        );
      }
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
