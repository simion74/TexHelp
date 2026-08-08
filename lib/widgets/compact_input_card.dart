import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Shrinkage/Fabric Consumption-এর মতো স্ক্রিনে যেখানে দুইটা ফিল্ড
/// পাশাপাশি (Length | Width) রাখা দরকার, সেখানে সাধারণ `InputCard`
/// ব্যবহার করলে জায়গার অভাবে লেবেল টেক্সট অক্ষর-বাই-অক্ষর ভেঙে যেত।
/// এই widget-এ আইকন + লেবেল + ভ্যালু সব একই লাইনে (আইকন বামে, ইনপুট
/// ডান পাশে) থাকে বলে হাইট অনেক কম লাগে - ছোট স্ক্রিনেও সহজে ফিট হয়।
/// ইনপুট বক্সটা ছোট রাখা হয়েছে (৩-৪ ডিজিটের জন্য যথেষ্ট)।
///
/// 🆕 [labelFontSize] ও [labelMaxLines] — ঐচ্ছিক প্যারামিটার, ডিফল্ট
/// ভ্যালু আগের আচরণের মতোই (fontSize: 11.5, maxLines: 1)। যে স্ক্রিনে
/// label টেক্সট এক লাইনে ফিট হচ্ছে না / কেটে যাচ্ছে (যেমন
/// FabricConsumptionScreen), শুধু সেই স্ক্রিনেই এই দুইটা পাস করে দিলে
/// আইকন/কার্ড সাইজ অপরিবর্তিত রেখে লেবেল ছোট ফন্টে দুই লাইনে wrap
/// হবে। অন্য কোনো স্ক্রিনে প্রভাব পড়বে না, কারণ ডিফল্ট ভ্যালু আগের মতোই।
class CompactInputCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Gradient iconGradient;
  final Color accentColor;
  final bool active;
  final VoidCallback onTap;
  final double labelFontSize;
  final int labelMaxLines;

  const CompactInputCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.iconGradient,
    required this.accentColor,
    required this.onTap,
    this.active = false,
    this.labelFontSize = 11.5,
    this.labelMaxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final displayVal = value.isEmpty ? '0' : value;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? accentColor : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: active
                  ? accentColor.withOpacity(0.2)
                  : Colors.black.withOpacity(0.04),
              blurRadius: active ? 10 : 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                gradient: iconGradient,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Icon(icon, color: Colors.white, size: 13),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                maxLines: labelMaxLines,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: labelFontSize,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkGreen,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              constraints: const BoxConstraints(minWidth: 56),
              decoration: BoxDecoration(
                color: AppColors.inputBg,
                border: Border.all(color: AppColors.inputBorder),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    displayVal,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color:
                          value.isEmpty ? Colors.black38 : AppColors.darkGreen,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    unit,
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkGreen,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
