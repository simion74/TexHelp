import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import 'ad_banner.dart';

/// Machine Library ও Fabric Fault-এর ৪টা স্ক্রিনের কমন কাঠামো।
///
/// 🔧 গুরুত্বপূর্ণ: এখানে `bg_frame.webp` ঠিক CalcScaffold-এ যেভাবে ব্যবহার
/// হয়, হুবহু সেভাবেই ব্যবহার করা হয়েছে — কোনো crop/OverflowBox/edit নেই।
/// ফ্রেমটা সম্পূর্ণ অপরিবর্তিত পুরো স্ক্রিনের ব্যাকগ্রাউন্ড হিসেবে বসানো,
/// আমাদের সব কন্টেন্ট (header, filter, grid) তার উপরে বসে।
class LibraryScaffold extends StatelessWidget {
  final Widget header; // home/back বাটন + টাইটেল + ভাষা টগল
  final Widget body; // স্ক্রলযোগ্য মূল কন্টেন্ট

  const LibraryScaffold({
    super.key,
    required this.header,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        body: Column(
          children: [
            // স্ট্যাটাস বার আইকনগুলোর জন্য গাঢ় সবুজ স্ট্রিপ — CalcScaffold-এর সাথে হুবহু মিল
            Container(
              height: statusBarHeight,
              color: AppColors.darkGreen,
            ),
            Expanded(
              child: Container(
                // 🖼️ ফ্রেম — অপরিবর্তিত, CalcScaffold-এর মতোই ব্যবহৃত
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/bg_frame.webp'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: header,
                    ),
                    Expanded(child: body),
                    const ClipRRect(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(10)),
                      child: AdBannerWidget(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
