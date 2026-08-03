import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../widgets/ad_banner.dart';
import '../widgets/numeric_keypad.dart';

/// % Calculation — দুইটা মোড টগল করে ব্যবহার করা যায়:
///
/// 1) Find % — দুইটা সংখ্যার একটা আরেকটার কত % তা বের করে
///    (যেমন: Total 450, Value 430 → Value, Total-এর কত %)
///
/// 2) % to Value — একটা সংখ্যা ও একটা % দিয়ে আসল মান বের করে
///    (যেমন: Number 450, Percent 16% → ফলাফল)
///
/// উপরে পাশাপাশি দুইটা ট্যাব বাটন — যেটাতে ট্যাপ করবেন সেটাই এক্টিভ হয়ে
/// ইনপুট নেয়। প্রতিটা মোডের নিজস্ব আলাদা ইনপুট মান মনে রাখা হয়, তাই মোড
/// পাল্টালেও আগের টাইপ করা মান হারাবে না।
///
/// 🔧 এখানে নিচের ভ্যারিয়েবলগুলো বদলে সাইজ/স্পেসিং নিয়ন্ত্রণ করুন।
class PercentCalculatorScreen extends StatefulWidget {
  const PercentCalculatorScreen({super.key});

  @override
  State<PercentCalculatorScreen> createState() =>
      _PercentCalculatorScreenState();
}

enum _PercentMode { findPercent, percentToValue }

class _PercentCalculatorScreenState extends State<PercentCalculatorScreen> {
  // 🔧 সাইজ কনফিগারেশন
  static const double _headerIconSize = 17;
  static const double _headerTitleTopPadding = 29;
  static const double _tabBarHeight = 46;
  static const double _inputBoxHeight = 56;
  static const double _keypadHeight = 230;
  static const int _maxFieldLength = 9; // ইনপুটে সর্বোচ্চ কয় ক্যারেক্টার

  _PercentMode _mode = _PercentMode.findPercent;

  // ✏️ প্রতিটা মোডের জন্য আলাদা ২টা ইনপুট — মোড পাল্টালেও মান অক্ষত থাকে
  final Map<_PercentMode, List<String>> _values = {
    _PercentMode.findPercent: ['', ''], // [Total, Value]
    _PercentMode.percentToValue: ['', ''], // [Number, Percent]
  };

  // কোন মোডের কোন ফিল্ড (0 বা 1) বর্তমানে এক্টিভ (টাইপ করার জন্য)
  int _activeField = 0;

  List<String> get _current => _values[_mode]!;

  void _switchMode(_PercentMode mode) {
    setState(() {
      _mode = mode;
      _activeField = 0;
    });
  }

  void _selectField(int index) {
    setState(() => _activeField = index);
  }

  void _onDigit(String d) {
    setState(() {
      final field = _current[_activeField];
      if (d == '.' && field.contains('.')) return; // একবারই দশমিক বিন্দু
      if (field.length < _maxFieldLength) {
        _current[_activeField] = field + d;
      }
    });
  }

  void _onBackspace() {
    setState(() {
      final field = _current[_activeField];
      if (field.isNotEmpty) {
        _current[_activeField] = field.substring(0, field.length - 1);
      } else if (_activeField > 0) {
        _activeField--;
      }
    });
  }

  // কিপ্যাডের "C" — শুধু বর্তমান এক্টিভ ফিল্ড ক্লিয়ার করে
  void _onClearCurrent() {
    setState(() => _current[_activeField] = '');
  }

  // কিপ্যাডের up/down তীর — দুইটা ইনপুটের মধ্যে কার্সর সরায়
  void _moveActive(int direction) {
    final next = _activeField + direction;
    if (next >= 0 && next < _current.length) {
      setState(() => _activeField = next);
    }
  }

  // 🔁 বর্তমান এক্টিভ মোডের দুইটা ইনপুটই রিসেট হয়
  void _resetCurrentMode() {
    setState(() {
      _current[0] = '';
      _current[1] = '';
      _activeField = 0;
    });
  }

  double? _parse(String s) => double.tryParse(s);

