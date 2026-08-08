import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/lab_test_data.dart';
import '../theme/app_colors.dart';
import '../utils/fuzzy_search.dart';
import '../widgets/ad_banner.dart';
import '../widgets/library_thumbnail.dart';
import 'lab_test_detail_screen.dart';

/// 🔬 Lab Test Library — ফেব্রিক/গার্মেন্টসের ২১৪+ ল্যাব টেস্টের রেফারেন্স
/// (Physical, Chemical, Mechanical ইত্যাদি সব ধরনের)। Chemical Library-এর
/// মতোই এখানে কোনো "Ask AI" সার্চ নেই — শুধু যাচাই করা বান্ডল করা ডাটা
/// থেকে সার্চ/ফিল্টার হয়, বানান ভুল হলেও (fuzzy match) খুঁজে দেবে।
///
/// 🖼️ নোট: Chemical Library-এর মতোই এই স্ক্রিনটাও নিজের আলাদা ব্যাকগ্রাউন্ড
/// ফ্রেম (`assets/images/lab_test_screen_frame.webp`) ব্যবহার করে —
/// তাই শেয়ার্ড `LibraryScaffold` / `LibraryWaveHeader` থেকে না নিয়ে এই
/// ফাইলের ভিতরেই স্ট্যাটাস-বার স্ট্রিপ, ব্যাকগ্রাউন্ড ফ্রেম, হেডার (home
/// আইকন + টাইটেল + ভাষা টগল) এবং নিচের অ্যাড ব্যানার — সবকিছু
/// স্বনির্ভরভাবে (self-contained) বসানো হয়েছে।
///
/// 📌 স্ক্রল বিহেভিয়ার: এখানে ক্যাটাগরি অনেক বেশি বলে Chemical Library থেকে
/// আলাদা — শুধু সার্চ বক্সটাই ফিক্সড থাকে, তার নিচে Category Filter
/// (হাইড/আনহাইড টগলসহ) + "All Tests" রো + টেস্ট গ্রিড — সবকিছু একসাথে
/// স্ক্রল হয়।
class LabTestScreen extends StatefulWidget {
  const LabTestScreen({super.key});

  @override
  State<LabTestScreen> createState() => _LabTestScreenState();
}

class _LabTestScreenState extends State<LabTestScreen> {
  bool _isEnglish = true;
  String _query = '';
  String? _selectedCategory; // null = All
  bool _isCategoryExpanded = true; // ক্যাটাগরি গ্রিড সবসময় খোলা থাকবে

  static const int _crossAxisCount = 4;
  static const double _gridSpacing = 10;
  static const double _cardAspectRatio = 0.86;

  // 🟢 এই স্ক্রিনের থিম-কালার — এখন Chemical Screen-এর মতোই সবুজ থিম।
  // হোম আইকন, সিলেক্টেড টগল, "All" ক্যাটাগরি ব্লক, কাউন্ট নাম্বার ইত্যাদি
  // সবখানে AppColors.green / AppColors.darkGreen ব্যবহার হচ্ছে। নিচের
  // টেস্ট-কার্ড গ্রিড (_LabTestCard) অপরিবর্তিত রাখা হয়েছে, ওখানে প্রতিটা
  // ক্যাটাগরির নিজস্ব রংই (test.categoryColor) থাকছে।
  static const Color _accentBlue = AppColors.green;
  static const Color _darkBlueText = AppColors.darkGreen;

