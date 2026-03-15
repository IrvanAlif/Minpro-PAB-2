import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'config/supabase_client.dart';
import 'pages/auth/login_page.dart';
import 'pages/home_page.dart';
import 'services/rental_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();

  // Cek apakah sudah ada session aktif
  final session = SupabaseConfig.client.auth.currentSession;
  Widget initialPage;
  if (session != null) {
    final controller = RentalController();
    await controller.init();
    initialPage = HomePage(controller: controller);
  } else {
    initialPage = const LoginPage();
  }

  runApp(MyApp(home: initialPage));
}

class MyApp extends StatelessWidget {
  final Widget home;
  const MyApp({super.key, required this.home});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F6F4),
        cardColor: Colors.white,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        dividerColor: const Color(0xFF2C2C2C),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.light,
      home: home,
    );
  }
}
