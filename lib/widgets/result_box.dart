import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// ফলাফল দেখানোর বক্স (যেমন Points/100 Sq.Yd, Grade, Consumption ইত্যাদি)
/// dense true দিলে আরেকটু কম হাইট হয় - Shrinkage/Fabric Consumption-এর
/// মতো স্ক্রিনে ব্যবহারের জন্য, বাকি স্ক্রিনের ডিফল্ট সাইজ অপরিবর্তিত থাকে।
class ResultBox extends StatelessWidget {
  final String label;
  final String value;
  final Color borderColor;
  final Color bgColor;
  final Color textColor;
  final Color labelColor;
  final bool live;
  final bool dense;

  const ResultBox({
    super.key,
    required this.label,
    required this.value,
    this.borderColor = AppColors.inputBorder,
    this.bgColor = Colors.white,
    this.textColor = AppColors.darkGreen,
    this.labelColor = Colors.black54,
    this.live = false,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      transform: live
          ? (Matrix4.identity()..translate(0.0, -2.0))
          : Matrix4.identity(),
      padding: EdgeInsets.symmetric(vertical: dense ? 5 : 6, horizontal: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(live ? 0.07 : 0.03),
            blurRadius: live ? 12 : 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: dense ? 9 : 10,
              fontWeight: FontWeight.w800,
              color: labelColor,
              letterSpacing: 0.2,
            ),
          ),
          SizedBox(height: dense ? 2 : 3),
          Text(
            value,
            style: TextStyle(
              fontSize: dense ? 14 : 16,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
