import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/lab_test_data.dart';
import '../theme/app_colors.dart';
import '../utils/fuzzy_search.dart';
import '../widgets/ad_banner.dart';
import '../widgets/library_thumbnail.dart';
import 'lab_test_detail_screen.dart';

/// 🔬 Lab Test Library — ফেব্রিক/গার্মেন্টসের ২১৪+ ল্যাব টেস্টের রেফারেন্স।
/// Chemical Library-এর সাথে হুবহু মিলিয়ে ডিজাইন করা, এবং স্ক্রল আর্কিটেকচারও
/// (নিচের নোট দেখুন) একই — কোনো "Ask AI" সার্চ নেই, শুধু বান্ডল করা ডাটা
/// থেকে fuzzy সার্চ/ফিল্টার হয়।
///
/// 📌 স্ক্রল বিহেভিয়ার: শুধু সার্চ বক্স ফিক্সড থাকে। ক্যাটাগরি সংখ্যা বেশি
/// (১৭টা) হওয়ায় ক্যাটাগরি গ্রিড + "All Tests" রো + টেস্ট গ্রিড — সবগুলো
/// একটাই `CustomScrollView`-এ (`SliverGrid`/`SliverToBoxAdapter` দিয়ে)
/// একসাথে স্ক্রল হয়। কোনো নেস্টেড shrinkWrap GridView ব্যবহার করা হয়নি,
/// তাই আগের রিলিজ-বিল্ড গ্যাপ বাগও তৈরি হবে না।
class LabTestScreen extends StatefulWidget {
  const LabTestScreen({super.key});

  @override
  State<LabTestScreen> createState() => _LabTestScreenState();
}

class _LabTestScreenState extends State<LabTestScreen> {
  bool _isEnglish = true;
  String _query = '';
  String? _selectedCategory; // null = All
  final ScrollController _listScrollController = ScrollController();

  static const int _crossAxisCount = 4;
  static const double _gridSpacing = 10;
  static const double _cardAspectRatio = 0.86;

  static const Color _accentGreen = AppColors.green;
  static const Color _darkGreenText = AppColors.darkGreen;

  // ==========================================================================
  // 🔧🔧🔧 লেআউট টিউনিং কনস্ট্যান্ট — Chemical Screen-এর সাথে হুবহু মিলিয়ে
  // ==========================================================================
  static const EdgeInsets fixedSectionPadding =
      EdgeInsets.fromLTRB(14, 0, 14, 0);
  static const double searchBoxBottomGap = 10;
  static const double categoryGridTileHeight = 30;
  static const double categoryGridSpacing = 8;
  // 👇 ক্যাটাগরি গ্রিড ↔ "All Tests" রো — এখন 0, কোনো ফাঁকা জায়গা নেই
  static const double categoryGridBottomGap = 10;
  static const double allTestsBottomGap = 0;

