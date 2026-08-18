# TexHelp — Flutter Android App

**টেক্সটাইল ও গার্মেন্টস ইন্ডাস্ট্রির জন্য অল-ইন-ওয়ান ক্যালকুলেটর ও রেফারেন্স অ্যাপ।**
স্পিনিং, নিটিং/উইভিং, ডাইং-ফিনিশিং, গার্মেন্টস/কাটিং-সুইং ও কস্টিং — প্রতিটি
ডিপার্টমেন্টের দরকারি ফর্মুলা একটাই অ্যাপে, সাথে AI-পাওয়ারড আইডেন্টিফিকেশন
টুলও আছে।

> ⚠️ এই README প্রজেক্টের **বর্তমান কোড দেখে** নতুন করে লেখা হয়েছে (আগের
> ভার্সনে মাত্র ৭টা ক্যালকুলেটরের কথা লেখা ছিল, যেটা অনেক আগেই পুরনো
> হয়ে গিয়েছিল)।

---

## ✨ মূল ফিচার

### ১. ৬০+ ক্যালকুলেটর, ৬টি ডিপার্টমেন্টে ভাগ করা
Spinning · Knitting · Dyeing · Finishing · Garments · Printing · Testing —
হোম স্ক্রিনে ডিপার্টমেন্ট-ভিত্তিক ফিল্টার চিপ দিয়ে সহজে খুঁজে বের করা যায়।
এর মধ্যে আছে (উদাহরণস্বরূপ):

- **কমন**: Calculator, Percent Calculator, Meter/Yard/Feet, MM/CM/Inch
- **ফেব্রিক/নিটিং**: Fabric GSM, Fabric Weight, GSM (Without Cutter),
  GSM (By Yarn Count), Average GSM, Fabric Consumption, Fabric Crimp,
  Stitch Density, Tightness Factor, Knitting Production, Body to Rib
  Fabric Ratio, Yarn to Knit Fabric
- **ইয়ার্ন/স্পিনিং**: Yarn Requirement, Yarn Count Converter, Yarn Weight,
  Yarn Consumption, Twist Calculator, Hank Count, Draft Calculator,
  CSP Calculator, Blend Ratio, Warp Yarn Requirement, Loom Production
- **ডাইং/ফিনিশিং**: Shrinkage Measurement, Process Loss, Liquor Ratio,
  Dye Recipe, Chemical Dosing, Chemical Add-on, Wet Pickup, GSM Change
- **গার্মেন্টস/কোয়ালিটি**: 4 Point Inspection, DHU Calculator, RFT
  Calculator, AQL Sampling, Seam Efficiency, Cutting Wastage, SAM/SMV,
  Hourly Target, Line Efficiency, Marker Efficiency, Marker Consumption
- **কস্টিং**: CM Costing, Profit/Markup, Costing Sheet, Cutting Sheet,
  Carton/CBM
- **কনভার্টার**: Stripe Size Converter, Twisting Measurement, Moisture %,
  Length Unit Converter, Small Measurement Converter

সম্পূর্ণ লিস্ট ও প্রতিটি আইকনের পাথ `lib/data/calc_menu_items.dart`-এ।

### ২. রেফারেন্স লাইব্রেরি (AI-সাপোর্টেড সার্চ সহ)
- **Machine Library** — টেক্সটাইল মেশিনের ছবি, ফাংশন, ব্যাখ্যা
- **Chemical Library** — ডাইং/ফিনিশিং কেমিক্যালের ডেটাবেজ, ক্যাটাগরি ফিল্টার
- **Lab Test** — ফেব্রিক/গার্মেন্টস ল্যাব টেস্টের স্ট্যান্ডার্ড মেথড, রেজাল্ট
  ইভ্যালুয়েশন ইত্যাদি
- **Fabric Fault** ও **Fabric Type** — ফল্ট/ফেব্রিক টাইপ আইডেন্টিফিকেশন

এই লাইব্রেরিগুলোতে **ফাজি সার্চ** (`lib/utils/fuzzy_search.dart`) কাজ করে, আর
সার্চে কিছু না মিললে ইউজারের নিজের **Gemini API Key** দিয়ে AI-এর কাছে জিজ্ঞেস
করার অপশন আছে (`lib/services/gemini_service.dart`)।

