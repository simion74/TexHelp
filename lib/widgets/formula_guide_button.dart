import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// 📖 ক্যালকুলেটরের হেডারে ডান কোনায় বসানোর বাটন — চাপলে বটম-শিটে
/// ফরমুলার সংজ্ঞা, ব্যাখ্যা ও ধাপে ধাপে হিসাবের নিয়ম দেখায়। এটা
/// CalcScaffold-এর `extraHeaderAction` প্যারামিটারে বসাতে হয়।
///
/// ব্যবহার:
/// ```dart
/// CalcScaffold(
///   ...
///   extraHeaderAction: FormulaGuideButton(
///     title: 'Twist / TPI',
///     sections: [
///       FormulaGuideSection(heading: 'সংজ্ঞা', body: '...'),
///       FormulaGuideSection(heading: 'ফরমুলা', body: '...'),
///     ],
///   ),
/// )
/// ```
class FormulaGuideButton extends StatelessWidget {
  final String title;
  final List<FormulaGuideSection> sections;

  const FormulaGuideButton({
    super.key,
    required this.title,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 3,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => _showGuide(context),
        child: const Padding(
          padding: EdgeInsets.all(9),
          child: Icon(Icons.menu_book_rounded,
              color: AppColors.darkGreen, size: 18),
        ),
      ),
    );
  }

  void _showGuide(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (ctx, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 10, 6),
                child: Row(
                  children: [
                    const Icon(Icons.menu_book_rounded,
                        color: AppColors.green, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkGreen),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: Colors.black45),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 26),
                  itemCount: sections.length,
                  itemBuilder: (ctx, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sections[i].heading,
                          style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.green),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          sections[i].body,
                          style: const TextStyle(
                              fontSize: 12.5,
                              color: Colors.black87,
                              height: 1.55),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ফরমুলা গাইডের একটা সেকশন (হেডিং + বিস্তারিত লেখা)
class FormulaGuideSection {
  final String heading;
  final String body;
  const FormulaGuideSection({required this.heading, required this.body});
}
