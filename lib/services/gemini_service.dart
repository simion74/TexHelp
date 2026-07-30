import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// 🤖 TexHelp AI ফিচারগুলোর জন্য একটাই কমন সার্ভিস।
///
/// 🔄 Google-এর অফিসিয়াল "-latest" alias ব্যবহার করা হচ্ছে —
/// এটা সবসময় Google-এর সর্বশেষ সচল Flash মডেলে পয়েন্ট করে।
/// Google নিজেই নতুন মডেল লঞ্চ হলে এই alias আপডেট করে দেয়,
/// তাই আমাদের কোডে ভার্সন নম্বর হার্ডকোড করার দরকার নেই।
class GeminiService {
  GeminiService._();

  static const String _apiKeyPref = 'gemini_api_key';

  // 🔧 Google-এর অফিসিয়াল "সবসময় লেটেস্ট Flash" alias
  static const String _model = 'gemini-flash-latest';

  static Uri _generateEndpoint(String apiKey) => Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$apiKey',
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
  }

  static Future<void> clearApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_apiKeyPref);
  }

  // ---------------------------------------------------------------------
  // Gemini-কে অনুরোধ পাঠিয়ে স্ট্রাকচার্ড JSON রেসপন্স নেওয়া
  // ---------------------------------------------------------------------

  static Future<Map<String, dynamic>> generateJson(String prompt) async {
    final apiKey = await getApiKey();
    if (apiKey == null) {
      throw AiException(
        'AI Key সক্রিয় নেই। অনুগ্রহ করে সাইড মেনু থেকে 🤖 AI Settings এ গিয়ে '
        'আপনার ফ্রি Gemini API Key সেট করে নিন।',
      );
    }

    http.Response response;
    try {
      response = await http
          .post(
            _generateEndpoint(apiKey),
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
