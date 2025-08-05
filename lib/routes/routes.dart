import 'package:flutter/material.dart';
import 'package:hemophilia_manager/screens/main_screen/healthcare_provider_screen/my_patients_screen.dart';
import 'package:hemophilia_manager/screens/main_screen/patient_screens/chatbot_screen.dart';
import 'package:hemophilia_manager/screens/main_screen/patient_screens/community_screen.dart';
import 'package:hemophilia_manager/screens/main_screen/patient_screens/ps_screen/pre_screening.dart';
import 'package:hemophilia_manager/screens/registration/authentication_landing_screen.dart';
import 'package:hemophilia_manager/screens/main_screen/healthcare_provider_screen/healthcare_main_screen.dart';
import 'package:hemophilia_manager/screens/main_screen/patient_screens/care_provider_screen.dart';
import 'package:hemophilia_manager/screens/main_screen/patient_screens/care_user_information_screen.dart';
import 'package:hemophilia_manager/screens/main_screen/patient_screens/dosage_calculator_screen.dart';
import 'package:hemophilia_manager/screens/main_screen/patient_screens/log_bleed.dart';
import 'package:hemophilia_manager/screens/main_screen/patient_screens/log_history_screen.dart';
import 'package:hemophilia_manager/screens/main_screen/patient_screens/log_infusion.dart';
import 'package:hemophilia_manager/screens/main_screen/patient_screens/main_screen_hud.dart';
import 'package:hemophilia_manager/screens/main_screen/patient_screens/notifications_screen.dart';
import 'package:hemophilia_manager/screens/main_screen/patient_screens/schedule_medication_screen.dart';
import 'package:hemophilia_manager/screens/main_screen/patient_screens/settings_screens/main_settings.dart';
import 'package:hemophilia_manager/screens/main_screen/patient_screens/settings_screens/user_info_settings.dart';
import 'package:hemophilia_manager/screens/main_screen/patient_screens/settings_screens/caregiver_info_settings.dart';
import 'package:hemophilia_manager/screens/main_screen/patient_screens/settings_screens/medical_info_settings.dart';
import 'package:hemophilia_manager/screens/main_screen/patient_screens/settings_screens/change_password_screen.dart';
import 'package:hemophilia_manager/screens/main_screen/patient_screens/messages_screen.dart';
import 'package:hemophilia_manager/screens/onboarding/onboarding_screen.dart';
import 'package:hemophilia_manager/screens/registration/create_acc_page.dart';
import 'package:hemophilia_manager/screens/registration/forgot_password.dart';
import 'package:hemophilia_manager/screens/registration/login_page.dart';
import 'package:hemophilia_manager/screens/role_selection/choose_role_selection.dart';
import 'package:hemophilia_manager/screens/role_selection/user_creation_success.dart';
import 'package:hemophilia_manager/screens/role_selection/user_details.dart';

// Routes are grouped by user roles for better maintainability.

class AppRoutes {
  // Common Routes (Accessible by all roles)
  static const String onboarding = '/onboarding';
  static const String authenticationScreen = '/authentication';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot_password';

  // Role Selection & User Creation
  static const String roleSelection = '/role_selection';
  static const String userFillup = '/user_fillup';
  static const String userAccountCreated = '/user_account_created';

  // Patient Routes
  static const String userScreen = '/user_screen';
  static const String settings = '/settings';
  static const String notifications = '/notifications';
  static const String doseCalculator = '/dose_calculator';
  static const String logBleed = '/log_bleed';
  static const String scheduleMedication = '/schedule_medication';
  static const String logHistoryScreen = '/log_history';
  static const String careProviderScreen = '/care_provider';
  static const String careUserInformationScreen = '/care_user_information';
  static const String logInfusion = '/log_infusion';
  static const String chatbotScreen = '/chatbot';
  static const String preScreening = '/pre_screening';
  static const String messages = '/messages';
  static const String community = '/community';

  // Patient Settings Subroutes
  static const String userInfoSettings = '/user_info_settings';
  static const String caregiverInfoSettings = '/caregiver_info_settings';
  static const String medicalInfoSettings = '/medical_info_settings';
  static const String changePassword = '/change_password';

  // Healthcare Provider Routes
  static const String healthcareMainScreen = '/healthcare_main';
  static const String myPatientsScreen = '/my_patients';

  static Map<String, WidgetBuilder> routes = {
    // Common Routes
    onboarding: (context) => const OnboardingScreen(),
    authenticationScreen: (context) => const AuthenticationLandingScreen(),
    login: (context) => const LoginPage(),
    register: (context) => const CreateAccPage(),
    forgotPassword: (context) => const ForgotPassword(),

    // Role Selection & User Creation
    roleSelection: (context) => const ChooseRoleSelection(),
    userFillup: (context) => const UserDetails(),
    userAccountCreated: (context) => const UserCreationSuccess(),

    // Patient Routes
    userScreen: (context) => const MainScreenDisplay(),
    settings: (context) => const UserSettings(),
    notifications: (context) => const NotificationsScreen(),
    doseCalculator: (context) => const DosageCalculatorScreen(),
    logBleed: (context) => const LogBleed(),
    scheduleMedication: (context) => const ScheduleMedicationScreen(),
    logHistoryScreen: (context) => const LogHistoryScreen(),
    careProviderScreen: (context) => const CareProviderScreen(),
    careUserInformationScreen: (context) => const CareUserInformationScreen(),
    logInfusion: (context) => const LogInfusionScreen(),
    chatbotScreen: (context) => const ChatbotScreen(),
    preScreening: (context) => const PreScreeningScreen(),
    messages: (context) => const MessagesScreen(),
    community: (context) => const CommunityScreen(),

    // Patient Settings Subroutes
    userInfoSettings: (context) => const UserInfoSettings(),
    caregiverInfoSettings: (context) => const CaregiverInfoSettings(),
    medicalInfoSettings: (context) => const MedicalInfoSettings(),
    changePassword: (context) => const ChangePasswordScreen(),

    // Healthcare Provider Routes
    healthcareMainScreen: (context) => const HealthcareMainScreen(),
    myPatientsScreen: (context) => const MyPatientsScreen(),
  };
}
