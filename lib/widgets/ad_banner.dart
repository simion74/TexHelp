import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// প্রতিটি ক্যালকুলেটর স্ক্রিনের একদম নিচে বসার জন্য Google AdMob
/// ব্যানার বিজ্ঞাপন উইজেট।
///
/// - সাইজ এখন **Anchored Adaptive Banner** ব্যবহার করা হচ্ছে, যা ডিভাইসের
///   প্রকৃত স্ক্রিন width অনুযায়ী automatic ফুল-উইথ হয়ে সেট হয়।
///   ফলে দুই পাশে আর কোনো ফাঁকা জায়গা থাকবে না, এবং height-ও ডিভাইস
///   অনুযায়ী optimize (সাধারণত ৫০-৯০dp) হয়ে প্রফেশনাল দেখাবে।
/// - টেস্ট Ad Unit ID ব্যবহার করা হয়েছে (Google-এর অফিসিয়াল টেস্ট আইডি)।
///   প্রোডাকশনে যাওয়ার আগে নিজের আসল AdMob Ad Unit ID বসিয়ে নিন।
class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

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
  bool _isLoading = false;

  // যতক্ষণ অ্যাড লোড না হয় (বা লোড fail করে), ততক্ষণ placeholder-এর
  // হাইট হিসেবে এটা ব্যবহার হবে যাতে লে-আউট না লাফায়।
  double _placeholderHeight = 50.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // MediaQuery এখানে ব্যবহারযোগ্য, তাই adaptive size লোড এখানেই করা হচ্ছে।
    if (!_isLoading) {
      _isLoading = true;
      _loadBanner();
    }
  }

  Future<void> _loadBanner() async {
    // ওয়েব বা অন্য কোনো আনসাপোর্টেড প্ল্যাটফর্মে ক্র্যাশ এড়াতে
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) return;

    // স্ক্রিনের প্রকৃত width (logical pixels) বের করা হচ্ছে
    final width = MediaQuery.sizeOf(context).width.truncate();

    // ডিভাইসের width অনুযায়ী Anchored Adaptive Banner সাইজ চাওয়া হচ্ছে।
    // এটা async কারণ AdMob SDK সাইজটা নেটওয়ার্ক/ডিভাইস তথ্য দেখে ক্যালকুলেট করে।
    final AdSize? adaptiveSize =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);

    if (adaptiveSize == null) {
      // সাইজ না পেলে ফিক্সড AdSize.banner (320x50) ফলব্যাক হিসেবে ব্যবহার হবে
      _createAndLoadBanner(AdSize.banner);
      return;
    }

    if (mounted) {
      setState(() => _placeholderHeight = adaptiveSize.height.toDouble());
    }
    _createAndLoadBanner(adaptiveSize);
  }

  void _createAndLoadBanner(AdSize size) {
    final banner = BannerAd(
      adUnitId: AdBannerWidget._adUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
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
    // ১. যদি আসল এড সফলভাবে লোড হয়, তবে এডটি দেখাবে (ফুল উইথ, অ্যাডাপটিভ হাইট)
    if (_isLoaded && _bannerAd != null) {
      return Container(
        height: _bannerAd!.size.height.toDouble(),
        width: double.infinity,
        alignment: Alignment.center,
        child: SizedBox(
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        ),
      );
    }

    // ২. ডিজাইন ও এডিটের সুবিধার্থে এড লোড না হলেও এই প্লেসহোল্ডার কন্টেইনারটি শো করবে
    return Container(
      height: _placeholderHeight,
      width: double.infinity,
      color: Colors.amber.shade300, // সহজে চেনার জন্য উজ্জ্বল হলুদ রং
      alignment: Alignment.center,
      child: const Text(
        'AD BANNER PLACEHOLDER (Adaptive)',
        style: TextStyle(
          color: Colors.black87,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    /* 
    *** প্রোডাকশনে বা আসল অ্যাপ রিলিজের সময় ওপরের প্লেসহোল্ডার Container-টি মুছে 
    নিচের অংশটুকু আনকমেন্ট করে দেবেন:
    
    return const SizedBox.shrink(); 
    */
  }
}