### ৩. AI ফিচার (Gemini)
সাইড মেনু → **AI Settings**-এ গিয়ে ইউজার নিজের ফ্রি Gemini API Key বসাতে
পারে (ডিভাইসেই সেভ থাকে, কোথাও পাঠানো হয় না)। এরপর Fabric Fault, Fabric
Type, Machine Library, Chemical Library-এ AI-বেসড রেজাল্ট পাওয়া যায়।

### ৪. Export
রেজাল্ট **Excel, PDF, ও Image** হিসেবে এক্সপোর্ট/শেয়ার করা যায়
(`lib/services/export_service.dart` — প্যাকেজ: `excel`, `pdf`, `printing`,
`share_plus`)।

### ৫. Favorites
প্রিয় ক্যালকুলেটরগুলো Favorites-এ পিন করে হোম স্ক্রিনের উপরে রাখা যায়
(`lib/services/favorites_service.dart`, `favorites_settings_screen.dart`)।

### ৬. Home Screen ও Side Menu
- হ্যামবার্গার আইকন ট্যাপ বা সোয়াইপ করে সাইড মেনু খোলে/বন্ধ হয়
- About, Share, Rate Me, More Apps, Privacy Policy, AI Settings, Exit
- প্রতিটি ক্যালকুলেটর স্ক্রিনের নিচে AdMob ব্যানার (adaptive size)

---

## 📁 ফোল্ডার স্ট্রাকচার

```
lib/
  main.dart                  -> App entry point, AdMob init
  theme/app_colors.dart      -> সব কালার/গ্রেডিয়েন্ট একজায়গায়
  models/keypad_controller.dart
  data/
    calc_menu_items.dart     -> হোম গ্রিডের সব ক্যালকুলেটরের মাস্টার লিস্ট
    department.dart          -> ডিপার্টমেন্ট (Spinning/Knitting/... ) লিস্ট
    chemical_data.dart, fabric_fault_data.dart, fabric_type_data.dart,
    lab_test_data.dart, machine_library_data.dart
  services/
    gemini_service.dart      -> Gemini API কল, key সেভ/লোড
    export_service.dart      -> Excel/PDF/Image export
    favorites_service.dart   -> Favorites সেভ/লোড
  utils/fuzzy_search.dart
  widgets/                   -> CalcScaffold, InputCard, ResultBox,
                                 NumericKeypad, AdBannerWidget, ইত্যাদি
  screens/                   -> ৬৯টি স্ক্রিন (প্রতিটি ক্যালকুলেটর/লাইব্রেরির
                                 নিজের ফাইল)
assets/
  homeicon/        -> হোম গ্রিডের আইকন
  images/           -> ব্যাকগ্রাউন্ড, AI আইকন ইত্যাদি
  images/Lab/       -> Lab Test-এর ছবি
  images/fabrics/, images/machines/
  icon/             -> app_icon (launcher icon সোর্স)
  Fabric_fault_image/, Ready_garments_fault_image/
```

নতুন ক্যালকুলেটর যোগ করতে:
1. `lib/screens/`-এ বিদ্যমান কোনো একটা স্ক্রিন কপি করে ফর্মুলা বদলান
   (`CalcScaffold`, `InputCard`, `ResultBox`, `NumericKeypad`,
   `KeypadFieldController` রেডি আছে)।
2. `lib/data/calc_menu_items.dart`-এ import + `CalcItem` এন্ট্রি যোগ করুন।

---

## 🚀 রান করার নিয়ম

```bash
flutter pub get
flutter run
```

Release APK/App Bundle বানাতে:

```bash
flutter build apk --release
# অথবা Play Store-এর জন্য:
flutter build appbundle --release
```

> `android/` ও `ios/` — দুটো নেটিভ ফোল্ডারই প্রজেক্টে আছে। শুধু Android
> টার্গেট করলে `ios/` নিয়ে মাথা ঘামানোর দরকার নেই, কিছু বিল্ড টুল
> (যেমন FlutLab) validation-এর জন্য এটা চায়, তাই রেখে দেওয়া হয়েছে।

---

## ✅ Play Store-এ পাবলিশ করার আগে চেকলিস্ট

