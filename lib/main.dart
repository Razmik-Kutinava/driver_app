import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sentry_flutter/sentry_flutter.dart';

import 'config/supabase_config.dart';
import 'services/auth_service.dart';
import 'services/location_service.dart';
import 'services/order_service.dart';
import 'services/notification_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main/main_screen.dart';
import 'screens/map/map_screen.dart';
import 'screens/scanner/scanner_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Sentry DSN - замените на реальный ключ для production
  const sentryDsn = String.fromEnvironment(
    'SENTRY_DSN',
    defaultValue: '',
  );

  // Инициализация Sentry только если DSN настроен
  if (sentryDsn.isNotEmpty && sentryDsn.startsWith('https://')) {
    await SentryFlutter.init(
      (options) {
        options.dsn = sentryDsn;
        options.tracesSampleRate = 1.0;
        options.environment = SupabaseConfig.isDebug ? 'development' : 'production';
        options.debug = SupabaseConfig.isDebug;
      },
      appRunner: () async {
        await _initializeApp();
      },
    );
  } else {
    // Запуск без Sentry для разработки
    debugPrint('⚠️ Sentry не инициализирован (DSN не настроен)');
    await _initializeApp();
  }
}

Future<void> _initializeApp() async {
  // Инициализация Supabase
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  // Запрос разрешений (только для мобильных платформ)
  if (!kIsWeb) {
    await _requestPermissions();
  }

  runApp(const LogisticDriverApp());
}

Future<void> _requestPermissions() async {
  // Разрешения не нужны для веб-платформы
  debugPrint('Permissions requested (web platform - no action needed)');
}

class LogisticDriverApp extends StatelessWidget {
  const LogisticDriverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => LocationService()),
        ChangeNotifierProvider(create: (_) => OrderService()),
        ChangeNotifierProvider(
          create: (_) => NotificationService()..initialize(),
        ),
      ],
      child: Consumer<AuthService>(
        builder: (context, authService, _) {
          return MaterialApp.router(
            title: SupabaseConfig.appName,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            routerConfig: _createRouter(authService),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }

  GoRouter _createRouter(AuthService authService) {
    return GoRouter(
      initialLocation: '/login',
      redirect: (context, state) {
        final isLoggedIn = authService.isLoggedIn;
        final isLoggingIn = state.matchedLocation == '/login';

        if (!isLoggedIn && !isLoggingIn) {
          return '/login';
        }
        if (isLoggedIn && isLoggingIn) {
          return '/main';
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/main',
          builder: (context, state) => const MainScreen(),
        ),
        GoRoute(
          path: '/map',
          builder: (context, state) => const MapScreen(),
        ),
        GoRoute(
          path: '/scanner',
          builder: (context, state) => const ScannerScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    );
  }
}