  static const EdgeInsets listPadding = EdgeInsets.fromLTRB(14, 8, 10, 12);
  static const double listScrollbarThickness = 3;

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
  void dispose() {
    _listScrollController.dispose();
    super.dispose();
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
            Container(
              height: statusBarHeight,
              color: _darkGreenText,
            ),
            Expanded(
              child: Container(
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

                    // 📌 ফিক্সড অংশ — শুধু সার্চ বক্স, এটাই একমাত্র অংশ যা
                    // স্ক্রল হয় না। ক্যাটাগরি অনেকগুলো (১৭টা) হওয়ায় সেটা
                    // এখন নিচের স্ক্রলযোগ্য অংশের সাথেই স্ক্রল হবে।
                    Padding(
                      padding: fixedSectionPadding,
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
                          style: const TextStyle(fontSize: 11.5),
                          decoration: InputDecoration(
                            isDense: true,
                            hintText:
                                'Search test name (e.g. Colorfastness, GSM...)',
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
                    ),
                    const SizedBox(height: searchBoxBottomGap),

                    // 📜 এখন থেকে ক্যাটাগরি গ্রিড + "All Tests" রো + টেস্ট
                    // গ্রিড — সবগুলো একসাথে একটাই CustomScrollView-এ, তাই
                    // ক্যাটাগরি ব্লকগুলোও কন্টেন্টের সাথে স্ক্রল হবে (আগের
                    // মতো ফিক্সড থাকবে না)। এটা নেস্টেড shrinkWrap GridView
                    // নয় (SliverGrid ব্যবহার করা হয়েছে) — তাই আগের গ্যাপ
                    // বাগও ফিরে আসবে না।
                    Expanded(
                      child: Scrollbar(
                        controller: _listScrollController,
                        thumbVisibility: true,
                        thickness: listScrollbarThickness,
                        radius: const Radius.circular(10),
                        child: CustomScrollView(
                          controller: _listScrollController,
                          slivers: [
                            SliverPadding(
                              padding: fixedSectionPadding,
                              sliver: SliverGrid(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  mainAxisSpacing: categoryGridSpacing,
                                  crossAxisSpacing: categoryGridSpacing,
                                  mainAxisExtent: categoryGridTileHeight,
                                ),
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    if (index == 0) {
                                      return _CategoryGridTile(
                                        icon: Icons.apps_rounded,
                                        title: 'All',
                                        subtitle: '${kLabTests.length}',
                                        color: _accentGreen,
                                        selected: _selectedCategory == null,
                                        onTap: () => setState(
                                            () => _selectedCategory = null),
                                      );
                                    }
                                    final cat = kLabTestCategories[index - 1];
                                    return _CategoryGridTile(
                                      icon: cat.icon,
                                      title:
                                          _isEnglish ? cat.nameEn : cat.nameBn,
                                      color: cat.color,
                                      selected: _selectedCategory == cat.id,
                                      onTap: () => setState(
                                          () => _selectedCategory = cat.id),
                                    );
                                  },
                                  childCount: kLabTestCategories.length + 1,
                                ),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: SizedBox(height: categoryGridBottomGap),
                            ),
                            SliverPadding(
                              padding: fixedSectionPadding,
                              sliver: SliverToBoxAdapter(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'All Tests',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: _darkGreenText),
                                    ),
                                    Text.rich(
                                      TextSpan(
                                        style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.black54),
                                        children: [
                                          const TextSpan(text: 'Total: '),
                                          TextSpan(
                                            text: '${filtered.length} Tests',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w800,
                                                color: _accentGreen),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: SizedBox(height: allTestsBottomGap),
                            ),
                            if (filtered.isEmpty)
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 30, horizontal: 14),
                                  child: Column(
                                    children: [
                                      const Icon(Icons.search_off_rounded,
                                          size: 38, color: Colors.black26),
                                      const SizedBox(height: 8),
                                      Text(
                                        _isEnglish
                                            ? 'No matching test found.'
                                            : 'কোনো মিলে যাওয়া টেস্ট পাওয়া যায়নি।',
                                        style: const TextStyle(
                                            color: Colors.black45,
                                            fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              SliverPadding(
                                padding: listPadding,
                                sliver: SliverGrid(
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: _crossAxisCount,
                                    crossAxisSpacing: _gridSpacing,
                                    mainAxisSpacing: _gridSpacing,
                                    childAspectRatio: _cardAspectRatio,
                                  ),
                                  delegate: SliverChildBuilderDelegate(
                                    (context, i) {
                                      final t = filtered[i];
                                      return _LabTestCard(
                                        test: t,
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  LabTestDetailScreen(
                                                test: t,
                                                initialIsEnglish: _isEnglish,
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    childCount: filtered.length,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

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

/// 🧭 এই স্ক্রিনের নিজস্ব হেডার — Chemical Library-এর হেডারের সাথে হুবহু
/// মিলিয়ে (একই পজিশন/সাইজ/কালার), শুধু টাইটেল টেক্সট আলাদা
class _LabTestHeader extends StatelessWidget {
  final bool isEnglish;
  final ValueChanged<bool> onLanguageChanged;
  final VoidCallback onHomeTap;

  const _LabTestHeader({
    required this.isEnglish,
    required this.onLanguageChanged,
    required this.onHomeTap,
  });

  static const double topOffset = 34;
  static const double buttonSize = 34;
  static const double buttonIconSize = 17;

  // 🔧 টাইটেল বড় ও বোল্ড করা হয়েছে (আগে 18 ছিল)
  static const double titleFontSize = 24;
  static const double subtitleFontSize = 10.5;

  static const Color _accentGreen = AppColors.green;

  static const EdgeInsets homeIconPadding =
      EdgeInsets.only(top: 0, right: 0, bottom: 0, left: 0);
  static const EdgeInsets titlePadding =
      EdgeInsets.only(top: 60, right: 0, bottom: 0, left: 40);
  static const EdgeInsets togglePadding =
      EdgeInsets.only(top: 105, right: 0, bottom: 0, left: 8);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                padding: const EdgeInsets.all(3),
                child: Container(
                  width: buttonSize - 6,
                  height: buttonSize - 6,
                  decoration: const BoxDecoration(
                    color: _accentGreen,
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
                    fontWeight: FontWeight.w900,
                    color: Color(0xff207f02),
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
                    color: Color(0xff135001),
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

  static const Color _accentGreen = AppColors.green;

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
          color: selected ? _accentGreen : Colors.transparent,
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

/// 🧾 টেস্ট গ্রিড কার্ড — অপরিবর্তিত (প্রতিটা ক্যাটাগরির নিজস্ব রং)
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