  // ==========================================================================
  // 🔧🔧🔧 লেআউট টিউনিং কনস্ট্যান্ট — এখান থেকেই স্পেসিং/সাইজ কন্ট্রোল
  // করা যাবে, কোডের অন্য কোথাও হাত দেওয়ার দরকার নেই।
  // ==========================================================================
  static const double searchBoxBottomGap = 5; // সার্চ বক্স ↔ স্ক্রলযোগ্য অংশ
  static const double categoryLabelBottomGap =
      0; // "Category Filter" টেক্সট ↔ গ্রিড
  static const double categoryGridTileHeight =
      30; // প্রতিটা ক্যাটাগরি ব্লকের হাইট
  static const double categoryGridSpacing =
      8; // ক্যাটাগরি ব্লকগুলোর মাঝের গ্যাপ
  static const double categoryGridBottomGap = 1; // গ্রিড ↔ "All Tests" রো
  static const double allTestsBottomGap = 1; // "All Tests" রো ↔ টেস্ট গ্রিড

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
              color: _darkBlueText,
            ),
            Expanded(
              child: Container(
                // 🖼️ ব্যাকগ্রাউন্ড ফ্রেম — পুরো স্ক্রিন জুড়ে
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/lab_chemical.webp'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: _LabTestHeader.topOffset),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: _LabTestHeader(
                        isEnglish: _isEnglish,
                        onLanguageChanged: (v) =>
                            setState(() => _isEnglish = v),
                        onHomeTap: () =>
                            Navigator.of(context).popUntil((r) => r.isFirst),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 📌 শুধু সার্চ বক্সটাই ফিক্সড — স্ক্রল হয় না
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
                      child: Container(
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
                            hintText:
                                'Search test name (e.g. Colorfastness, GSM...)',
                            hintStyle: const TextStyle(
                                fontSize: 11.5, color: Colors.black38),
                            prefixIcon: const Icon(Icons.search_rounded,
                                color: Colors.black45, size: 18),
                            prefixIconConstraints: const BoxConstraints(
                                minWidth: 34, minHeight: 0),
                            suffixIcon: _query.isEmpty
                                ? null
                                : IconButton(
                                    icon: const Icon(Icons.close_rounded,
                                        size: 16, color: Colors.black45),
                                    onPressed: () =>
                                        setState(() => _query = ''),
                                  ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: searchBoxBottomGap),

                    // 📜 সার্চ বক্সের নিচ থেকে এখানে সবকিছু (ক্যাটাগরি
                    // ফিল্টারসহ) একসাথে স্ক্রল হয় — কারণ ক্যাটাগরি অনেক বেশি
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(14, 0, 14, 6),
                        children: [
                          // 🔽 Category Filter হেডার — ট্যাপ করলে সব
                          // ক্যাটাগরি এক্সপ্যান্ড/কোলাপ্স হবে
                          InkWell(
                            borderRadius: BorderRadius.circular(6),
                            onTap: null,
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
                                  if (!_isCategoryExpanded &&
                                      _selectedCategory != null)
                                    Flexible(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: _accentBlue.withOpacity(0.12),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          _isEnglish
                                              ? kLabTestCategories
                                                  .firstWhere((c) =>
                                                      c.id == _selectedCategory)
                                                  .nameEn
                                              : kLabTestCategories
                                                  .firstWhere((c) =>
                                                      c.id == _selectedCategory)
                                                  .nameBn,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: _darkBlueText),
                                        ),
                                      ),
                                    ),
                                  const Spacer(),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: categoryLabelBottomGap),

                          // 🔲 ক্যাটাগরি গ্রিড — স্কয়ার ব্লক, বাম পাশে
                          // আইকন, ডান পাশে ছোট ফন্টে দুই লাইনের নাম।
                          // ক্যাটাগরি অনেক বেশি বলে হাইড/আনহাইড টগল আছে।
                          AnimatedSize(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeInOut,
                            alignment: Alignment.topCenter,
                            child: !_isCategoryExpanded
                                ? const SizedBox.shrink()
                                : GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: kLabTestCategories.length + 1,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 4,
                                      mainAxisSpacing: categoryGridSpacing,
                                      crossAxisSpacing: categoryGridSpacing,
                                      mainAxisExtent: categoryGridTileHeight,
                                    ),
                                    itemBuilder: (context, index) {
                                      if (index == 0) {
                                        return _CategoryGridTile(
                                          icon: Icons.apps_rounded,
                                          title: 'All',
                                          subtitle: '${kLabTests.length}',
                                          color: _accentBlue,
                                          selected: _selectedCategory == null,
                                          onTap: () => setState(
                                              () => _selectedCategory = null),
                                        );
                                      }
                                      final cat = kLabTestCategories[index - 1];
                                      return _CategoryGridTile(
                                        icon: cat.icon,
                                        title: _isEnglish
                                            ? cat.nameEn
                                            : cat.nameBn,
                                        color: cat.color,
                                        selected: _selectedCategory == cat.id,
                                        onTap: () => setState(
                                            () => _selectedCategory = cat.id),
                                      );
                                    },
                                  ),
                          ),
                          SizedBox(height: categoryGridBottomGap),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'All Tests',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: _darkBlueText),
                              ),
                              Text.rich(
                                TextSpan(
                                  style: const TextStyle(
                                      fontSize: 11, color: Colors.black54),
                                  children: [
                                    const TextSpan(text: 'Total: '),
                                    TextSpan(
                                      text: '${filtered.length} Tests',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: _accentBlue),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: allTestsBottomGap),
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
                                    style: const TextStyle(
                                        color: Colors.black45, fontSize: 12),
                                  ),
                                ],
                              ),
                            )
                          else
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filtered.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
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
                    ),

                    // 📢 নিচের অ্যাড ব্যানার — Chemical Library-এর মতোই
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

