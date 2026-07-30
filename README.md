# TexHelp — Flutter Android App

## 🆕 সর্বশেষ আপডেট (এই সংস্করণে যা যা করা হয়েছে)

- **Home Screen** ও **Side Menu**-এর ব্যাকগ্রাউন্ডে আপনার দেওয়া নতুন ছবি
  (`assets/images/home_bg.png`, `assets/images/side_menu_bg.jpg`) বসানো
  হয়েছে, সুন্দরভাবে ক্রপ/ফিট করে (`BoxFit.cover`)।
- **অ্যাপ আইকন সম্পূর্ণ পরিবর্তন**: পুরনো আইকন ডিলিট করে আপনার দেওয়া নতুন
  সেলাই-থিমের আইকন বসানো হয়েছে —
  - `assets/icon/app_icon.png` — স্কয়ার/রাউন্ড-কর্নার ভার্সন (হোম পেজের টপ বারে ব্যবহৃত)
  - `assets/icon/app_icon_round.png` — গোল ভার্সন (সাইড মেনুর লোগোতে ব্যবহৃত)
  - Android (`mipmap-*`) এবং iOS (`AppIcon.appiconset`) — দুই জায়গার
    আসল লঞ্চার আইকনও রিজেনারেট করে বসানো হয়েছে, তাই আলাদা করে
    `flutter_launcher_icons` চালানোর দরকার নেই।
- **Home গ্রিড** এখন উদাহরণ ডিজাইনের মতো ৩টি করে এক লাইনে (৩ কলাম), গোল
  গ্রেডিয়েন্ট আইকন + টাইটেল + রঙিন আন্ডারলাইন সহ।
- **সাইড মেনু** এখন হাত দিয়ে সোয়াইপ করে খোলা/বন্ধ করা যায় (বাম কিনারা থেকে
  ডানে সোয়াইপ করলে খুলবে, মেনু খোলা অবস্থায় বামে সোয়াইপ করলে বন্ধ হবে) —
  পাশাপাশি হ্যামবার্গার (☰) বাটনও আগের মতোই কাজ করে।
- **প্রতিটি ক্যালকুলেটর স্ক্রিনের নিচে Google AdMob ব্যানার**: `height: 50.0`,
  `width: double.infinity` — `lib/widgets/ad_banner.dart`-এ বানানো হয়েছে এবং
  `lib/widgets/calc_scaffold.dart`-এ যুক্ত করা হয়েছে (সব স্ক্রিন শেয়ার করে
  বলে একবার যোগ করলেই সবগুলোতে চলে এসেছে)। এখন Google-এর **টেস্ট Ad Unit
  ID** বসানো আছে — Play Store/App Store-এ প্রকাশ করার আগে অবশ্যই
  `lib/widgets/ad_banner.dart`-এর `_androidTestUnitId` / `_iosTestUnitId`
  এবং `AndroidManifest.xml` / `Info.plist`-এর App ID নিজের AdMob অ্যাকাউন্টের
  আসল আইডি দিয়ে বদলে নিন, নাহলে রিয়েল বিজ্ঞাপন দেখাবে না।
- অ্যাডের জন্য জায়গা রাখতে হেডার/ইনপুট-কার্ডের মাঝের গ্যাপ সামান্য কমানো
  হয়েছে, এবং কন্টেন্ট এরিয়া এখন প্রয়োজনে হালকা স্ক্রল হতে পারে (স্বাভাবিক
  অবস্থায় বোঝা যাবে না) — যাতে কোনো স্ক্রিনে অ্যাড দেখানোর সময় লে-আউট
  ভেঙে/ওভারফ্লো না হয়।
- **নতুন dependency**: `pubspec.yaml`-এ `google_mobile_ads` যোগ করা হয়েছে —
  চালানোর আগে `flutter pub get` দিতে ভুলবেন না।

---


আপনার ৭টি HTML ক্যালকুলেটর একটি Flutter প্রজেক্টে কনভার্ট করা হয়েছে, যেখানে
কমন ডিজাইন (হেডার, ইনপুট কার্ড, রেজাল্ট বক্স, কিপ্যাড, কালার) একবার লেখা হয়েছে
এবং সবগুলো ক্যালকুলেটর স্ক্রিন সেটাই রিইউজ করে — তাই কোড অনেক ছোট ও সহজে
মেইনটেইন করা যায়।

