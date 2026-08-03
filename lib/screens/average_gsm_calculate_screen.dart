import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../widgets/ad_banner.dart';
import '../widgets/numeric_keypad.dart';

/// Average GSM Calculate — সম্পূর্ণ ম্যানুয়াল এন্ট্রি সিস্টেম (ক্যামেরা/OCR নেই)।
///
/// 🔝 সবার উপরে চিকন সেটিংস বার: Record GSM + Approved Range%(+/-) +
/// একটা Clear বাটন (শুধু এই সেটিংস মুছে দেয়, নিচের রোল এন্ট্রিতে হাত দেয় না)।
///
/// 📋 মাঝে অটো-নম্বরড এন্ট্রি গ্রিড — প্রতিটা কলামে সর্বোচ্চ ~৯/১০টা এন্ট্রি,
/// প্রথম এন্ট্রি শুরু হয় ডান সাইডের নিচ কোনা থেকে, তারপর টাইপ করার সাথে সাথে
/// আগের এন্ট্রিগুলো উপরের দিকে উঠতে থাকে (ছোট, ফিক্সড ফন্টে)। একটা কলাম
/// (৯/১০টা এন্ট্রি) ভরে গেলে পরের কলাম আবার নিচ থেকে উপরে ওঠা শুরু করে —
/// এভাবে ৩টা কলাম ভরে গেলে ৪টা কলাম হয়ে যায়, ইত্যাদি। প্রতিটা এন্ট্রি একবার
/// যে কলামে বসে সেখানেই স্থায়ী থাকে (আর কখনো এদিক-ওদিক জাম্প করে না)।
/// ৩টা ডিজিট টাইপ হলেই অটো পরের ঘরে (serial) চলে যায়, তাই আলাদা "Next"
/// বাটনের দরকার নেই। যেকোনো ঘরে ট্যাপ করলে বা কিপ্যাডের up/down তীর চেপে
/// কার্সর সরিয়ে ভুল এন্ট্রি ঠিক করা যায়। Record GSM + Range% সেট থাকলে
/// রেঞ্জের ভেতরের মান সবুজ, বাইরেরটা লাল — টাইপ করা মাত্রই।
///
/// 🔽 নিচে ফলাফল বার (Average / Finish Min–Max / Total Roll), এরপর আলাদা
/// "RESET ALL" বাটন (শুধু এন্ট্রি লিস্ট মুছে, উপরের Record/Range অক্ষত
/// থাকে), তারপর সবসময়-দৃশ্যমান কাস্টম কিপ্যাড, সবশেষে বিজ্ঞাপন।
///
/// 🔧 এখানে নিচের ভ্যারিয়েবলগুলো বদলে সাইজ/স্পেসিং/লিমিট নিয়ন্ত্রণ করুন।
class AverageGsmCalculateScreen extends StatefulWidget {
  const AverageGsmCalculateScreen({super.key});

  @override
  State<AverageGsmCalculateScreen> createState() =>
      _AverageGsmCalculateScreenState();
}

class _AverageGsmCalculateScreenState extends State<AverageGsmCalculateScreen> {
  // 🔧 সাইজ/লিমিট কনফিগারেশন
  static const double _headerIconSize = 17;
  static const double _headerTitleTopPadding = 29;
  static const double _settingsBarHeight = 46;
  static const int _maxRolls = 100; // সর্বোচ্চ কয়টা রোল এন্ট্রি করা যাবে
  // 📋 প্রতিটা কলামে সর্বোচ্চ কয়টা এন্ট্রি থাকবে — এটা ফিক্সড রাখায় একটা
  // এন্ট্রি একবার যে কলামে বসে, নতুন এন্ট্রি যোগ হলেও আর কখনো অন্য কলামে
  // জাম্প করবে না (আগে এটা ডাইনামিক ছিল বলেই এন্ট্রি এদিক-ওদিক যাচ্ছিল)।
  static const int _rowsPerColumn = 9;
  // 🔤 ফিক্সড ছোট ফন্ট — শুরু থেকেই একলাইনে (এক কলামে) ৯/১০টা এন্ট্রি আঁটে
  static const double _entryFontSize = 15;
  static const double _keypadHeight = 230;

