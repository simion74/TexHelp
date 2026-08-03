import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Machine Library ও Fabric Fault — এই দুই ফিচারের লিস্ট ও ডিটেইল, মোট ৪টা
/// স্ক্রিনেই এই একই হেডার-রো ব্যবহার হয়। এই widget নিজে কোনো ব্যাকগ্রাউন্ড
/// আঁকে না — TCX Color Finder স্ক্রিনের মতোই, পুরো স্ক্রিনের ব্যাকগ্রাউন্ড
/// হিসেবে `assets/images/bg_frame.webp` সরাসরি (অপরিবর্তিত) ব্যবহার হয়,
/// আর এই হেডার-রো টা শুধু সেই ব্যাকগ্রাউন্ডের উপর বসানো কন্টেন্ট।
///
/// 🔧 এখানে নিচের ভ্যারিয়েবলগুলো বদলে হেডারের সাইজ/স্পেসিং নিয়ন্ত্রণ করুন।
class LibraryWaveHeader extends StatelessWidget {
  final String title;
  final String? subtitle; // সবসময় ইংরেজি ফিক্সড টেক্সট, টগল হয় না
  final bool isBack; // true হলে back arrow, false হলে home আইকন
  final VoidCallback onLeadingTap;
  final bool isEnglish;
  final ValueChanged<bool> onLanguageChanged;
  final bool titleGreen; // true: গাঢ় সবুজ বোল্ড টাইটেল, false: কালো টাইটেল

  // 🔧 হেডারের সাইজ নিয়ন্ত্রণ
  static const double buttonSize = 34;
  static const double buttonIconSize = 17;
  static const double titleFontSize = 21;
  static const double subtitleFontSize = 11.5;

  // 🔧🔧🔧 টাইটেল টেক্সটকে (title + subtitle) নিচে/উপরে নামানোর জন্য —
  // সংখ্যা বাড়ালে টেক্সট নিচে নামবে, কমালে উপরে উঠবে, ঋণাত্মক (negative)
  // সংখ্যাও দেওয়া যাবে (তাহলে হোম আইকনের চেয়েও উপরে উঠে যাবে)।
  static const double titleTopOffset = 30;

  // 🔧🔧🔧 টাইটেল টেক্সটকে (title + subtitle) ডানে/বামে সরানোর জন্য —
  // পজিটিভ সংখ্যা (যেমন 10, 20) দিলে ডানে সরবে, নেগেটিভ সংখ্যা (যেমন -10)
  // দিলে বামে সরবে। 0 দিলে ঠিক মাঝখানে থাকবে (আগের মতো)।
  static const double titleHorizontalOffset = 16;

  const LibraryWaveHeader({
    super.key,
    required this.title,
    this.subtitle,
    required this.isBack,
    required this.onLeadingTap,
    required this.isEnglish,
    required this.onLanguageChanged,
    this.titleGreen = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: AppColors.pink,
          shape: const CircleBorder(),
          elevation: 3,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onLeadingTap,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                isBack ? Icons.arrow_back_rounded : Icons.home_rounded,
                color: Colors.white,
                size: buttonIconSize,
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            // 🔧 এখানে top: titleTopOffset — উপরের ভ্যারিয়েবল বদলালেই
            // টাইটেল/সাবটাইটেল নিচে-উপরে সরবে।
            padding: const EdgeInsets.only(top: titleTopOffset),
            // 🔧 Transform.translate দিয়ে ডানে/বামে সরানো হচ্ছে —
            // titleHorizontalOffset ভ্যারিয়েবল বদলালেই সরে যাবে।
            child: Transform.translate(
              offset: const Offset(titleHorizontalOffset, 0),
              child: Column(
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xff0d930d),
                      height: 1.1,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: subtitleFontSize,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        _LanguageToggle(
          isEnglish: isEnglish,
          onChanged: onLanguageChanged,
        ),
      ],
    );
  }
}

class _LanguageToggle extends StatelessWidget {
  final bool isEnglish;
  final ValueChanged<bool> onChanged;

  const _LanguageToggle({required this.isEnglish, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _pill('EN', isEnglish, () => onChanged(true)),
            _pill('বাংলা', !isEnglish, () => onChanged(false)),
          ],
        ),
      ),
    );
  }

  Widget _pill(String label, bool selected, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(13),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? AppColors.green : Colors.transparent,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : Colors.black54,
          ),
        ),
      ),
    );
  }
}