## যা যা করা হয়েছে

- **Home Screen**: বাম পাশে ৩-লাইন (☰) আইকন — ট্যাপ করলে সাইড মেনু খোলে,
  আবার ট্যাপ করলে বন্ধ হয়। মেনুতে About, Share, Rate Me, More Apps,
  Privacy Policy, Exit আছে (এখন প্লেসহোল্ডার ডায়ালগ দেখায়, নিচে দেখুন কীভাবে
  আসল লিংক বসাবেন)।
- Home গ্রিডে ৭টি ক্যালকুলেটর + Exit (মোট ৮টি বক্স-টাইপ কার্ড)। নতুন
  ক্যালকুলেটর যোগ করতে চাইলে `lib/screens/home_screen.dart`-এর `_items`
  লিস্টে একটা এন্ট্রি বাড়ালেই হবে।
- **৭টি ক্যালকুলেটর স্ক্রিন** (মূল হিসাবের সূত্র হুবহু আপনার HTML থেকে নেওয়া):
  - 4 Point Fabric Inspection
  - Fabric Calculator (Length/Width/GSM/Weight — যেকোনো ৩টি দিলে ৪র্থটি বের হয়)
  - Shrinkage Measurement (Length%, Width%, Spirality%)
  - Stripe Size Converter (mm/cm/inch/feeder + CPI গাইড)
  - Yarn Requirement (Wastage % সহ)
  - Yarn Count Converter (Ne/Denier/Tex/Nm)
  - Fabric Consumption (Per Dozen)
- প্রতিটি ক্যালকুলেটর স্ক্রিনে `assets/images/bg_frame.png` (আপনার দেওয়া
  green-wave ডিজাইন) ব্যাকগ্রাউন্ড হিসেবে বসানো আছে। **Home Screen-এ এই
  ব্যাকগ্রাউন্ড নেই** — আপনি যেমন বলেছিলেন সেভাবেই আলাদা ডিজাইন করা হয়েছে।
- কিপ্যাড, ইনপুট কার্ড, বাটন সব আগের চেয়ে বড় ও টাচ-ফ্রেন্ডলি সাইজে বানানো
  হয়েছে যেন মোবাইলে দ্রুত ও আরামে ব্যবহার করা যায়।

> **নোট:** FlutLab-এর মতো অনলাইন বিল্ড টুল Flutter প্রজেক্ট চিনতে `android/`
> এবং `ios/` — দুটো নেটিভ ফোল্ডারই খোঁজে, তাই দুটোই এই প্রজেক্টে যোগ করা
> আছে। আপনি যেহেতু শুধু Android অ্যাপ বানাচ্ছেন, `ios/` ফোল্ডারটা শুধু
> আপলোড ভ্যালিডেশন পাশ করার জন্য দরকার — এটার ভেতরের কিছু নিয়ে মাথা
> ঘামানোর দরকার নেই, শুধু build/upload-এর সময় ফোল্ডারটা রেখে দিন।

## ফোল্ডার স্ট্রাকচার

```
lib/
  main.dart
  theme/app_colors.dart          -> সব কালার/গ্রেডিয়েন্ট একজায়গায়
  models/keypad_controller.dart  -> কমন কিপ্যাড লজিক (active field, digit, backspace...)
  widgets/
    calc_scaffold.dart   -> হেডার + ব্যাকগ্রাউন্ড + রিসেট বাটন + কিপ্যাড স্লট
    input_card.dart      -> ইনপুট রো (আইকন + লেবেল + ভ্যালু + ইউনিট)
    result_box.dart      -> রেজাল্ট বক্স
    numeric_keypad.dart  -> কাস্টম নিউমেরিক কিপ্যাড
  screens/
    home_screen.dart
    four_point_screen.dart
    fabric_calculator_screen.dart
    shrinkage_screen.dart
    stripe_converter_screen.dart
    yarn_requirement_screen.dart
    yarn_count_converter_screen.dart
    fabric_consumption_screen.dart
assets/
  images/bg_frame.png   -> আপনার আপলোড করা green-wave ব্যাকগ্রাউন্ড
  icon/app_icon.png     -> আপনার অ্যাপ আইকন (লঞ্চার আইকন বসাতে ব্যবহার করুন)
```

