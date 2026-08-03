import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// একটি ইনপুট রো/কার্ড - আইকন, লেবেল, সাব-লেবেল ও ডান পাশে ভ্যালু + ইউনিট।
/// active হলে কালার-ম্যাচড গ্লো বর্ডার দেখাবে (আগের HTML এর মতোই)।
/// isResult true হলে ফিল্ডটি অটো-ক্যালকুলেটেড ফলাফল হিসেবে টিন্ট রঙে দেখাবে।
/// dense true দিলে আরেকটু কম হাইট/প্যাডিং হয় - শুধু যে স্ক্রিনে বেশি ফিল্ড
/// একসাথে ফিট করাতে হয় (যেমন Stripe Size Converter) সেখানেই ব্যবহার হয়,
/// বাকি স্ক্রিনগুলোর ডিফল্ট (dense=false) সাইজ অপরিবর্তিত থাকে।
class InputCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subLabel;
  final String value;
  final String unit;
  final String placeholder;
  final Gradient iconGradient;
  final Color accentColor;
  final bool active;
  final bool isResult;
  final bool dense;
  final VoidCallback onTap;

  const InputCard({
    super.key,
    required this.icon,
    required this.label,
    required this.subLabel,
    required this.value,
    required this.unit,
    required this.iconGradient,
    required this.accentColor,
    required this.onTap,
    this.placeholder = '0',
    this.active = false,
    this.isResult = false,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final displayVal = value.isEmpty ? placeholder : value;
    final iconSize = dense ? 32.0 : 34.0;
    final vPad = dense ? 5.0 : 5.5;
    final vMargin = dense ? 2.0 : 2.5;
    final valueFont = dense ? 16.0 : 17.0;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: active
            ? (Matrix4.identity()..translate(0.0, -2.0))
            : Matrix4.identity(),
        margin: EdgeInsets.symmetric(vertical: vMargin),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: vPad),
        decoration: BoxDecoration(
          color: isResult
              ? accentColor.withOpacity(0.10)
              : AppColors.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active || isResult
                ? accentColor
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: active
                  ? accentColor.withOpacity(0.22)
                  : Colors.black.withOpacity(0.04),
              blurRadius: active ? 14 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                gradient: iconGradient,
                borderRadius: BorderRadius.circular(11),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: dense ? 15 : 17),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  if (subLabel.isNotEmpty) ...[
                    const SizedBox(height: 1),
                    Text(
                      subLabel,
                      style: const TextStyle(fontSize: 10, color: Colors.black54),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              constraints: const BoxConstraints(minWidth: 92),
              decoration: BoxDecoration(
                color: AppColors.inputBg,
                border: Border.all(color: AppColors.inputBorder),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: vPad),
                    child: Text(
                      displayVal,
                      style: TextStyle(
                        fontSize: valueFont,
                        fontWeight: FontWeight.w800,
                        color: value.isEmpty
                            ? Colors.black38
                            : (isResult ? accentColor : AppColors.darkGreen),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 9, vertical: vPad),
                    decoration: const BoxDecoration(
                      color: AppColors.unitBg,
                      border: Border(left: BorderSide(color: AppColors.inputBorder)),
                    ),
                    child: Text(
                      unit,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkGreen,
                      ),
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