  // ⚙️ Record GSM + Approved Range% — লাইভ (টাইপ করা মাত্রই কালার আপডেট
  // হয়, আলাদা "Save" বাটনের দরকার নেই)
  final TextEditingController _recordGsmController = TextEditingController();
  final TextEditingController _rangePlusController = TextEditingController();
  final TextEditingController _rangeMinusController = TextEditingController();

  // 📋 প্রতিটা রোলের GSM স্ট্রিং আকারে রাখা হচ্ছে (সর্বোচ্চ ৩ ডিজিট), যাতে
  // টাইপ করার সময় আংশিক মানও ("1", "12") দেখানো যায়। শুরুতে ১টা খালি ঘর।
  final List<String> _entries = [''];
  int _activeIndex = 0;

  // ↔️ এন্ট্রি গ্রিডের হরাইজন্টাল স্ক্রল কন্ট্রোলার — নতুন কলাম তৈরি হলে
  // অটো সবশেষ (সবচেয়ে ডান/সক্রিয়) কলামে স্ক্রল করে নিয়ে যায়
  final ScrollController _gridScrollController = ScrollController();

  @override
  void dispose() {
    _recordGsmController.dispose();
    _rangePlusController.dispose();
    _rangeMinusController.dispose();
    _gridScrollController.dispose();
    super.dispose();
  }

  double? get _recordGsm => double.tryParse(_recordGsmController.text);
  double get _rangePlus => double.tryParse(_rangePlusController.text) ?? 0;
  double get _rangeMinus => double.tryParse(_rangeMinusController.text) ?? 0;

  // 🧹 শুধু উপরের Record GSM + Range% সেটিংস মুছবে — নিচের এন্ট্রি
  // লিস্টে কোনো প্রভাব পড়বে না
  void _clearSettings() {
    setState(() {
      _recordGsmController.clear();
      _rangePlusController.clear();
      _rangeMinusController.clear();
    });
  }

  // ✅❌ একটা GSM মান approved রেঞ্জের ভেতরে আছে কিনা — Record GSM সেট না
  // থাকলে null (তখন ডিফল্ট কালো রঙে দেখাবে)
  bool? _isWithinRange(int gsm) {
    final record = _recordGsm;
    if (record == null) return null;
    final low = record * (1 - _rangeMinus / 100);
    final high = record * (1 + _rangePlus / 100);
    return gsm >= low && gsm <= high;
  }

  // 📊 লাইভ ক্যালকুলেশন — পূরণ করা এন্ট্রিগুলো নিয়ে হিসাব
  List<int> get _filledValues => _entries
      .where((e) => e.isNotEmpty)
      .map((e) => int.tryParse(e))
      .whereType<int>()
      .toList();

