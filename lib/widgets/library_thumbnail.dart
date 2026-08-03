import 'package:flutter/material.dart';

/// থাম্বনেইল — `imagePath` দেওয়া থাকলে সেই ছবি দেখাবে, না থাকলে
/// একটা রঙিন gradient ব্যাকগ্রাউন্ডে আইকন দেখাবে (placeholder)।
///
/// 🔧 পরে রিয়েল ছবি যোগ করতে চাইলে শুধু data ফাইলে `images: ['assets/...']`
/// বসিয়ে দিলেই এটা automatically আসল ছবি দেখাবে, কোড বদলাতে হবে না।
class LibraryThumbnail extends StatelessWidget {
  final String? imagePath;
  final IconData icon;
  final Color color;
  final double borderRadius;

  const LibraryThumbnail({
    super.key,
    required this.imagePath,
    required this.icon,
    required this.color,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: imagePath != null
          ? Image.asset(
              imagePath!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholder(),
            )
          : _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.75), color],
        ),
      ),
      child: Center(
        child: Icon(icon, color: Colors.white, size: 32),
      ),
    );
  }
}
