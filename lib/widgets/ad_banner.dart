import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// প্রতিটি ক্যালকুলেটর স্ক্রিনের একদম নিচে বসার জন্য Google AdMob
/// ব্যানার বিজ্ঞাপন উইজেট।
///
/// - সাইজ **Anchored Adaptive Banner** ব্যবহার করা হচ্ছে, যা ডিভাইসের
///   প্রকৃত স্ক্রিন width অনুযায়ী automatic ফুল-উইথ হয়ে সেট হয়, height-ও
///   ডিভাইস অনুযায়ী optimize (সাধারণত ৫০-৯০dp) হয়।
/// - 🔧 SAFETY CAP: যদি কোনো ডিভাইসে (সাধারণত খুব ছোট/অস্বাভাবিক স্ক্রিন)
///   adaptive height [maxAdaptiveHeight]-এর বেশি হয়ে যায়, তাহলে সেই
///   ডিভাইসে ফিক্সড ছোট সাইজ (AdSize.banner, 320x50) ফলব্যাক হিসেবে
///   ব্যবহার হবে — যাতে কিপ্যাড/মূল কন্টেন্ট বেশি squeeze না হয়। এই
///   ফলব্যাক শুধু ব্যতিক্রমী ছোট স্ক্রিনেই ঘটবে; সাধারণ/বড় স্ক্রিনে
///   সবসময় ফুল-উইথ adaptive banner-ই দেখাবে।
/// - টেস্ট Ad Unit ID ব্যবহার করা হয়েছে (Google-এর অফিসিয়াল টেস্ট আইডি)।
///   প্রোডাকশনে যাওয়ার আগে নিজের আসল AdMob Ad Unit ID বসিয়ে নিন।
class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  // 🔧 এই height-এর বেশি adaptive সাইজ এলে ফিক্সড ছোট ব্যানারে ফলব্যাক
  // হবে। প্রয়োজনে এই ভ্যালু বাড়ানো/কমানো যাবে।
  static const double maxAdaptiveHeight = 70.0;

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
    final AdSize? adaptiveSize =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);

    AdSize sizeToUse;
    if (adaptiveSize == null) {
      // সাইজ না পেলে ফিক্সড AdSize.banner (320x50) ফলব্যাক
      sizeToUse = AdSize.banner;
    } else if (adaptiveSize.height > AdBannerWidget.maxAdaptiveHeight) {
      // 🔧 SAFETY CAP: এই ডিভাইসে adaptive height অনেক বড় (ছোট/অস্বাভাবিক
      // স্ক্রিন) — কিপ্যাড/কন্টেন্ট squeeze এড়াতে ফিক্সড ছোট ব্যানারে যাচ্ছি
      sizeToUse = AdSize.banner;
    } else {
      sizeToUse = adaptiveSize;
    }

    if (mounted) {
      setState(() => _placeholderHeight = sizeToUse.height.toDouble());
    }
    _createAndLoadBanner(sizeToUse);
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
    // ১. যদি আসল এড সফলভাবে লোড হয়, তবে এডটি দেখাবে
    // (adaptive হলে ফুল-উইথ, cap-এর কারণে fallback হলে ছোট সাইজ কিন্তু
    // তখনো width: double.infinity কন্টেইনারের মাঝে center করা থাকবে)
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

    // ২. অ্যাড লোড না হওয়া পর্যন্ত (বা লোড fail করলে) এই খালি জায়গাটা দেখাবে —
    // height রিজার্ভ করে রাখা হয় যাতে অ্যাড লোড হওয়ার সময় লে-আউট হঠাৎ
    // লাফিয়ে না ওঠে, কিন্তু প্রোডাকশনে দৃশ্যমান কোনো ডিবাগ বক্স/টেক্সট
    // দেখানো হয় না।
    return SizedBox(
      height: _placeholderHeight,
      width: double.infinity,
    );
  }
}
