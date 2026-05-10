import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'screens/auth/phone_login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const CafeDeParisApp());
}

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class CafeDeParisApp extends StatelessWidget {
  const CafeDeParisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cafe De Paris',
      scaffoldMessengerKey: scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const PhoneLoginScreen(),
    );
  }
}
// force rebuild
