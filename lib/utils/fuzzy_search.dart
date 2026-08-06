/// 🔎 বানান ভুল সহ্য করতে পারা এমন সার্চ ম্যাচার — Lab Test ও Chemical
/// লাইব্রেরিতে ব্যবহারের জন্য। প্রথমে সাধারণ সাবস্ট্রিং ম্যাচ চেষ্টা করে
/// (দ্রুত), সেটা না মিললে প্রতিটা শব্দের সাথে Levenshtein Distance দিয়ে
/// "কাছাকাছি বানান"ও মিলিয়ে দেখে।
bool fuzzyContains(String text, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return true;
  final t = text.toLowerCase();

  // ধাপ ১ — সরাসরি সাবস্ট্রিং ম্যাচ (দ্রুততম, বেশিরভাগ ক্ষেত্রেই যথেষ্ট)
  if (t.contains(q)) return true;

  // ধাপ ২ — প্রতিটা শব্দ আলাদা করে বানান-সহনশীল (fuzzy) ম্যাচ
  final words = t.split(RegExp(r'[\s,()\-/।]+'));
  final queryWords = q.split(RegExp(r'[\s,()\-/।]+'));

  for (final qw in queryWords) {
    if (qw.length < 3) continue; // খুব ছোট শব্দে fuzzy match এড়িয়ে যাওয়া ভালো
    final threshold = qw.length > 6 ? 2 : 1; // লম্বা শব্দে একটু বেশি সহনশীলতা
    final matched = words.any((w) {
      if (w.isEmpty) return false;
      if (w.contains(qw) || qw.contains(w)) return true;
      return _levenshtein(w, qw) <= threshold;
    });
    if (!matched) return false;
  }
  return true;
}

/// দুটো স্ট্রিং-এর মধ্যে "এডিট ডিস্ট্যান্স" (কতগুলো অক্ষর বদলালে একটা
/// আরেকটার সমান হবে) — কম মান মানে বানান কাছাকাছি।
int _levenshtein(String a, String b) {
  if (a == b) return 0;
  if (a.isEmpty) return b.length;
  if (b.isEmpty) return a.length;

  final dp = List.generate(a.length + 1, (_) => List.filled(b.length + 1, 0));
  for (var i = 0; i <= a.length; i++) dp[i][0] = i;
  for (var j = 0; j <= b.length; j++) dp[0][j] = j;

  for (var i = 1; i <= a.length; i++) {
    for (var j = 1; j <= b.length; j++) {
      final cost = a[i - 1] == b[j - 1] ? 0 : 1;
      final del = dp[i - 1][j] + 1;
      final ins = dp[i][j - 1] + 1;
      final sub = dp[i - 1][j - 1] + cost;
      dp[i][j] = [del, ins, sub].reduce((x, y) => x < y ? x : y);
    }
  }
  return dp[a.length][b.length];
}