## কীভাবে রান করবেন (ধাপে ধাপে)

আমার sandbox-এ Flutter SDK ইনস্টল করা নেই, তাই আমি সরাসরি `flutter run` করে
টেস্ট করতে পারিনি। তাই নিচের ধাপগুলো আপনার নিজের কম্পিউটারে করুন:

1. আপনার কম্পিউটারে Flutter ইনস্টল থাকতে হবে (না থাকলে flutter.dev থেকে ইনস্টল করুন)।
2. একটি নতুন প্রজেক্ট বানান (এটা android/ios ফোল্ডার তৈরি করে দেবে):
   ```
   flutter create texhelp
   ```
3. নতুন তৈরি হওয়া `texhelp` ফোল্ডারের ভেতরের `lib/`, `pubspec.yaml`, `assets/`
   — এই তিনটা এই zip-এর ভার্সন দিয়ে রিপ্লেস করে দিন।
4. তারপর:
   ```
   cd texhelp
   flutter pub get
   flutter run
   ```
5. Android APK বানাতে:
   ```
   flutter build apk --release
   ```

## অ্যাপ আইকন বসানো (আপনার দেওয়া ছবি দিয়ে)

`assets/icon/app_icon.png` ফাইলটা আপনার দেওয়া আইকন। লঞ্চার আইকন হিসেবে
বসাতে `flutter_launcher_icons` প্যাকেজ ব্যবহার করুন:

1. `pubspec.yaml`-এ `dev_dependencies`-এ যোগ করুন:
   ```yaml
   flutter_launcher_icons: ^0.13.1
   ```
   এবং নিচে (yaml-এর একদম শেষে) যোগ করুন:
   ```yaml
   flutter_launcher_icons:
     android: true
     ios: true
     image_path: "assets/icon/app_icon.png"
   ```
2. তারপর রান করুন:
   ```
   flutter pub get
   flutter pub run flutter_launcher_icons
   ```

## About / Share / Rate Me / More Apps / Privacy Policy বাস্তবে কাজ করানো

এখন এগুলো একটা তথ্যমূলক ডায়ালগ দেখায় (placeholder), যাতে আপনি বুঝতে পারেন কোথায়
বসবে। বাস্তব লিংক/অ্যাকশন যোগ করতে `pubspec.yaml`-এ কমেন্ট করা প্যাকেজ দুটো
আনকমেন্ট করুন:

```yaml
url_launcher: ^6.2.5
share_plus: ^7.2.1
```

এরপর `lib/screens/home_screen.dart`-এ `_showInfo(...)` কলগুলোর জায়গায়:

- **Share**: `Share.share('আমার অ্যাপটি দেখুন: <Play Store লিংক>')`
- **Rate Me**: `launchUrl(Uri.parse('<Play Store লিংক>'))`
- **More Apps**: `launchUrl(Uri.parse('<আপনার ডেভেলপার পেজ লিংক>'))`
- **Privacy Policy**: `launchUrl(Uri.parse('<আপনার প্রাইভেসি পলিসি লিংক>'))`
- **About**: শুধু টেক্সট ডায়ালগ রাখলেই চলবে, এখনকার মতোই।
- **Exit**: `SystemNavigator.pop()` (Android-এ অ্যাপ বন্ধ করার জন্য, `import 'package:flutter/services.dart';`)

## নতুন ক্যালকুলেটর যোগ করবেন কীভাবে

1. `lib/screens/` এ নতুন একটা screen ফাইল বানান, বিদ্যমান যেকোনো একটা
   (যেমন `yarn_requirement_screen.dart`) কপি করে edit করুন — `CalcScaffold`,
   `InputCard`, `ResultBox`, `NumericKeypad` এবং `KeypadFieldController`
   এমনিই রেডি আছে, শুধু আপনার হিসাবের সূত্র বসিয়ে দিন।
2. `home_screen.dart`-এর `_items` লিস্টে একটা `_CalcItem` যোগ করুন।

এতে প্রতিটা নতুন ক্যালকুলেটরের জন্য মাত্র একটা ফাইল লিখলেই হবে — ডিজাইন,
কিপ্যাড, কালার সবকিছু অটোমেটিক্যালি একই থাকবে।