কোড রিভিউ করে যা যা এখনও **করা বাকি** পাওয়া গেছে, প্রকাশ করার আগে এগুলো
সারিয়ে নিন:

- [ ] **AdMob real ID বসান** — `lib/widgets/ad_banner.dart`-এর
      `_androidTestUnitId` / `_iosTestUnitId` এবং
      `android/app/src/main/AndroidManifest.xml`-এর
      `com.google.android.gms.ads.APPLICATION_ID` — এখনও Google-এর
      **টেস্ট আইডি** বসানো আছে, নিজের AdMob অ্যাকাউন্টের আসল আইডি দিয়ে
      পরিবর্তন করুন।
- [ ] **অ্যাড প্লেসহোল্ডার বন্ধ করুন** — `ad_banner.dart`-এর
      `build()`-এ এখনও হলুদ "AD BANNER PLACEHOLDER" `Container` অ্যাক্টিভ
      আছে; নিচে কমেন্ট করা `return const SizedBox.shrink();` অংশটা
      আনকমেন্ট করে আসল প্লেসহোল্ডার-বক্সটা মুছে দিন।
- [ ] **ভাঙা ছবি ঠিক করুন** — `assets/images/Lab/zipper_strength - Copy.webp`
      ফাইলটার নাম বদলে `zipper_strength.webp` করুন (অথবা
      `lib/data/lab_test_data.dart`-এ পাথ আপডেট করুন), নাহলে Zipper
      Strength টেস্টে ব্রোকেন ইমেজ দেখাবে।
- [ ] **অব্যবহৃত Camera পারমিশন সরান** — `pubspec.yaml`-এ `camera` ও
      `google_mlkit_text_recognition` প্যাকেজ এবং
      `AndroidManifest.xml`-এ CAMERA পারমিশন আছে, কিন্তু কোথাও কোনো
      ক্যামেরা/OCR ফিচার লেখা হয়নি। GSM Scanner ফিচার বানানোর প্ল্যান
      না থাকলে দুটো প্যাকেজ + পারমিশন সরিয়ে ফেলুন (App সাইজ কমবে, Play
      Store রিভিউতেও ঝামেলা কম হবে)।
- [ ] **`mounted` চেক যোগ করুন** — `fabric_fault_screen.dart`,
      `fabric_type_screen.dart`, `machine_library_screen.dart`,
      `favorites_settings_screen.dart`-এ Gemini AI কলের পর `setState()`
      করার আগে `if (!mounted) return;` যোগ করুন, নাহলে ইউজার রেসপন্স
      আসার আগে স্ক্রিন থেকে বেরিয়ে গেলে অ্যাপ ক্র্যাশ করতে পারে।
- [ ] **রুট ফোল্ডারের এতিম ফাইল মুছুন** — `ad_banner.dart` ও
      `chemical_screen.dart` (এগুলো `lib/`-এর বাইরে, বিল্ডে ব্যবহার হয় না,
      কিন্তু পুরনো/ভিন্ন কোড রয়ে গেছে বলে কনফিউশন তৈরি করতে পারে)।
- [ ] **About / Share / Rate Me / More Apps / Privacy Policy** এখনও
      placeholder ডায়ালগ দেখায়। বাস্তব লিংক বসাতে
      `lib/screens/home_screen.dart`-এ:
      - **Share**: `Share.share('আমার অ্যাপটি দেখুন: <Play Store লিংক>')`
      - **Rate Me / More Apps / Privacy Policy**:
        `launchUrl(Uri.parse('<লিংক>'))`
      - **Exit**: `SystemNavigator.pop()`
        (`import 'package:flutter/services.dart';`)

---

## 📦 মূল Dependency

| প্যাকেজ | কাজ |
|---|---|
| `google_mobile_ads` | AdMob ব্যানার বিজ্ঞাপন |
| `http` + `shared_preferences` | Gemini AI কল + API key সেভ |
| `excel`, `pdf`, `printing`, `share_plus` | রেজাল্ট এক্সপোর্ট/শেয়ার |
| `url_launcher` | About/Rate/More Apps লিংক ওপেন |
| `camera`, `google_mlkit_text_recognition` | *(যোগ করা আছে, বর্তমানে অব্যবহৃত — উপরের চেকলিস্ট দেখুন)* |
