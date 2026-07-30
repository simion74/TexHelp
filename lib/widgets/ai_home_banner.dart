import 'dart:ui';
import 'package:flutter/material.dart';
import '../screens/ai_settings_screen.dart';
import '../services/gemini_service.dart';
import 'ai_icon.dart';

/// হোম পেজের সবুজ হেডারে বসে — API Key সেট করা না থাকলে গ্লাস-ইফেক্ট
/// "Activate Smart AI Features" ব্যানার দেখাবে, সেট করা থাকলে শুধু একটা
/// ছোট গ্লাস-স্টাইল "AI Active" স্ট্যাটাস দেখাবে (আর কোনো বার্তা দেখাবে না)।
class AiHomeBanner extends StatefulWidget {
  const AiHomeBanner({super.key});

  // ---------------------------------------------------------------------
  // 🔧 সাইজ/স্পেসিং কনফিগারেশন — এখানেই ইচ্ছামতো ছোট-বড় করুন
  // ---------------------------------------------------------------------
  /// ব্যানারের ভেতরের প্যাডিং (চারপাশে) — বাড়ালে কন্টেইনার বড় হবে
  static const EdgeInsets bannerPadding =
      EdgeInsets.symmetric(horizontal: 6, vertical: 7);

  /// 🆕 সরাসরি লম্বা (height) নিয়ন্ত্রণ — এখানে একটা সংখ্যা দিলে ভেতরে
  /// আইকন/ফন্ট যাই থাকুক, কন্টেইনার ঠিক এতটুকুই লম্বা হবে (iconBoxSize বা
  /// bannerPadding-এর vertical মান আর height আটকাতে পারবে না)। null রাখলে
  /// আগের মতো স্বয়ংক্রিয় (আইকন + padding অনুযায়ী) উচ্চতা হবে।
  static const double? bannerHeight = 40;

  /// ব্যানারের গোলাকার কোণা
  static const double borderRadius = 9;

  /// আইকন বক্সের সাইজ
  static const double iconBoxSize = 25;

  /// টাইটেল ও সাবটাইটেলের ফন্ট সাইজ
  static const double titleFontSize = 12;
  static const double subtitleFontSize = 9.5;

  /// গ্লাস ব্লার-এর তীব্রতা (বেশি হলে আরও ফ্রস্টেড দেখাবে)
  static const double blurSigma = 6;

  @override
  State<AiHomeBanner> createState() => _AiHomeBannerState();
}

class _AiHomeBannerState extends State<AiHomeBanner> {
  bool? _isActive; // null = এখনো চেক করা হয়নি (কিছু দেখাবে না, ঝাঁকুনি এড়াতে)

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final active = await GeminiService.isActive();
    if (!mounted) return;
    setState(() => _isActive = active);
  }

  Future<void> _openSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AiSettingsScreen()),
    );
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    if (_isActive == null) return const SizedBox.shrink();

    if (_isActive == true) {
      // ✅ সক্রিয় থাকলে শুধু ছোট গ্লাস-স্টাইল স্ট্যাটাস — কোনো বাড়তি বার্তা নেই
      return _GlassContainer(
        borderRadius: 20,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.circle, size: 7, color: Color(0xFF7CFC9C)),
            SizedBox(width: 6),
            Text('AI Active',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      );
    }

    // 🔴 সক্রিয় না থাকলে — স্বচ্ছ গ্লাস-ইফেক্ট সেটআপ ব্যানার
    return _GlassContainer(
      borderRadius: AiHomeBanner.borderRadius,
      // 🔧 bannerHeight সেট করা থাকলে vertical প্যাডিং বাদ দেওয়া হয় (নাহলে
      // height আর padding একে অপরের সাথে সংঘর্ষ করে overflow দেখাতে পারে)
      // — height নিজেই তখন উচ্চতা ঠিক করে, Center দিয়ে কনটেন্ট মাঝে বসে।
      padding: AiHomeBanner.bannerHeight != null
          ? EdgeInsets.symmetric(
              horizontal: AiHomeBanner.bannerPadding.horizontal / 2)
          : AiHomeBanner.bannerPadding,
      height: AiHomeBanner.bannerHeight,
      onTap: _openSettings,
      child: Row(
        children: [
          Container(
            width: AiHomeBanner.iconBoxSize,
            height: AiHomeBanner.iconBoxSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: AiIcon(
              size: AiHomeBanner.iconBoxSize,
              borderRadius: BorderRadius.circular(9),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Activate Smart AI Features',
                  style: TextStyle(
                      fontSize: AiHomeBanner.titleFontSize,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 4),
                      ]),
                ),
                Text(
                  'Setup your free Gemini API Key to unlock AI features',
                  style: TextStyle(
                      fontSize: AiHomeBanner.subtitleFontSize,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.85)),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded,
              size: 12, color: Colors.white.withOpacity(0.75)),
        ],
      ),
    );
  }
}

/// 🧊 গ্লাসমরফিজম (ফ্রস্টেড গ্লাস) ইফেক্ট — ব্লার + স্বচ্ছ সাদা টিন্ট +
/// হালকা বর্ডার হাইলাইট, যাতে সবুজ ব্যাকগ্রাউন্ডের উপর "স্মার্ট" ও ভাসমান
/// একটা কাচের কার্ডের মতো দেখায়।
class _GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsets padding;
  final double? height;
  final VoidCallback? onTap;

  const _GlassContainer({
    required this.child,
    required this.borderRadius,
    required this.padding,
    this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(
            sigmaX: AiHomeBanner.blurSigma, sigmaY: AiHomeBanner.blurSigma),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Container(
              // 🔧 height দেওয়া থাকলে কন্টেইনার ঠিক এই উচ্চতায় "লক" হয়ে
              // যাবে — ভেতরের আইকন/টেক্সট যত বড়ই হোক, এর বাইরে বাড়বে না।
              // Center দিয়ে ভেতরের কনটেন্ট মাঝখানে বসানো হয়েছে, যাতে
              // vertical padding-এর সাথে সংঘর্ষ না হয়।
              height: height,
              padding: padding,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.22),
                    Colors.white.withOpacity(0.08),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.35),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: height != null ? Center(child: child) : child,
            ),
          ),
        ),
      ),
    );
  }
}