/// 🧭 এই স্ক্রিনের নিজস্ব হেডার — সাদা গোলাকার বাটনে সবুজ ফিল + সাদা home
/// আইকন, বাম-সংলগ্ন টাইটেল/সাবটাইটেল, আর ডানে সাদা পিল-আকৃতির ভাষা টগল।
///
/// 🔧🔧🔧 নিচে home আইকন, টাইটেল/সাবটাইটেল, আর ভাষা টগল — এই তিনটার জন্য
/// আলাদা আলাদা EdgeInsets দেওয়া আছে। প্রতিটা এলিমেন্ট স্বাধীনভাবে
/// উপরে/নিচে/ডানে/বামে সরাতে শুধু সংশ্লিষ্ট EdgeInsets-এর সংখ্যা বদলান —
/// বাকি এলিমেন্টে কোনো প্রভাব পড়বে না।
///
/// 🎨 প্যাডিং ও টেক্সট কালার এখন Chemical Screen-এর সাথে হুবহু মেলানো —
/// থিম-কালারও Chemical Screen-এর মতোই সবুজ।
class _LabTestHeader extends StatelessWidget {
  final bool isEnglish;
  final ValueChanged<bool> onLanguageChanged;
  final VoidCallback onHomeTap;

  const _LabTestHeader({
    required this.isEnglish,
    required this.onLanguageChanged,
    required this.onHomeTap,
  });

  // 🔧 হেডার শুরু হওয়ার আগে উপরে কতটুকু ফাঁকা জায়গা থাকবে — বাড়ালে পুরো
  // হেডার-রো (৩টা এলিমেন্টই একসাথে) নিচে নামবে
  static const double topOffset = 34;

  // 🔧 home বাটনের সাইজ
  static const double buttonSize = 34;
  static const double buttonIconSize = 17;

  // 🔧 টাইটেল/সাবটাইটেলের ফন্ট সাইজ
  static const double titleFontSize = 18;
  static const double subtitleFontSize = 10.5;

  // 🟢 এই হেডারের থিম-কালার — Chemical Screen-এর মতোই সবুজ
  static const Color _accentBlue = AppColors.green;
  static const Color _darkBlueText = AppColors.darkGreen;

  // 🔧🔧🔧 এলিমেন্ট-ভিত্তিক আলাদা প্যাডিং — এখানে বদলালেই শুধু ওই
  // এলিমেন্টটা সরবে (top/right/bottom/left) — Chemical Screen-এর মতোই
  static const EdgeInsets homeIconPadding =
      EdgeInsets.only(top: 0, right: 0, bottom: 0, left: 0);
  static const EdgeInsets titlePadding =
      EdgeInsets.only(top: 60, right: 0, bottom: 0, left: 60);
  static const EdgeInsets togglePadding =
      EdgeInsets.only(top: 105, right: 0, bottom: 0, left: 8);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🏠 home বাটন — সাদা বর্ডার, ভিতরে সবুজ ফিল, তার ভিতরে সাদা আইকন
        Padding(
          padding: homeIconPadding,
          child: Material(
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
                    color: _accentBlue,
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
        ),
        Expanded(
          child: Padding(
            padding: titlePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Lab Test',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w800,
                    color: Color(0x8a026B0C),
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Fabric & Garments Test Guide',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: subtitleFontSize,
                    fontWeight: FontWeight.w500,
                    color: Color(0x8a144206),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: togglePadding,
          child: _LanguageToggle(
            isEnglish: isEnglish,
            onChanged: onLanguageChanged,
          ),
        ),
      ],
    );
  }
}

class _LanguageToggle extends StatelessWidget {
  final bool isEnglish;
  final ValueChanged<bool> onChanged;

  const _LanguageToggle({required this.isEnglish, required this.onChanged});

  static const Color _accentBlue = AppColors.green;

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
          color: selected ? _accentBlue : Colors.transparent,
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
/// (এবং "All"-এর জন্য পাশে সংখ্যা)। সিলেক্ট করা থাকলে হালকা গাঢ়
/// ব্যাকগ্রাউন্ড আর রঙিন বর্ডার দেখাবে।
///
/// 🎨 রাউন্ড কর্নার (6) ও subtitle লেআউট (title পাশাপাশি "(count)") এখন
/// Chemical Screen-এর সাথে হুবহু মেলানো — যাতে "All" ব্লকে সংখ্যা কেটে না
/// যায়।
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
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
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
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: color),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '($subtitle)',
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

/// 🧾 টেস্ট গ্রিড কার্ড — Chemical Library-এর নির্দেশনা অনুযায়ী এই অংশ
/// অপরিবর্তিত রাখা হয়েছে (প্রতিটা ক্যাটাগরির নিজস্ব রংই থাকছে)।
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