  double get _averageGsm {
    final values = _filledValues;
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  int get _minGsm =>
      _filledValues.isEmpty ? 0 : _filledValues.reduce((a, b) => a < b ? a : b);

  int get _maxGsm =>
      _filledValues.isEmpty ? 0 : _filledValues.reduce((a, b) => a > b ? a : b);

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  // ⌨️ ডিজিট চাপলে — বর্তমান এক্টিভ ঘরে যোগ হয়, ৩ ডিজিট পূর্ণ হলেই অটো
  // পরের ঘরে (serial) চলে যায়। প্রয়োজনে নতুন ঘর তৈরি হয় (সর্বোচ্চ সীমা
  // পর্যন্ত)।
  void _onDigit(String d) {
    if (!RegExp(r'^[0-9]$').hasMatch(d)) return; // দশমিক বাটন থাকলেও উপেক্ষা
    setState(() {
      if (_entries[_activeIndex].length < 3) {
        _entries[_activeIndex] += d;
      }
      if (_entries[_activeIndex].length == 3) {
        _advance();
      }
    });
  }

  void _advance() {
    if (_activeIndex == _entries.length - 1) {
      if (_entries.length < _maxRolls) {
        _entries.add('');
        _activeIndex++;
      } else {
        _showSnack('সর্বোচ্চ $_maxRolls টি রোল এন্ট্রি করা যায়।');
      }
    } else {
      _activeIndex++;
    }
  }

  void _onBackspace() {
    setState(() {
      if (_entries[_activeIndex].isNotEmpty) {
        _entries[_activeIndex] = _entries[_activeIndex]
            .substring(0, _entries[_activeIndex].length - 1);
      } else if (_activeIndex > 0) {
        _activeIndex--;
        if (_entries[_activeIndex].isNotEmpty) {
          _entries[_activeIndex] = _entries[_activeIndex]
              .substring(0, _entries[_activeIndex].length - 1);
        }
      }
    });
  }

  // কিপ্যাডের "C" — শুধু বর্তমান এক্টিভ ঘরটা ক্লিয়ার করে
  void _onClearCurrent() {
    setState(() => _entries[_activeIndex] = '');
  }

  // কিপ্যাডের up/down তীর — কার্সর আগের/পরের ঘরে সরায়
  void _moveActive(int direction) {
    final next = _activeIndex + direction;
    if (next >= 0 && next < _entries.length) {
      setState(() => _activeIndex = next);
    }
  }

  // গ্রিডের যেকোনো ঘরে ট্যাপ করলে — সেটাই এক্টিভ হয়ে যায়, ভুল হলে
  // backspace দিয়ে মুছে আবার টাইপ করা যায়
  void _selectEntry(int index) {
    setState(() => _activeIndex = index);
  }

  // 🔁 শুধু এন্ট্রি লিস্ট রিসেট হয় — উপরের Record GSM/Range অক্ষত থাকে
  void _resetAllEntries() {
    setState(() {
      _entries
        ..clear()
        ..add('');
      _activeIndex = 0;
    });
  }

  // ↔️ নতুন কলাম তৈরি হলে বা এন্ট্রি বাড়লে গ্রিড অটো সবশেষ (সক্রিয়) কলাম
  // পর্যন্ত স্ক্রল হয়ে যায়, যাতে ইউজার সবসময় যেখানে টাইপ করছে সেটাই দেখতে পায়
  void _scrollGridToEnd() {
    if (!_gridScrollController.hasClients) return;
    final maxExtent = _gridScrollController.position.maxScrollExtent;
    if ((_gridScrollController.offset - maxExtent).abs() > 1) {
      _gridScrollController.animateTo(
        maxExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light
          .copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        body: Column(
          children: [
            // স্ট্যাটাস বার স্ট্রিপ — বাকি ক্যালকুলেটর স্ক্রিনের মতোই
            Container(height: statusBarHeight, color: AppColors.darkGreen),
            Expanded(
              child: Container(
                // 🖼️ ব্যাগ্রাউন্ড ফ্রেম — বাকি সব স্ক্রিনের মতোই একই ফ্রেম
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/bg_frame.webp'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 6),
                  child: Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 6),
                      _buildSettingsBar(),
                      const SizedBox(height: 8),
                      Expanded(child: _buildEntriesGrid()),
                      const SizedBox(height: 8),
                      _buildResultBar(),
                      const SizedBox(height: 8),
                      _buildResetAllButton(),
                      const SizedBox(height: 8),
                      // 🎹 আপনার ডিজাইন করা কাস্টম কিপ্যাড — সরাসরি লিংক
                      // করা, সবসময় ভিজিবল (পপআপ নয়)
                      NumericKeypad(
                        height: _keypadHeight,
                        onDigit: _onDigit,
                        onBackspace: _onBackspace,
                        onClear: _onClearCurrent,
                        onUp: () => _moveActive(-1),
                        onDown: () => _moveActive(1),
                      ),
                      const SizedBox(height: 4),
                      const ClipRRect(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(10)),
                        child: AdBannerWidget(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Material(
          color: Colors.white,
          shape: const CircleBorder(),
          elevation: 3,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => Navigator.of(context).pop(),
            child: const Padding(
              padding: EdgeInsets.all(9),
              child: Icon(Icons.arrow_back_rounded,
                  color: AppColors.darkGreen, size: _headerIconSize),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: _headerTitleTopPadding),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/homeicon/average_gsm_calculate.webp',
                      width: 30,
                      height: 30,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'AVERAGE GSM CALCULATE',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkGreen),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Material(
          color: Colors.white,
          shape: const CircleBorder(),
          elevation: 3,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: _resetAllEntries,
            child: const Padding(
              padding: EdgeInsets.all(9),
              child: Icon(Icons.refresh_rounded,
                  color: AppColors.darkGreen, size: _headerIconSize),
            ),
          ),
        ),
      ],
    );
  }

  // ⚙️ সবার উপরে চিকন সেটিংস কন্টেইনার — Record GSM + Approved Range%(+/-)
  // + একটা Clear বাটন
  Widget _buildSettingsBar() {
    return Container(
      height: _settingsBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.inputBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _settingsLabel('Record GSM'),
          const SizedBox(width: 4),
          _settingsField(_recordGsmController, flex: 3),
          const SizedBox(width: 8),
          _settingsLabel('Range%'),
          const SizedBox(width: 4),
          _settingsField(_rangePlusController,
              flex: 2, prefix: '+', color: AppColors.green),
          const SizedBox(width: 4),
          _settingsField(_rangeMinusController,
              flex: 2, prefix: '-', color: Colors.red),
          const SizedBox(width: 8),
          Material(
            color: AppColors.green,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: _clearSettings,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Text('Clear',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: AppColors.darkGreen),
    );
  }

  Widget _settingsField(TextEditingController controller,
      {required int flex, String? prefix, Color? color}) {
    return Expanded(
      flex: flex,
      child: SizedBox(
        height: 32,
        child: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: false),
          textAlign: TextAlign.center,
          onChanged: (_) => setState(() {}), // লাইভ কালার রি-চেক
          style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: color ?? AppColors.darkGreen),
          decoration: InputDecoration(
            isDense: true,
            prefixText: prefix,
            prefixStyle: TextStyle(
                fontSize: 12.5, fontWeight: FontWeight.w800, color: color),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            filled: true,
            fillColor: AppColors.inputBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
              borderSide: BorderSide(color: AppColors.inputBorder),
            ),
          ),
        ),
      ),
    );
  }

  // 📋 এন্ট্রি গ্রিড — ফিক্সড ক্যাপাসিটির কলাম (প্রতি কলামে সর্বোচ্চ
  // _rowsPerColumn টা এন্ট্রি)। প্রথম এন্ট্রি একদম ডান সাইডের নিচ কোনা থেকে
  // শুরু হয়; নতুন এন্ট্রি টাইপ করলে সেটা সবসময় সক্রিয় কলামের একদম নিচে
  // বসে আর আগের এন্ট্রিগুলো ধীরে ধীরে উপরের দিকে উঠে যায়। একটা কলাম ভরে
  // গেলে তার ডান পাশে (কালানুক্রমিকভাবে পরের) নতুন কলাম তৈরি হয়ে সেটাও
  // আবার নিচ থেকে উপরে উঠতে থাকে। একটা এন্ট্রি একবার যে কলামে জায়গা পায়
  // (index ~/ _rowsPerColumn অনুযায়ী), সেখানেই স্থায়ী থাকে — নতুন এন্ট্রি
  // যোগ হলেও কখনো অন্য কলামে জাম্প করে না।
  Widget _buildEntriesGrid() {
    final total = _entries.length;
    final columnCount = (total / _rowsPerColumn).ceil().clamp(1, 999);

    final columns = List.generate(columnCount, (c) {
      final start = c * _rowsPerColumn;
      final end =
          (start + _rowsPerColumn) > total ? total : (start + _rowsPerColumn);
      return List.generate(end - start, (i) => start + i);
    });

    // নতুন কলাম/এন্ট্রি তৈরি হলে অটো সবশেষ (সক্রিয়) কলাম পর্যন্ত স্ক্রল
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollGridToEnd());

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFDFF6FB), // হালকা আকাশি ব্যাকগ্রাউন্ড
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            controller: _gridScrollController,
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              // কলামের সংখ্যা কম থাকলে (স্ক্রল লাগার আগে) পুরো ব্লকটা
              // ডান সাইডে চেপে রাখার জন্য ন্যূনতম প্রস্থ = ভিউপোর্ট প্রস্থ
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: SizedBox(
                height: constraints.maxHeight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: columns
                      .map((colIndices) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              // নিচ থেকে উপরে ওঠার এফেক্ট: নতুন এন্ট্রি
                              // সবসময় নিচে বসে, আগেরগুলো উপরে ঠেলে দেয়
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: colIndices
                                  .map((i) => _buildEntryCell(i))
                                  .toList(),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEntryCell(int index) {
    final text = _entries[index];
    final active = index == _activeIndex;
    final value = int.tryParse(text);
    final within = value != null ? _isWithinRange(value) : null;
    final valueColor = value == null
        ? AppColors.darkGreen
        : within == null
            ? Colors.black87
            : within
                ? AppColors.green
                : Colors.red;

    return InkWell(
      onTap: () => _selectEntry(index),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 1),
        padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 4),
        decoration: BoxDecoration(
          color:
              active ? AppColors.green.withOpacity(0.10) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${index + 1}.',
                style: TextStyle(
                    fontSize: _entryFontSize * 0.6,
                    color: Colors.black26,
                    fontWeight: FontWeight.w600)),
            const SizedBox(width: 4),
            Text(text,
                style: TextStyle(
                    fontSize: _entryFontSize,
                    fontWeight: FontWeight.w800,
                    color: valueColor,
                    height: 1.0)),
            if (active) _BlinkingCursor(fontSize: _entryFontSize),
          ],
        ),
      ),
    );
  }

  Widget _buildResultBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.darkGreen,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.green.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _resultStat('Average GSM', _averageGsm.toStringAsFixed(1),
              Colors.greenAccent),
          Container(width: 1, height: 32, color: Colors.white24),
          _resultStat(
              'Finish GSM (Min–Max)',
              _filledValues.isEmpty ? '0 – 0' : '$_minGsm – $_maxGsm',
              Colors.amberAccent),
          Container(width: 1, height: 32, color: Colors.white24),
          _resultStat(
              'Total Roll', '${_filledValues.length}', Colors.lightBlueAccent),
        ],
      ),
    );
  }

  Widget _resultStat(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 10)),
          const SizedBox(height: 3),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 17, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _buildResetAllButton() {
    return Material(
      color: AppColors.green,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: _resetAllEntries,
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 13),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('RESET ALL',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14.5,
                      letterSpacing: 0.4)),
            ],
          ),
        ),
      ),
    );
  }
}

// ⌨️ ব্লিংকিং কার্সর — বর্তমান এক্টিভ ঘরে দেখা যায়, ঠিক টেক্সট কার্সরের মতো
class _BlinkingCursor extends StatefulWidget {
  final double fontSize;
  const _BlinkingCursor({required this.fontSize});

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 2,
        height: widget.fontSize * 0.9,
        margin: const EdgeInsets.only(left: 2, bottom: 2),
        color: AppColors.green,
      ),
    );
  }
}
