import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'screens/home_screen.dart'; //  screens/ কেটে সরাসরি home_screen.dart করা হয়েছে
import 'theme/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 📢 AdMob SDK ইনিশিয়ালাইজেশন
  MobileAds.instance.initialize();

  // 📱 পোর্ট্রেট মোড ফিক্সড
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const TexHelpApp());
}

class TexHelpApp extends StatelessWidget {
  const TexHelpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TexHelp - Smart Textile Solution',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.green),
        scaffoldBackgroundColor: AppColors.screenBg,
      ),
      home: const HomeScreen(),
    );
  }
}
