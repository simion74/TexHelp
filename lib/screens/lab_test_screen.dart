import 'package:flutter/material.dart';
import '../data/lab_test_data.dart';
import '../theme/app_colors.dart';
import '../utils/fuzzy_search.dart';
import '../widgets/library_scaffold.dart';
import '../widgets/library_thumbnail.dart';
import '../widgets/library_wave_header.dart';
import 'lab_test_detail_screen.dart';

/// 🔬 Lab Test Library — ফেব্রিক/গার্মেন্টসের ২১৪+ ল্যাব টেস্টের রেফারেন্স
/// (Physical, Chemical, Mechanical ইত্যাদি সব ধরনের)। Chemical Library-এর
/// মতোই এখানে কোনো "Ask AI" সার্চ নেই — শুধু যাচাই করা বান্ডল করা ডাটা
/// থেকে সার্চ/ফিল্টার হয়, বানান ভুল হলেও (fuzzy match) খুঁজে দেবে।
class LabTestScreen extends StatefulWidget {
  const LabTestScreen({super.key});

  @override
  State<LabTestScreen> createState() => _LabTestScreenState();
}

class _LabTestScreenState extends State<LabTestScreen> {
  bool _isEnglish = true;
  String _query = '';
  String? _selectedCategory; // null = All

  static const int _crossAxisCount = 4;
  static const double _gridSpacing = 10;
  static const double _cardAspectRatio = 0.86;

  List<LabTestItem> get _filtered {
    return kLabTests.where((t) {
      final matchesCategory =
          _selectedCategory == null || t.categoryId == _selectedCategory;
      final matchesQuery = _query.isEmpty ||
          fuzzyContains(t.name, _query) ||
          fuzzyContains(t.shortDescriptionEn, _query) ||
          fuzzyContains(t.shortDescriptionBn, _query);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return LibraryScaffold(
      header: LibraryWaveHeader(
        title: 'Lab Test',
        subtitle: 'Fabric & Garments Test Guide',
        isBack: false,
        onLeadingTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
        isEnglish: _isEnglish,
        onLanguageChanged: (v) => setState(() => _isEnglish = v),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
        children: [
          // 🔎 সার্চ বক্স — টাইপ করার সাথে সাথে ফিল্টার হয়, বানান একটু
          // ভুল হলেও (fuzzy match) কাছাকাছি রেজাল্ট দেখাবে
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2)),
              ],
            ),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              style: const TextStyle(fontSize: 12.5),
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Search test name (e.g. Colorfastness, GSM...)',
                hintStyle:
                    const TextStyle(fontSize: 11.5, color: Colors.black38),
                prefixIcon: const Icon(Icons.search_rounded,
                    color: Colors.black45, size: 18),
                prefixIconConstraints:
                    const BoxConstraints(minWidth: 34, minHeight: 0),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded,
                            size: 16, color: Colors.black45),
                        onPressed: () => setState(() => _query = ''),
                      ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 12, horizontal: 4),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Category Filter',
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _CategoryChip(
                label: 'All',
                color: AppColors.green,
                icon: Icons.apps_rounded,
                selected: _selectedCategory == null,
                onTap: () => setState(() => _selectedCategory = null),
              ),
              for (final cat in kLabTestCategories)
                _CategoryChip(
                  label: _isEnglish ? cat.nameEn : cat.nameBn,
                  color: cat.color,
                  icon: cat.icon,
                  selected: _selectedCategory == cat.id,
                  onTap: () => setState(() => _selectedCategory = cat.id),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'All Tests',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkGreen),
              ),
              Text.rich(
                TextSpan(
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                  children: [
                    const TextSpan(text: 'Total: '),
                    TextSpan(
                      text: '${filtered.length} Tests',
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, color: AppColors.green),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Column(
                children: [
                  const Icon(Icons.search_off_rounded,
                      size: 40, color: Colors.black26),
                  const SizedBox(height: 8),
                  Text(
                    _isEnglish
                        ? 'No matching test found.'
                        : 'কোনো মিলে যাওয়া টেস্ট পাওয়া যায়নি।',
                    style: const TextStyle(color: Colors.black45, fontSize: 12),
                  ),
                ],
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _crossAxisCount,
                crossAxisSpacing: _gridSpacing,
                mainAxisSpacing: _gridSpacing,
                childAspectRatio: _cardAspectRatio,
              ),
              itemBuilder: (context, i) {
                final t = filtered[i];
                return _LabTestCard(
                  test: t,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => LabTestDetailScreen(
                          test: t,
                          initialIsEnglish: _isEnglish,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.color,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? color : color.withOpacity(0.10),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 13, color: selected ? Colors.white : color),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LabTestCard extends StatelessWidget {
  final LabTestItem test;
  final VoidCallback onTap;

  const _LabTestCard({required this.test, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(7),
      elevation: 1.5,
      shadowColor: Colors.black26,
      child: InkWell(
        borderRadius: BorderRadius.circular(7),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: LibraryThumbnail(
                  imagePath: null,
                  icon: test.categoryIcon,
                  color: test.categoryColor,
                  borderRadius: 3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                test.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 9.2,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkGreen,
                    height: 1.15),
              ),
              const SizedBox(height: 4),
              Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                    color: test.categoryColor, shape: BoxShape.circle),
                child: Icon(test.categoryIcon, color: Colors.white, size: 9),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
