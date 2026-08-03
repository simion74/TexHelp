import 'package:flutter/material.dart';

/// 🤖 TexHelp-এর কমন AI আইকন — হোম পেজের ব্যানার, AI Settings, AI Color
/// Finder, Machine Library/Fabric Fault/Fabric Type-এর "AI Support" সার্চ
/// বক্স, "Powered by Gemini AI" ব্যাজ — অ্যাপের সব জায়গায় এই একই আইকনটা
/// ব্যবহার হয়, যাতে ব্র্যান্ডিং সবখানে সামঞ্জস্যপূর্ণ থাকে।
///
/// 🔧 আইকন বদলাতে চাইলে শুধু assets/images/ai_icon.webp ফাইলটা নতুন ছবি
/// দিয়ে replace করলেই পুরো অ্যাপে (সব স্ক্রিনে) একসাথে বদলে যাবে — কোডে
/// আলাদাভাবে কোথাও হাত দেওয়া লাগবে না।
class AiIcon extends StatelessWidget {
  final double size;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? shadows;

  const AiIcon({
    super.key,
    this.size = 20,
    this.borderRadius,
    this.shadows,
  });

  static const String assetPath = 'assets/images/ai_icon.webp';

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );

    if (borderRadius == null && shadows == null) return image;

    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: shadows,
      ),
      child: borderRadius != null
          ? ClipRRect(borderRadius: borderRadius!, child: image)
          : image,
    );
  }
}