  // 📊 লাইভ রেজাল্ট
  String get _resultText {
    if (_mode == _PercentMode.findPercent) {
      final total = _parse(_current[0]);
      final value = _parse(_current[1]);
      if (total == null || value == null || total == 0) return '—';
      final pct = (value / total) * 100;
      return '${pct.toStringAsFixed(2)} %';
    } else {
      final number = _parse(_current[0]);
      final percent = _parse(_current[1]);
      if (number == null || percent == null) return '—';
      final result = number * percent / 100;
      return result.toStringAsFixed(2);
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
                      const SizedBox(height: 8),
                      _buildModeTabs(),
                      const SizedBox(height: 12),
                      _buildInputFields(),
                      const SizedBox(height: 12),
                      _buildResultCard(),
                      const Spacer(),
                      // 🎹 আপনার ডিজাইন করা কাস্টম কিপ্যাড — সরাসরি লিংক
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/homeicon/percent_calculator.webp',
                  width: 30,
                  height: 30,
                ),
                const SizedBox(width: 8),
                const Text(
                  '% CALCULATION',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkGreen),
                ),
              ],
            ),
          ),
        ),
        // 🧹 Clear/Reset — বর্তমান এক্টিভ মোডের দুইটা ইনপুটই মুছে দেয়
        Material(
          color: Colors.white,
          shape: const CircleBorder(),
          elevation: 3,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: _resetCurrentMode,
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

  // 🔀 পাশাপাশি দুইটা মোড ট্যাব — যেটাতে ট্যাপ করবেন সেটাই এক্টিভ হয়ে
  // ব্যবহারযোগ্য হবে
  Widget _buildModeTabs() {
    return SizedBox(
      height: _tabBarHeight,
      child: Row(
        children: [
          Expanded(
            child: _tabButton(
              label: 'Find %',
              subtitle: 'কত % তা বের করুন',
              icon: Icons.percent_rounded,
              selected: _mode == _PercentMode.findPercent,
              onTap: () => _switchMode(_PercentMode.findPercent),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _tabButton(
              label: '% to Value',
              subtitle: '% থেকে মান বের করুন',
              icon: Icons.calculate_rounded,
              selected: _mode == _PercentMode.percentToValue,
              onTap: () => _switchMode(_PercentMode.percentToValue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabButton({
    required String label,
    required String subtitle,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: selected ? AppColors.darkGreen : Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: selected ? 3 : 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 16,
                  color: selected ? Colors.white : AppColors.darkGreen),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: selected ? Colors.white : AppColors.darkGreen,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 📥 এক্টিভ মোড অনুযায়ী ২টা লম্বা ইনপুট বক্স
  Widget _buildInputFields() {
    final labels = _mode == _PercentMode.findPercent
        ? const ['Total (100%)', 'Value']
        : const ['Number', 'Percent %'];
    final suffixes = _mode == _PercentMode.findPercent
        ? const [null, null]
        : const [null, '%'];

    return Column(
      children: List.generate(2, (i) {
        return Padding(
          padding: EdgeInsets.only(bottom: i == 0 ? 10 : 0),
          child: _inputBox(
            label: labels[i],
            value: _current[i],
            suffix: suffixes[i],
            selected: _activeField == i,
            onTap: () => _selectField(i),
          ),
        );
      }),
    );
  }

  Widget _inputBox({
    required String label,
    required String value,
    String? suffix,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: _inputBoxHeight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.green : AppColors.inputBorder,
            width: selected ? 1.8 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkGreen)),
            const Spacer(),
            Text(
              value.isEmpty ? '0' : value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: value.isEmpty
                    ? AppColors.darkGreen.withOpacity(0.3)
                    : AppColors.darkGreen,
              ),
            ),
            if (suffix != null)
              Padding(
                padding: const EdgeInsets.only(left: 3),
                child: Text(suffix,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkGreen.withOpacity(0.6))),
              ),
          ],
        ),
      ),
    );
  }

  // ✅ রেজাল্ট কার্ড — ডায়নামিকভাবে আপডেট হয়
  Widget _buildResultCard() {
    final resultLabel = _mode == _PercentMode.findPercent
        ? 'Value is this % of Total'
        : 'Result';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.darkGreen,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.green.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Text(resultLabel,
              style: const TextStyle(color: Colors.white70, fontSize: 11.5)),
          const SizedBox(height: 6),
          Text(
            _resultText,
            style: const TextStyle(
                color: Colors.greenAccent,
                fontSize: 30,
                fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
