import 'package:flutter/material.dart';
import '../data/chemical_data.dart';
import '../theme/app_colors.dart';
import '../utils/fuzzy_search.dart';
import '../widgets/library_scaffold.dart';
import '../widgets/library_wave_header.dart';
import 'chemical_detail_screen.dart';

/// 🧪 Chemical Library — টেক্সটাইল/গার্মেন্টসে ব্যবহৃত ৬৭+ কেমিক্যালের
/// রেফারেন্স তালিকা। এখানে ইচ্ছাকৃতভাবে কোনো "Ask AI" সার্চ নেই — কারণ
/// কেমিক্যাল সেফটি তথ্যে AI-এর ভুল অনুমান (hallucination) সরাসরি বিপদজনক
/// হতে পারে। শুধুমাত্র যাচাই করা বান্ডল করা ডাটা থেকেই সার্চ/ফিল্টার হয়,
/// বানান একটু ভুল হলেও (fuzzy match) খুঁজে দেবে।
///
/// 📝 নোট: কোনো স্যাম্পল ছবি না থাকায় গ্রিড-থাম্বনেইল বাদ দিয়ে এখন
/// প্রতিটি কেমিক্যাল একটি ক্লিন লিস্ট-টাইল আকারে দেখানো হয় — শুধু
/// রঙিন আইকন-অ্যাভাটার, নাম, ক্যাটাগরি ব্যাজ, আর সংক্ষিপ্ত ব্যবহার।
class ChemicalScreen extends StatefulWidget {
  const ChemicalScreen({super.key});

  @override
  State<ChemicalScreen> createState() => _ChemicalScreenState();
}

class _ChemicalScreenState extends State<ChemicalScreen> {
  bool _isEnglish = true;
  String _query = '';
  String? _selectedCategory; // null = All
  bool _isCategoryExpanded = false;

  List<ChemicalItem> get _filtered {
    return kChemicals.where((c) {
      final matchesCategory =
          _selectedCategory == null || c.categoryId == _selectedCategory;
      final matchesQuery = _query.isEmpty ||
          fuzzyContains(c.nameEn, _query) ||
          fuzzyContains(c.nameBn, _query) ||
          fuzzyContains(c.usedInProcessEn, _query);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return LibraryScaffold(
      header: LibraryWaveHeader(
        title: 'Chemical Library',
        subtitle: 'Textile & Garments Chemical Reference',
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
                hintText: 'Search chemical name (e.g. Caustic, Softener...)',
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
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 🔽 Category Filter হেডার — ট্যাপ করলে সব ক্যাটাগরি এক্সপ্যান্ড/কোলাপ্স হবে
          InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: () =>
                setState(() => _isCategoryExpanded = !_isCategoryExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Text(
                    'Category Filter',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.black54),
                  ),
                  const SizedBox(width: 6),
                  if (!_isCategoryExpanded && _selectedCategory != null)
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.green.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _isEnglish
                              ? kChemicalCategories
                                  .firstWhere(
                                      (cat) => cat.id == _selectedCategory)
                                  .nameEn
                              : kChemicalCategories
                                  .firstWhere(
                                      (cat) => cat.id == _selectedCategory)
                                  .nameBn,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkGreen),
                        ),
                      ),
                    ),
                  const Spacer(),
                  AnimatedRotation(
                    turns: _isCategoryExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down_rounded,
                        size: 18, color: Colors.black45),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: !_isCategoryExpanded
                ? const SizedBox.shrink()
                : Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _CategoryChip(
                        label: 'All',
                        color: AppColors.green,
                        icon: Icons.apps_rounded,
                        selected: _selectedCategory == null,
                        onTap: () {
                          setState(() {
                            _selectedCategory = null;
                            _isCategoryExpanded = false;
                          });
                        },
                      ),
                      for (final cat in kChemicalCategories)
                        _CategoryChip(
                          label: _isEnglish ? cat.nameEn : cat.nameBn,
                          color: cat.color,
                          icon: cat.icon,
                          selected: _selectedCategory == cat.id,
                          onTap: () {
                            setState(() {
                              _selectedCategory = cat.id;
                              _isCategoryExpanded = false;
                            });
                          },
                        ),
                    ],
                  ),
          ),
          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'All Chemicals',
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
                      text: '${filtered.length} Chemicals',
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
                        ? 'No matching chemical found.'
                        : 'কোনো মিলে যাওয়া কেমিক্যাল পাওয়া যায়নি।',
                    style: const TextStyle(color: Colors.black45, fontSize: 12),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final c = filtered[i];
                return _ChemicalListTile(
                  chemical: c,
                  isEnglish: _isEnglish,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChemicalDetailScreen(
                          chemical: c,
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

/// 🧾 কোনো ইমেজ/থাম্বনেইল কন্টেইনার ছাড়াই ক্লিন লিস্ট-টাইল —
/// রঙিন আইকন-অ্যাভাটার, নাম, ব্যবহারের সংক্ষিপ্ত বিবরণ, ক্যাটাগরি ব্যাজ।
class _ChemicalListTile extends StatelessWidget {
  final ChemicalItem chemical;
  final bool isEnglish;
  final VoidCallback onTap;

  const _ChemicalListTile({
    required this.chemical,
    required this.isEnglish,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = chemical.categoryColor;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border(left: BorderSide(color: color, width: 4)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2)),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: color.withOpacity(0.12), shape: BoxShape.circle),
                child: Icon(chemical.categoryIcon, color: color, size: 19),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // পুরো নাম — এখন ২ লাইন পর্যন্ত wrap হবে, কাটা পড়বে না
                    Text(
                      isEnglish ? chemical.nameEn : chemical.nameBn,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkGreen,
                          height: 1.2),
                    ),
                    const SizedBox(height: 4),
                    // ক্যাটাগরি — খুব ছোট আকারে নামের ঠিক নিচে
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration:
                              BoxDecoration(color: color, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            isEnglish ? chemical.categoryEn : chemical.categoryBn,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: color),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right_rounded,
                  color: Colors.black26, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
