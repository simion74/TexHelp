import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// 🤖 TexHelp AI ফিচারগুলোর (AI Color Finder, Machine Library, Fabric Fault,
/// Fabric Type) জন্য একটাই কমন সার্ভিস। Gemini API Key সেভ/লোড করা এবং
/// Gemini-কে JSON রেসপন্সের জন্য অনুরোধ পাঠানো — দুটো কাজই এখানে কেন্দ্রীভূত,
/// যাতে প্রতিটা স্ক্রিনে বারবার একই কোড কপি-পেস্ট করতে না হয়।
///
/// 🔄 স্বয়ংক্রিয় মডেল সিলেকশন (Auto Model Discovery):
/// Google মাঝেমধ্যে পুরনো Gemini মডেল বন্ধ (deprecate) করে দেয়, তখন হার্ডকোড
/// করা মডেলের নাম দিয়ে কল করলে ৪০৪ এরর আসে। এটা এড়াতে এখানে কোনো একটা
/// মডেলের নাম স্থায়ীভাবে হার্ডকোড করা নেই — বরং অ্যাপ নিজেই ইউজারের API Key
/// দিয়ে Google-কে জিজ্ঞেস করে "এখন কোন কোন ফ্রি Flash মডেল অ্যাক্টিভ আছে"
/// (ListModels এন্ডপয়েন্ট) এবং তার মধ্যে থেকে সবচেয়ে উপযুক্তটা নিজে বেছে
/// নেয়। ফলাফল কিছুদিনের জন্য ডিভাইসে ক্যাশ থাকে (বারবার এক্সট্রা নেটওয়ার্ক
/// কল এড়াতে), আর কোনো মডেল হঠাৎ বন্ধ হয়ে ৪০৪ দিলে অ্যাপ নিজে থেকেই নতুন
/// মডেল খুঁজে আবার চেষ্টা করে — ইউজারকে কিছুই করতে হয় না, আর অ্যাপ আপডেট
/// দেওয়ারও দরকার পড়ে না।
class GeminiService {
  GeminiService._();

  static const String _apiKeyPref = 'gemini_api_key';
  static const String _cachedModelPref = 'gemini_resolved_model';
  static const String _cachedModelTimePref = 'gemini_resolved_model_ts';

  // 🆘 সব ধরনের অটো-ডিটেকশন ব্যর্থ হলে (যেমন ইন্টারনেট না থাকা অবস্থায়
  // প্রথমবার খোলা) এই মডেলটা শেষ ভরসা হিসেবে ব্যবহার হবে।
  static const String _hardFallbackModel = 'gemini-2.5-flash';

  // 🔧 কতদিন পর পর নতুন করে মডেল লিস্ট চেক করবে (এর মধ্যে ক্যাশ থেকেই চলবে)
  static const Duration _cacheTtl = Duration(days: 3);

