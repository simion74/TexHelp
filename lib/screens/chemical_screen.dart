import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/chemical_data.dart';
import '../theme/app_colors.dart';
import '../utils/fuzzy_search.dart';
import '../widgets/ad_banner.dart';
import 'chemical_detail_screen.dart';

/// 🧪 Chemical Library — টেক্সটাইল/গার্মেন্টসে ব্যবহৃত ৬৭+ কেমিক্যালের
/// রেফারেন্স তালিকা। এখানে ইচ্ছাকৃতভাবে কোনো "Ask AI" সার্চ নেই — কারণ
/// কেমিক্যাল সেফটি তথ্যে AI-এর ভুল অনুমান (hallucination) সরাসরি বিপদজনক
/// হতে পারে। শুধুমাত্র যাচাই করা বান্ডল করা ডাটা থেকেই সার্চ/ফিল্টার হয়,
/// বানান একটু ভুল হলেও (fuzzy match) খুঁজে দেবে।
///
/// 🖼️ নোট: এই স্ক্রিনটা আলাদা ব্যাকগ্রাউন্ড ফ্রেম
/// (`assets/image/chemical_screen_frame.webp`) ব্যবহার করে — তাই এটা আর
/// শেয়ার্ড `LibraryScaffold` / `LibraryWaveHeader` (যেগুলো Machine Library ও
/// Fabric Fault স্ক্রিনে `assets/images/bg_frame.webp` ব্যবহার করে) থেকে
/// নেয় না। এই ফাইলের ভিতরেই স্ট্যাটাস-বার স্ট্রিপ, ব্যাকগ্রাউন্ড ফ্রেম,
/// হেডার (home আইকন + টাইটেল + ভাষা টগল) এবং নিচের অ্যাড ব্যানার — সবকিছু
/// স্বনির্ভরভাবে (self-contained) বসানো হয়েছে, যাতে অন্য কোনো স্ক্রিনের
/// ডিজাইনে প্রভাব না পড়ে।
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

  // 🎨 নিচের কেমিক্যাল লিস্টে এখন প্রতিটা ক্যাটাগরির আলাদা রং দেখানো হয় না —
  // ব্যাকগ্রাউন্ড ফ্রেমের সাথে "Finishing" ক্যাটাগরির রংটাই সবচেয়ে ভালো
  // মানানসই, তাই পুরো লিস্টে এই একটা রংই ব্যবহার হচ্ছে। "Finishing" নাম
  // বদলে গেলে/না পাওয়া গেলে প্রথম ক্যাটাগরির রং ব্যবহার হবে (ক্র্যাশ হবে না)।
  static final Color _listAccentColor = kChemicalCategories
      .firstWhere(
        (c) => c.nameEn == 'Finishing',
        orElse: () => kChemicalCategories.first,
      )
      .color;

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
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        body: Column(
          children: [
            // স্ট্যাটাস বার আইকনগুলোর জন্য গাঢ় সবুজ স্ট্রিপ
            Container(
              height: statusBarHeight,
              color: AppColors.darkGreen,
            ),
            Expanded(
              child: Container(
                // 🖼️ নতুন ব্যাকগ্রাউন্ড ফ্রেম — পুরো স্ক্রিন জুড়ে
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/chemical_screen_frame.webp'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: _ChemicalHeader.topOffset),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: _ChemicalHeader(
                        isEnglish: _isEnglish,
                        onLanguageChanged: (v) =>
                            setState(() => _isEnglish = v),
                        onHomeTap: () =>
                            Navigator.of(context).popUntil((r) => r.isFirst),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
                        children: [
                          // 🔎 সার্চ বক্স — টাইপ করার সাথে সাথে ফিল্টার হয়,
                          // বানান একটু ভুল হলেও (fuzzy match) কাছাকাছি
                          // রেজাল্ট দেখাবে
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
                              style: const TextStyle(fontSize: 11.5),
                              decoration: InputDecoration(
                                isDense: true,
                                hintText:
                                    'Search chemical name (e.g. Caustic, Softener...)',
                                hintStyle: const TextStyle(
                                    fontSize: 10.5, color: Colors.black38),
                                prefixIcon: const Icon(Icons.search_rounded,
                                    color: Colors.black45, size: 16),
                                prefixIconConstraints: const BoxConstraints(
                                    minWidth: 32, minHeight: 0),
                                suffixIcon: _query.isEmpty
                                    ? null
                                    : IconButton(
                                        icon: const Icon(Icons.close_rounded,
                                            size: 14, color: Colors.black45),
                                        onPressed: () =>
                                            setState(() => _query = ''),
                                      ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 11, horizontal: 4),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // 🔽 Category Filter হেডার — ট্যাপ করলে সব
                          // ক্যাটাগরি এক্সপ্যান্ড/কোলাপ্স হবে
                          InkWell(
                            borderRadius: BorderRadius.circular(6),
                            onTap: () => setState(() =>
                                _isCategoryExpanded = !_isCategoryExpanded),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  const Text(
                                    'Category Filter',
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black54),
                                  ),
                                  const SizedBox(width: 6),
                                  if (!_isCategoryExpanded &&
                                      _selectedCategory != null)
                                    Flexible(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.green
                                              .withOpacity(0.12),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          _isEnglish
                                              ? kChemicalCategories
                                                  .firstWhere((cat) =>
                                                      cat.id ==
                                                      _selectedCategory)
                                                  .nameEn
                                              : kChemicalCategories
                                                  .firstWhere((cat) =>
                                                      cat.id ==
                                                      _selectedCategory)
                                                  .nameBn,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.darkGreen),
                                        ),
                                      ),
                                    ),
                                  const Spacer(),
                                  AnimatedRotation(
                                    turns: _isCategoryExpanded ? 0.5 : 0,
                                    duration:
                                        const Duration(milliseconds: 200),
                                    child: const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        size: 17,
                                        color: Colors.black45),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // 🔲 ক্যাটাগরি গ্রিড — উদাহরণ ছবির মতো ৪x২ = ৮টা
                          // স্কয়ার ব্লক (All + ৭টা ক্যাটাগরি), প্রতিটাতে
                          // বাম পাশে আইকন, ডান পাশে ছোট ফন্টে দুই লাইনের নাম
                          AnimatedSize(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeInOut,
                            alignment: Alignment.topCenter,
                            child: !_isCategoryExpanded
                                ? const SizedBox.shrink()
                                : GridView.count(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    crossAxisCount: 4,
                                    mainAxisSpacing: 8,
                                    crossAxisSpacing: 8,
                                    childAspectRatio: 1.0,
                                    children: [
                                      _CategoryGridTile(
                                        icon: Icons.apps_rounded,
                                        title: 'All',
                                        subtitle: '${kChemicals.length}',
                                        color: AppColors.green,
                                        selected: _selectedCategory == null,
                                        onTap: () {
                                          setState(() {
                                            _selectedCategory = null;
                                            _isCategoryExpanded = false;
                                          });
                                        },
                                      ),
                                      for (final cat in kChemicalCategories)
                                        _CategoryGridTile(
                                          icon: cat.icon,
                                          title: _isEnglish
                                              ? cat.nameEn
                                              : cat.nameBn,
                                          color: cat.color,
                                          selected:
                                              _selectedCategory == cat.id,
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
                          const SizedBox(height: 12),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'All Chemicals',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.darkGreen),
                              ),
                              Text.rich(
                                TextSpan(
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.black54),
                                  children: [
                                    const TextSpan(text: 'Total: '),
                                    TextSpan(
                                      text: '${filtered.length} Chemicals',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.green),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          if (filtered.isEmpty)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 30),
                              child: Column(
                                children: [
                                  const Icon(Icons.search_off_rounded,
                                      size: 38, color: Colors.black26),
                                  const SizedBox(height: 8),
                                  Text(
                                    _isEnglish
                                        ? 'No matching chemical found.'
                                        : 'কোনো মিলে যাওয়া কেমিক্যাল পাওয়া যায়নি।',
                                    style: const TextStyle(
                                        color: Colors.black45, fontSize: 11),
                                  ),
                                ],
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, i) {
                                final c = filtered[i];
                                return _ChemicalListTile(
                                  chemical: c,
                                  isEnglish: _isEnglish,
                                  accentColor: _listAccentColor,
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
                    ),
                    // 📢 এটা আগেও এখানেই ছিল — নিচের "View Guide" স্টাইলের
                    // কন্টেইনার এখানে নেই, বরং আগের AdBannerWidget-ই ফিরিয়ে
                    // আনা হয়েছে।
                    const ClipRRect(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(10)),
                      child: AdBannerWidget(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 🧭 এই স্ক্রিনের নিজস্ব হেডার — নতুন ফ্রেম অনুযায়ী উদাহরণ ছবির মতো করে
/// বানানো: সাদা গোলাকার বাটনে সবুজ home আইকন, বাম-সংলগ্ন টাইটেল/সাবটাইটেল,
/// আর ডানে সাদা পিল-আকৃতির ভাষা টগল (ভিতরের সিলেক্টেড অংশ সবুজ)।
///
/// 🔧 নিচের কনস্ট্যান্টগুলো বদলে পজিশন/সাইজ টিউন করা যাবে।
class _ChemicalHeader extends StatelessWidget {
  final bool isEnglish;
  final ValueChanged<bool> onLanguageChanged;
  final VoidCallback onHomeTap;

  const _ChemicalHeader({
    required this.isEnglish,
    required this.onLanguageChanged,
    required this.onHomeTap,
  });

  // 🔧 হেডার শুরু হওয়ার আগে উপরে কতটুকু ফাঁকা জায়গা থাকবে — বাড়ালে হেডার
  // নিচে নামবে (উদাহরণ ছবির মতো গাঢ় green wave-এর মাঝামাঝি জায়গায় বসবে)
  static const double topOffset = 34;
  static const double buttonSize = 34;
  static const double buttonIconSize = 17;
  static const double titleFontSize = 18;
  static const double subtitleFontSize = 10.5;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 🏠 home বাটন — সাদা বর্ডার, ভিতরে green ফিল, তার ভিতরে সাদা আইকন
        Material(
          color: Colors.white,
          shape: const CircleBorder(),
          elevation: 3,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onHomeTap,
            child: Padding(
              // 🔧 সাদা বর্ডারের পুরুত্ব — সংখ্যা বাড়ালে বর্ডার মোটা হবে
              padding: const EdgeInsets.all(3),
              child: Container(
                width: buttonSize - 6,
                height: buttonSize - 6,
                decoration: const BoxDecoration(
                  color: AppColors.green,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.home_rounded,
                  color: Colors.white,
                  size: buttonIconSize,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Chemical Library',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkGreen,
                  height: 1.1,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Textile & Garments Chemical Reference',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: subtitleFontSize,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _LanguageToggle(
          isEnglish: isEnglish,
          onChanged: onLanguageChanged,
        ),
      ],
    );
  }
}

class _LanguageToggle extends StatelessWidget {
  final bool isEnglish;
  final ValueChanged<bool> onChanged;

  const _LanguageToggle({required this.isEnglish, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _pill('EN', isEnglish, () => onChanged(true)),
            _pill('বাংলা', !isEnglish, () => onChanged(false)),
          ],
        ),
      ),
    );
  }

  Widget _pill(String label, bool selected, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(13),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? AppColors.green : Colors.transparent,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Text(
          label,
          style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : Colors.black54),
        ),
      ),
    );
  }
}

/// 🔲 ক্যাটাগরি গ্রিডের একটা স্কয়ার ব্লক — বাম পাশে আইকন, ডান পাশে টাইটেল
/// (এবং "All"-এর জন্য নিচে সংখ্যা)। সিলেক্ট করা থাকলে হালকা গাঢ় ব্যাকগ্রাউন্ড
/// আর রঙিন বর্ডার দেখাবে।
class _CategoryGridTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryGridTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? color.withOpacity(0.22) : color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: selected ? Border.all(color: color, width: 1.3) : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: subtitle == null
                    ? Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w700,
                            color: color,
                            height: 1.05),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: color),
                          ),
                          Text(
                            subtitle!,
                            style: TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w600,
                                color: color.withOpacity(0.75)),
                          ),
                        ],
                      ),
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
  final Color accentColor;
  final VoidCallback onTap;

  const _ChemicalListTile({
    required this.chemical,
    required this.isEnglish,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 🎨 এখন ক্যাটাগরি অনুযায়ী রং বদলায় না — সব লিস্ট-টাইলে একটাই রং
    final color = accentColor;
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
          padding: const EdgeInsets.fromLTRB(12, 9, 10, 9),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    color: color.withOpacity(0.12), shape: BoxShape.circle),
                child: Icon(chemical.categoryIcon, color: color, size: 17),
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
                          fontSize: 12,
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
                          decoration: BoxDecoration(
                              color: color, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            isEnglish
                                ? chemical.categoryEn
                                : chemical.categoryBn,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 9,
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
                  color: Colors.black26, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
