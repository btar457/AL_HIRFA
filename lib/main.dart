import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'core/constants/strings.dart';
import 'core/navigation/role_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/order_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/splash_screen.dart';
import 'widgets/common/connectivity_banner.dart';

/// معالج إشعارات FCM أثناء تشغيل التطبيق في الخلفية أو إغلاقه.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: const AlHirfaApp(),
    ),
  );
}

class AlHirfaApp extends StatelessWidget {
  const AlHirfaApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const AuthGate(),
      builder: (context, child) => ConnectivityBanner(child: child!),
    );
  }
}

/// يستمع لحالة تسجيل الدخول عبر AuthProvider (المبني بدوره على
/// FirebaseAuth.instance.authStateChanges()) ويوجّه تلقائياً عند بدء
/// التطبيق: مسجّل دخوله → شاشته الرئيسية حسب دوره، غير مسجّل → LoginScreen.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});
  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _minimumSplashElapsed = false;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _minimumSplashElapsed = true);
    });
  }

  void _navigateIfReady(AuthProvider auth) {
    if (_hasNavigated) return;
    if (!_minimumSplashElapsed || auth.isInitializing || auth.isLoading) return;
    _hasNavigated = true;

    final user = auth.currentUser;
    if (user == null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    } else {
      navigateByRole(context, user.role, user: user);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _navigateIfReady(auth));
    return const SplashScreen();
  }
}