  static Uri _listModelsEndpoint(String apiKey) => Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models?key=$apiKey',
      );

  static Uri _generateEndpoint(String model, String apiKey) => Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
      );

  // ---------------------------------------------------------------------
  // API Key সেভ / লোড / মুছে ফেলা
  // ---------------------------------------------------------------------

  static Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final key = prefs.getString(_apiKeyPref);
    if (key == null || key.trim().isEmpty) return null;
    return key.trim();
  }

  static Future<bool> isActive() async => (await getApiKey()) != null;

  static Future<void> saveApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyPref, apiKey.trim());
    // 🔄 নতুন Key দিলে আগের ক্যাশ করা মডেল মুছে ফেলা হয়, যাতে নতুন Key দিয়ে
    // আবার তাজা করে মডেল লিস্ট চেক হয় (কোনো পুরনো/ভুল ক্যাশ থেকে না যায়)
    await prefs.remove(_cachedModelPref);
    await prefs.remove(_cachedModelTimePref);
  }

  static Future<void> clearApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_apiKeyPref);
    await prefs.remove(_cachedModelPref);
    await prefs.remove(_cachedModelTimePref);
  }

  // ---------------------------------------------------------------------
  // 🔄 বর্তমানে অ্যাক্টিভ ফ্রি Flash মডেল স্বয়ংক্রিয়ভাবে খুঁজে বের করা
  // ---------------------------------------------------------------------

  static Future<String> _resolveModel(String apiKey,
      {bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();

    if (!forceRefresh) {
      final cached = prefs.getString(_cachedModelPref);
      final cachedAt = prefs.getInt(_cachedModelTimePref);
      if (cached != null && cachedAt != null) {
        final age = DateTime.now().millisecondsSinceEpoch - cachedAt;
        if (age < _cacheTtl.inMilliseconds) return cached;
      }
    }

    try {
      final res = await http
          .get(_listModelsEndpoint(apiKey))
          .timeout(const Duration(seconds: 12));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final models = (data['models'] as List?) ?? [];

        final candidates = <String>[];
        for (final m in models) {
          final rawName = (m['name'] as String?) ?? '';
          final name = rawName.replaceFirst('models/', '');
          final methods =
              ((m['supportedGenerationMethods'] as List?) ?? [])
                  .map((e) => e.toString())
                  .toList();

          // শুধু generateContent সাপোর্ট করা, ফ্রি-টিয়ার-বান্ধব "flash"
          // ফ্যামিলির টেক্সট মডেলই দরকার — image/tts/embedding/vision বা
          // বিশেষায়িত মডেল আমাদের JSON-টেক্সট কাজে লাগবে না
          if (!methods.contains('generateContent')) continue;
          if (!name.contains('flash')) continue;
          if (name.contains('image') ||
              name.contains('tts') ||
              name.contains('embedding') ||
              name.contains('vision') ||
              name.contains('live') ||
              name.contains('native-audio')) {
            continue;
          }
          candidates.add(name);
        }

        String? pick(bool Function(String) test) {
          for (final c in candidates) {
            if (test(c)) return c;
          }
          return null;
        }

        // 🥇 পছন্দক্রম: স্টেবল ফুল Flash > স্টেবল Flash-Lite > preview/experimental > যেকোনো একটা
        final chosen = pick((n) =>
                !n.contains('preview') &&
                !n.contains('exp') &&
                !n.contains('lite')) ??
            pick((n) => !n.contains('preview') && !n.contains('exp')) ??
            pick((n) => true);

        if (chosen != null) {
          await prefs.setString(_cachedModelPref, chosen);
          await prefs.setInt(
              _cachedModelTimePref, DateTime.now().millisecondsSinceEpoch);
          return chosen;
        }
      }
    } catch (_) {
      // নেটওয়ার্ক/পার্সিং সমস্যা হলে নিচে ফলব্যাক লজিকে চলে যাবে
    }

    // ব্যর্থ হলে — আগের ক্যাশ (থাকলে) অথবা হার্ড ফলব্যাক মডেল ব্যবহার হবে
    return prefs.getString(_cachedModelPref) ?? _hardFallbackModel;
  }

  // ---------------------------------------------------------------------
  // Gemini-কে অনুরোধ পাঠিয়ে স্ট্রাকচার্ড JSON রেসপন্স নেওয়া
  // ---------------------------------------------------------------------

  static Future<http.Response> _callGenerate(
      String model, String apiKey, String prompt) {
    return http
        .post(
          _generateEndpoint(model, apiKey),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {'text': prompt},
                ],
              },
            ],
            'generationConfig': {
              'temperature': 0.4,
              'responseMimeType': 'application/json',
            },
          }),
        )
        .timeout(const Duration(seconds: 30));
  }

  /// [prompt]-এ যা লেখা থাকবে Gemini সেটাই strictly JSON আকারে ফেরত
  /// দেওয়ার চেষ্টা করবে (প্রতিটা prompt-এর নিচে JSON structure বলে দিতে
  /// হবে)। রেসপন্স markdown ```json ফেন্স দিয়ে মোড়ানো থাকলে তা এখানেই
  /// পরিষ্কার করে Map<String, dynamic> হিসেবে ফেরত দেওয়া হয়।
  static Future<Map<String, dynamic>> generateJson(String prompt) async {
    final apiKey = await getApiKey();
    if (apiKey == null) {
      throw AiException(
        'AI Key সক্রিয় নেই। অনুগ্রহ করে সাইড মেনু থেকে 🤖 AI Settings এ গিয়ে '
        'আপনার ফ্রি Gemini API Key সেট করে নিন।',
      );
    }

    String model = await _resolveModel(apiKey);

    http.Response response;
    try {
      response = await _callGenerate(model, apiKey, prompt);

      // 🔄 মডেলটা Google হঠাৎ বন্ধ/deprecate করে দিলে ৪০৪ আসবে — তখন অ্যাপ
      // নিজে থেকেই নতুন করে সচল মডেল খুঁজে আবার একবার চেষ্টা করবে, ইউজারকে
      // কিছু করতে হয় না।
      if (response.statusCode == 404) {
        model = await _resolveModel(apiKey, forceRefresh: true);
        response = await _callGenerate(model, apiKey, prompt);
      }
    } catch (_) {
      throw AiException(
        'ইন্টারনেট কানেকশন পাওয়া যায়নি। AI ফিচার ব্যবহার করতে মোবাইল ডাটা '
        'অথবা Wi-Fi চালু রাখুন।',
      );
    }

    if (response.statusCode == 400 || response.statusCode == 403) {
      throw AiException(
        'API Key টি সঠিক নয় অথবা মেয়াদ শেষ হয়ে গেছে। AI Settings থেকে '
        'Key টি আবার চেক করুন। (Code: ${response.statusCode})',
      );
    }
    if (response.statusCode == 429) {
      throw AiException(
        'আজকের ফ্রি লিমিট শেষ হয়ে গেছে। কিছুক্ষণ পর আবার চেষ্টা করুন।',
      );
    }
    if (response.statusCode != 200) {
      throw AiException(
        'তথ্য আনতে সমস্যা হয়েছে। আবার চেষ্টা করুন। (Code: ${response.statusCode})',
      );
    }

    try {
      final data = jsonDecode(response.body);
      String rawText =
          data['candidates'][0]['content']['parts'][0]['text'] as String;
      rawText =
          rawText.replaceAll('```json', '').replaceAll('```', '').trim();
      return jsonDecode(rawText) as Map<String, dynamic>;
    } catch (_) {
      throw AiException('রেসপন্স বোঝা যায়নি। আবার চেষ্টা করুন।');
    }
  }
}

/// AI কল ব্যর্থ হলে ইউজার-ফ্রেন্ডলি (বাংলা) মেসেজ সহ এক্সসেপশন
class AiException implements Exception {
  final String message;
  AiException(this.message);

  @override
  String toString() => message;
}
