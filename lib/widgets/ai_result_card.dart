import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'ai_icon.dart';

/// একটা সেকশন — যেমন "Root Causes", "Remedies", "Safety Tips" ইত্যাদি।
/// [items] দিলে বুলেট লিস্ট আকারে দেখাবে, [paragraph] দিলে সাধারণ প্যারাগ্রাফ।
class AiInfoSection {
  final String heading;
  final IconData icon;
  final Color? iconColor;
  final List<String>? items;
  final String? paragraph;

  const AiInfoSection({
    required this.heading,
    required this.icon,
    this.iconColor,
    this.items,
    this.paragraph,
  }) : assert(items != null || paragraph != null);
}

/// Gemini AI থেকে আসা তথ্য দেখানোর জন্য কমন কার্ড ডিজাইন — Machine Library,
/// Fabric Fault, Fabric Type — তিনটা ফিচারেই এই একই স্টাইল ব্যবহার হয়, শুধু
/// টাইটেল/ট্যাগ/সেকশন কনটেন্ট বদলায়।
class AiInfoCard extends StatelessWidget {
  final String title;
  final String? tag;
  final Color accentColor;
  final String? description;
  final List<AiInfoSection> sections;

  const AiInfoCard({
    super.key,
    required this.title,
    this.tag,
    required this.accentColor,
    this.description,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentColor.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                      color: accentColor),
                ),
              ),
              if (tag != null && tag!.trim().isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tag!,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700),
                  ),
                ),
            ],
          ),
          if (description != null && description!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(description!,
                style: const TextStyle(fontSize: 12.5, color: Colors.black87, height: 1.4)),
          ],
          for (final s in sections) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(s.icon, size: 15, color: s.iconColor ?? accentColor),
                const SizedBox(width: 6),
                Text(s.heading,
                    style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: s.iconColor ?? accentColor)),
              ],
            ),
            const SizedBox(height: 6),
            if (s.items != null)
              ...s.items!.map(
                (t) => Padding(
                  padding: const EdgeInsets.only(top: 3, left: 21),
                  child: Text('•  $t',
                      style: const TextStyle(fontSize: 12.5, height: 1.35)),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(left: 21),
                child: Text(s.paragraph!,
                    style: const TextStyle(fontSize: 12.5, height: 1.4)),
              ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              AiIcon(size: 13),
              SizedBox(width: 4),
              Text('Powered by Gemini AI',
                  style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}

/// AI সার্চের Loading / Error অবস্থা দেখানোর জন্য কমন widget।
class AiStatusPanel extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final Color accentColor;

  const AiStatusPanel({
    super.key,
    required this.isLoading,
    required this.errorMessage,
    this.accentColor = AppColors.green,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 22),
        child: Column(
          children: [
            SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(
                  strokeWidth: 2.6, color: accentColor),
            ),
            const SizedBox(height: 10),
            const Text('AI থেকে তথ্য আনা হচ্ছে...',
                style: TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      );
    }
    if (errorMessage != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade100),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: Colors.redAccent, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(errorMessage!,
                  style: const TextStyle(fontSize: 12, color: Colors.black87, height: 1.4)),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
