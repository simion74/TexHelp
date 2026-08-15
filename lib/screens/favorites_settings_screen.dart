import 'package:flutter/material.dart';
import '../data/calc_menu_items.dart';
import '../services/favorites_service.dart';
import '../theme/app_colors.dart';

/// ⭐ Favorites ম্যানেজমেন্ট স্ক্রিন
/// --------------------------------
/// হোম হেডারের সেটিংস আইকন থেকে খোলে। এখানে ইউজার:
/// ১) যেকোনো ফিচারকে তারার আইকনে ট্যাপ করে ফেভারিটে যোগ/বাদ দিতে পারবে
/// ২) উপরের "Your Favorites" লিস্টে ড্র্যাগ করে ক্রম সাজাতে পারবে
///
/// প্রতিটা পরিবর্তন সাথে সাথেই ডিভাইসে সেভ হয় (FavoritesService দিয়ে),
/// আলাদা "Save" বাটন লাগে না। হোম স্ক্রিনে ফিরে গেলে সাথে সাথে নতুন
/// ক্রম অনুযায়ী "My Favorites" সেকশন আপডেট হয়ে যাবে।
class FavoritesSettingsScreen extends StatefulWidget {
  const FavoritesSettingsScreen({super.key});

  @override
  State<FavoritesSettingsScreen> createState() =>
      _FavoritesSettingsScreenState();
}

class _FavoritesSettingsScreenState extends State<FavoritesSettingsScreen> {
  List<String> _favTitles = [];
  bool _loading = true;
  String _search = '';

  // Exit বাটন ফেভারিটে যোগ করার কোনো মানে নেই, তাই লিস্ট থেকে বাদ
  late final List<CalcItem> _selectableItems =
      calcMenuItems.where((e) => !e.isExit).toList();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final titles = await FavoritesService.getFavoriteTitles();
    if (!mounted) return;
    setState(() {
      // ডিফেন্সিভ: লিস্টে আর নেই এমন কোনো পুরনো টাইটেল থাকলে বাদ দেওয়া হচ্ছে
      _favTitles =
          titles.where((t) => _selectableItems.any((e) => e.title == t)).toList();
      _loading = false;
    });
  }

  Future<void> _persist() async {
    await FavoritesService.setFavoriteTitles(_favTitles);
  }

  void _toggleFavorite(String title) {
    setState(() {
      if (_favTitles.contains(title)) {
        _favTitles.remove(title);
      } else {
        _favTitles.add(title);
      }
    });
    _persist();
  }

  void _removeFavoriteAt(int index) {
    setState(() => _favTitles.removeAt(index));
    _persist();
  }

  void _reorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _favTitles.removeAt(oldIndex);
      _favTitles.insert(newIndex, item);
    });
    _persist();
  }

  CalcItem? _itemFor(String title) {
    for (final e in _selectableItems) {
      if (e.title == title) return e;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _search.trim().isEmpty
        ? _selectableItems
        : _selectableItems
            .where((e) =>
                e.title.toLowerCase().contains(_search.trim().toLowerCase()))
            .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(child: _buildFavoritesSection()),
                        SliverToBoxAdapter(child: _buildSearchBox()),
                        SliverToBoxAdapter(child: _buildAllFeaturesHeading()),
                        SliverList.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, i) =>
                              _allFeatureTile(filtered[i]),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 24)),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: AppColors.darkGreen,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.star_rounded, color: Colors.amberAccent, size: 20),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Manage Favorites',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star_rounded,
                  size: 18, color: Colors.amber),
              const SizedBox(width: 6),
              Text(
                'Your Favorites (${_favTitles.length})',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _favTitles.isEmpty
                ? 'নিচের লিস্ট থেকে ⭐ ট্যাপ করে আপনার বেশি ব্যবহৃত ফিচারগুলো এখানে যোগ করুন।'
                : 'ধরে টেনে (drag) ক্রম সাজান — হোম স্ক্রিনে এই ক্রমেই দেখাবে।',
            style: const TextStyle(fontSize: 11.5, color: Colors.black54),
          ),
          const SizedBox(height: 10),
          if (_favTitles.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 22),
              decoration: BoxDecoration(
                color: AppColors.inputBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.inputBorder),
              ),
              child: const Center(
                child: Text(
                  'এখনো কোনো ফেভারিট যোগ করা হয়নি',
                  style: TextStyle(fontSize: 12.5, color: Colors.black45),
                ),
              ),
            )
          else
            ReorderableListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              onReorder: _reorder,
              children: [
                for (int i = 0; i < _favTitles.length; i++)
                  _favoriteTile(_favTitles[i], i, key: ValueKey(_favTitles[i])),
              ],
            ),
        ],
      ),
    );
  }

  Widget _favoriteTile(String title, int index, {required Key key}) {
    final item = _itemFor(title);
    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.green.withOpacity(0.35)),
      ),
      child: ListTile(
        dense: true,
        leading: _itemThumb(item),
        title: Text(
          title,
          style: const TextStyle(
              fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.darkGreen),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.close_rounded,
                  size: 18, color: Colors.black45),
              onPressed: () => _removeFavoriteAt(index),
              tooltip: 'Remove',
            ),
            const Icon(Icons.drag_handle_rounded, color: Colors.black38),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        onChanged: (v) => setState(() => _search = v),
        decoration: InputDecoration(
          hintText: 'ফিচার খুঁজুন...',
          hintStyle: const TextStyle(fontSize: 12.5),
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          filled: true,
          fillColor: AppColors.inputBg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.inputBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.inputBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.green, width: 1.4),
          ),
        ),
      ),
    );
  }

  Widget _buildAllFeaturesHeading() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Text(
        'All Features',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: AppColors.darkGreen,
        ),
      ),
    );
  }

  Widget _allFeatureTile(CalcItem item) {
    final isFav = _favTitles.contains(item.title);
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: _itemThumb(item),
      title: Text(
        item.title,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
      subtitle: item.department != null
          ? Text(item.department!,
              style: const TextStyle(fontSize: 10.5, color: Colors.black45))
          : null,
      trailing: IconButton(
        icon: Icon(
          isFav ? Icons.star_rounded : Icons.star_border_rounded,
          color: isFav ? Colors.amber : Colors.black38,
        ),
        onPressed: () => _toggleFavorite(item.title),
      ),
      onTap: () => _toggleFavorite(item.title),
    );
  }

  Widget _itemThumb(CalcItem? item) {
    if (item?.imagePath != null) {
      return SizedBox(
        width: 32,
        height: 32,
        child: Image.asset(item!.imagePath!, fit: BoxFit.contain),
      );
    }
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: item?.color ?? AppColors.green,
        shape: BoxShape.circle,
      ),
      child: Icon(
        item?.icon ?? Icons.help_outline_rounded,
        color: Colors.white,
        size: 16,
      ),
    );
  }
}
