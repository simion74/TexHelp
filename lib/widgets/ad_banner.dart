import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// প্রতিটি ক্যালকুলেটর স্ক্রিনের একদম নিচে বসার জন্য Google AdMob
/// ব্যানার বিজ্ঞাপন উইজেট।
///
/// - সাইজ সবসময় ফিক্সড রাখা হয়েছে: height = 50.0, width = double.infinity
///   (স্ট্যান্ডার্ড মোবাইল ব্যানার), যাতে অ্যাড লোড হওয়ার আগে/পরে
///   লে-আউট হঠাৎ লাফিয়ে/ভেঙে না যায়।
/// - টেস্ট Ad Unit ID ব্যবহার করা হয়েছে (Google-এর অফিসিয়াল টেস্ট আইডি)।
///   প্রোডাকশনে যাওয়ার আগে নিজের আসল AdMob Ad Unit ID বসিয়ে নিন।
class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  static const double bannerHeight = 50.0;

  // Google-এর অফিসিয়াল টেস্ট ব্যানার Ad Unit ID।
  // *** প্রোডাকশনে রিলিজ দেওয়ার আগে এই আইডিগুলো অবশ্যই বদলে
  // নিজের AdMob অ্যাকাউন্টের আসল Ad Unit ID দিন। ***
  static const String _androidTestUnitId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _iosTestUnitId = 'ca-app-pub-3940256099942544/2934735716';

  static String get _adUnitId =>
      Platform.isIOS ? _iosTestUnitId : _androidTestUnitId;

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  void _loadBanner() {
    // ওয়েব বা অন্য কোনো আনসাপোর্টেড প্ল্যাটফর্মে ক্র্যাশ এড়াতে
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) return;

    final banner = BannerAd(
      adUnitId: AdBannerWidget._adUnitId,
      size: AdSize.banner, // 320x50 - স্ট্যান্ডার্ড মোবাইল ব্যানার
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) return;
          setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );
    _bannerAd = banner;
    banner.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ১. যদি আসল এড সফলভাবে লোড হয়, তবে এডটি দেখাবে
    if (_isLoaded && _bannerAd != null) {
      return Container(
        height: AdBannerWidget.bannerHeight,
        width: double.infinity,
        alignment: Alignment.center,
        child: SizedBox(
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        ),
      );
    }

    // ২. ডিজাইন ও এডিটের সুবিধার্থে এড লোড না হলেও অলটাইম ৫০ হাইটের এই কন্টেইনারটি শো করবে
    return Container(
      height: AdBannerWidget.bannerHeight,
      width: double.infinity,
      color: Colors.amber.shade300, // সহজে চেনার জন্য উজ্জ্বল হলুদ রং
      alignment: Alignment.center,
      child: const Text(
        'AD BANNER PLACEHOLDER (50px)',
        style: TextStyle(
          color: Colors.black87,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    /* 
    *** প্রোডাকশনে বা আসল অ্যাপ রিলিজের সময় ওপরের প্লেসহোল্ডার Container-টি মুছে 
    নিচের অংশটুকু আনকমেন্ট করে দেবেন:
    
    return const SizedBox.shrink(); 
    */
  }
}
