import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'utils/app_theme.dart';
import 'services/auth_provider.dart';
import 'screens/auth/auth_screens.dart';
import 'screens/user/user_screens.dart';
import 'screens/admin/admin_screens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const SupSalleApp(),
    ),
  );
}

class SupSalleApp extends StatelessWidget {
  const SupSalleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SupSalle',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: '/splash',
      routes: {
        '/splash':          (_) => const SplashScreen(),
        '/login':           (_) => const LoginScreen(),
        '/register':        (_) => const RegisterScreen(),
        '/home':            (_) => const UserHomeScreen(),
        '/reserver':        (_) => const NouvelleReservationScreen(),
        '/mes-reservations':(_) => const MesReservationsScreen(),
        '/notifications':   (_) => const NotificationsScreen(),
        '/mon-compte':      (_) => const MonCompteScreen(),
        '/admin':           (_) => const AdminShell(),
      },
    );
  }
}
