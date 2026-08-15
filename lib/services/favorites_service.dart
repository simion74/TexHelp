import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// ইউজারের বেছে নেওয়া ফেভারিট ফিচারগুলো ডিভাইসে সেভ রাখার সার্ভিস।
/// প্রতিটি ফিচারের `title`-কেই ইউনিক আইডি হিসেবে ব্যবহার করা হয়েছে
/// (calcMenuItems লিস্টে সব title ইউনিক), আর ক্রম (order) অনুযায়ী
/// একটা List<String> হিসেবে সেভ থাকে — তাই ইউজার যেভাবে সাজাবে
/// (drag-to-reorder) ঠিক সেভাবেই হোম স্ক্রিনে দেখাবে।
class FavoritesService {
  static const String _key = 'texhelp_favorite_titles';

  /// সেভ করা ফেভারিট টাইটেলগুলো, ইউজারের সাজানো ক্রম অনুযায়ী।
  static Future<List<String>> getFavoriteTitles() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List;
      return decoded.map((e) => e.toString()).toList();
    } catch (_) {
      return [];
    }
  }

  /// সম্পূর্ণ লিস্টটাই (নতুন ক্রম সহ) সেভ করে দেয়।
  static Future<void> setFavoriteTitles(List<String> titles) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(titles));
  }

  /// একটা টাইটেল ফেভারিটে যোগ করে (শেষে) — আগে থেকে থাকলে কিছু করে না।
  static Future<List<String>> addFavorite(String title) async {
    final current = await getFavoriteTitles();
    if (!current.contains(title)) {
      current.add(title);
      await setFavoriteTitles(current);
    }
    return current;
  }

  /// একটা টাইটেল ফেভারিট থেকে বাদ দেয়।
  static Future<List<String>> removeFavorite(String title) async {
    final current = await getFavoriteTitles();
    current.remove(title);
    await setFavoriteTitles(current);
    return current;
  }
}
