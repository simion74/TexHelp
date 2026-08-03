import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Shrinkage/Fabric Consumption-এর মতো স্ক্রিনে যেখানে দুইটা ফিল্ড
/// পাশাপাশি (Length | Width) রাখা দরকার, সেখানে সাধারণ `InputCard`
/// ব্যবহার করলে জায়গার অভাবে লেবেল টেক্সট অক্ষর-বাই-অক্ষর ভেঙে যেত।
/// এই widget-এ আইকন + লেবেল + ভ্যালু সব একই লাইনে (আইকন বামে, ইনপুট
/// ডান পাশে) থাকে বলে হাইট অনেক কম লাগে - ছোট স্ক্রিনেও সহজে ফিট হয়।
/// ইনপুট বক্সটা ছোট রাখা হয়েছে (৩-৪ ডিজিটের জন্য যথেষ্ট)।
class CompactInputCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Gradient iconGradient;
  final Color accentColor;
  final bool active;
  final VoidCallback onTap;

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
              color: active ? accentColor.withOpacity(0.2) : Colors.black.withOpacity(0.04),
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11.5,
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
                      color: value.isEmpty ? Colors.black38 : AppColors.darkGreen,
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
