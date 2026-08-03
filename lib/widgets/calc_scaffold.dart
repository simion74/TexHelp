import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import 'ad_banner.dart';

/// সব ক্যালকুলেটর স্ক্রিনের কমন কাঠামো:
/// - সবার উপরে: স্ট্যাটাস বার (battery/network আইকন) এর জন্য একটা ছোট গাঢ় সবুজ স্ট্রিপ
/// - তারপর: ঢেউ ডিজাইনের ব্যাকগ্রাউন্ড, তার নিচে হোম বাটন + লোগো + টাইটেল হেডার
/// - মাঝে: `content` (ইনপুট কার্ড, রেজাল্ট বক্স ইত্যাদি) - বাকি জায়গা যতটুকু আছে
///   ততটুকুতেই বসে, স্ক্রল করা লাগে না
/// - নিচে: Reset বাটন + কাস্টম কিপ্যাড
class CalcScaffold extends StatelessWidget {
  final String title; // দুই লাইনের জন্য \n ব্যবহার করুন
  final IconData icon;
  final Widget content;
  final Widget keypad;
  final VoidCallback onReset;
  final Widget? extraHeaderAction;
  // 🖼️ হেডারের ছোট লোগো বক্সে IconData-এর বদলে কাস্টম ছবি (webp/png)
  // দেখাতে চাইলে এখানে asset path দিন, যেমন
  // 'assets/images/4_point_inspection.webp'। দিলে এটাই দেখাবে,
  // না দিলে আগের মতো `icon` (IconData) দেখাবে — তাই বাকি স্ক্রিনগুলো
  // এমনিতেই আগের মতো কাজ করবে।
  final String? iconAsset;
  // 🟩 true হলে (ডিফল্ট) আগের মতো গ্রিন গ্রেডিয়েন্ট বক্সের ভেতরে
  // আইকন/ছবি দেখাবে (যেমন 4 Point স্ক্রিনে আছে)। false দিলে কোনো
  // ব্যাকগ্রাউন্ড/শ্যাডো ছাড়া শুধু ছবিটাই (plain) দেখাবে।
  final bool showIconBackground;

  const CalcScaffold({
    super.key,
    required this.title,
    required this.icon,
    required this.content,
    required this.keypad,
    required this.onReset,
    this.extraHeaderAction,
    this.iconAsset,
    this.showIconBackground = true,
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
            // স্ট্যাটাস বার আইকনগুলোর (battery/network/camera) জন্য গাঢ় স্ট্রিপ
            Container(
              height: statusBarHeight,
              color: AppColors.darkGreen,
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/bg_frame.webp'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Padding(
                  // নিচে AdMob ব্যানারের (height 50) জন্য জায়গা রাখতে বাকি
                  // অংশের প্যাডিং/গ্যাপ একটু কমানো হয়েছে, যাতে সব মিলিয়ে
                  // এক স্ক্রিনেই সুন্দরভাবে ফিট হয়ে যায়, স্ক্রল লাগে না।
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 6),
                  child: Column(
                    children: [
                      // হেডার এখন একদম উপরে - স্ট্যাটাস বার স্ট্রিপের ঠিক পরেই
                      const SizedBox(height: 4),
                      _Header(
                        title: title,
                        icon: icon,
                        iconAsset: iconAsset,
                        showIconBackground: showIconBackground,
                        extraAction: extraHeaderAction,
                      ),
                      // হেডার থেকে ইনপুট কার্ডের মাঝে গ্যাপ (কমপ্যাক্ট করা হয়েছে)
                      const SizedBox(height: 4),
                      // Expanded + SingleChildScrollView: সাধারণত কন্টেন্ট এক
                      // স্ক্রিনেই বসে যায়, কিন্তু ছোট স্ক্রিনে বা AdMob ব্যানারের
                      // জন্য জায়গা কমে গেলেও যেন লে-আউট ভেঙে/ওভারফ্লো না হয়ে
                      // বরং সামান্য স্ক্রল হয় — এই নিরাপত্তার জন্য যুক্ত করা হয়েছে।
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          child: content,
                        ),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: onReset,
                          icon: const Icon(Icons.refresh_rounded, size: 20),
                          label: const Text(
                            'RESET ALL',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF65B741),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      keypad,
                      const SizedBox(height: 4),
                      // Google AdMob মোবাইল ব্যানার বিজ্ঞাপন কন্টেইনার
                      // height: 50.0, width: double.infinity — যাতে অ্যাড
                      // দেখানোর সময়ও লে-আউট না ভাঙে এবং কাজের ব্যাঘাত না হয়।
                      const ClipRRect(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(10)),
                        child: AdBannerWidget(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? iconAsset;
  final bool showIconBackground;
  final Widget? extraAction;

  const _Header({
    required this.title,
    required this.icon,
    this.iconAsset,
    this.showIconBackground = true,
    this.extraAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: _CircleIconButton(
            gradient: AppColors.homeButtonGradient,
            icon: Icons.home_rounded,
            onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(
                top: 32.0), // 🎯 এই ১৪.০ সংখ্যাটিই আপনার ইচ্ছেমত পরিবর্তন করবেন
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: showIconBackground
                      ? BoxDecoration(
                          gradient: AppColors.logoGradient,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.green.withOpacity(0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        )
                      : null,
                  child: iconAsset != null
                      ? Padding(
                          padding: showIconBackground
                              ? const EdgeInsets.all(6)
                              : EdgeInsets.zero,
                          child: Image.asset(
                            iconAsset!,
                            fit: BoxFit.contain,
                          ),
                        )
                      : Icon(
                          icon,
                          color: showIconBackground
                              ? Colors.white
                              : AppColors.darkGreen,
                          size: 17,
                        ),
                ),
                const SizedBox(width: 9),
                Flexible(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkGreen,
                      height: 1.1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: extraAction ?? const SizedBox(width: 38),
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final Gradient? gradient;
  final Color? color;
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({
    this.gradient,
    this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: gradient == null ? (color ?? Colors.white) : null,
      shape: const CircleBorder(),
      elevation: 3,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          gradient: gradient,
          shape: BoxShape.circle,
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Icon(
            icon,
            size: 17,
            color: gradient != null ? Colors.white : AppColors.darkGreen,
          ),
        ),
      ),
    );
    // ফাইলের শেষ এখানে
  }
}
