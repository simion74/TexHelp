import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/calc_scaffold.dart';

/// সাধারণ ক্যালকুলেটর — যোগ, বিয়োগ, গুণ, ভাগ। একটা সাধারণ ক্যালকুলেটরের
/// মতোই বামদিক থেকে ডানদিকে ক্রমান্বয়ে হিসাব করে (যেমন সাধারণ মোবাইল
/// ক্যালকুলেটর করে) — জটিল BODMAS/অগ্রাধিকার নিয়ম নেই, এটা ইচ্ছাকৃত।
///
/// 🧾 এক্সপ্রেশন টেপ: পুরো হিসাবটা (আগের নম্বর/অপারেটর + এখন যা টাইপ
/// হচ্ছে) একটানা এক টেক্সট হিসেবে দেখানো হয় — ঠিক স্বাভাবিক
/// ক্যালকুলেটরের মতো (যেমন "120+125+" — শেষে কার্সর/নতুন সংখ্যা এখানেই
/// যোগ হতে থাকবে)। জায়গা কম পড়লে এই টেক্সট নিজে থেকেই র‍্যাপ করে
/// উপরের দিকে বাড়তে থাকে, সবশেষ এন্ট্রি সবসময় নিচেই দেখা যায়। "=" চাপার
/// পর রেজাল্টও এই একই টেক্সটের অংশ হয়ে যোগ হয় (যেমন "120+125=245"),
/// পরের হিসাব শুরু হলে নতুন লাইনে বসে। Clear ("C" বা হেডারের রিফ্রেশ
/// আইকন) চাপলে পুরো টেপ মুছে যায়।
class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _current = '0'; // এখন যা টাইপ হচ্ছে / রেজাল্ট
  double? _previousValue; // আগের সংরক্ষিত মান
  String? _pendingOp; // '+', '-', '×', '÷'
  bool _justEvaluated = false;

  // 🧾 এক্সপ্রেশন টেপ — পুরো হিসাবটা একটানা এক টেক্সট হিসেবে জমা হয়
  // (যেমন "120+125+45=290"), আলাদা আলাদা লাইনে ভাঙা হয় না। এটা
  // স্বাভাবিকভাবেই র‍্যাপ করে — জায়গা কম পড়লে টেক্সট এমনিতেই উপরের
  // দিকে বাড়তে থাকে (নিচে সবসময় সবশেষ এন্ট্রি দেখা যাবে)।
  String _tape = '';
  final ScrollController _historyScrollController = ScrollController();

  static const int _maxDigits = 12;

  // 🔧 ইনপুট/হিস্ট্রি কন্টেইনারের উচ্চতা — এটা বাড়ালে/কমালে পুরো
  // কন্টেইনারের সাইজ বদলাবে; হিস্ট্রি যত বড়ই হোক, বর্তমান ইনপুট সবসময়
  // একদম নিচেই থাকবে আর হিস্ট্রি তার উপরে স্ক্রলযোগ্য থাকবে
  static const double _displayHeight = 260;

  @override
  void dispose() {
    _historyScrollController.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _current = '0';
      _previousValue = null;
      _pendingOp = null;
      _justEvaluated = false;
      _tape = ''; // 🧹 ক্লিয়ার করলে পুরো টেপ মুছে যাবে
    });
  }

  String _formatNumber(double v) {
    if (v == v.roundToDouble() && v.abs() < 1e12) {
      return v.toInt().toString();
    }
    String s = v.toStringAsFixed(6);
    s = s.replaceFirst(RegExp(r'0+$'), '');
    s = s.replaceFirst(RegExp(r'\.$'), '');
    return s;
  }

  double _applyOp(double a, double b, String op) {
    switch (op) {
      case '+':
        return a + b;
      case '-':
        return a - b;
      case '×':
        return a * b;
      case '÷':
        return b == 0 ? double.nan : a / b;
      default:
        return b;
    }
  }

  // 🔴 লাইভ রানিং টোটাল — "=" না চাপলেও, একটা চেইন (যেমন 10 + 10 + ...)
  // চলাকালীন এখন পর্যন্ত টোটাল কত হতো তা লাইভ দেখায়। প্রতিটা ডিজিট
  // টাইপের সাথে সাথে এটা রি-ক্যালকুলেট হয় (build মেথড থেকেই কল হয়,
  // তাই আলাদা কোনো setState লাগে না)।
  double? get _liveTotal {
    if (_previousValue == null || _pendingOp == null || _justEvaluated) {
      return null;
    }
    final currentVal = double.tryParse(_current) ?? 0;
    return _applyOp(_previousValue!, currentVal, _pendingOp!);
  }

  // 🧾+🔢 টেপ + বর্তমান ইনপুট মিলিয়ে একটাই টেক্সট — ঠিক যেমন স্বাভাবিক
  // ক্যালকুলেটরে দেখায় (যেমন "102+123+450+")। "=" চাপার পরপরই রেজাল্ট
  // টেপে যোগ হয়ে যায় বলে সেটা আবার আলাদাভাবে দেখানোর দরকার হয় না।
  String get _displayText {
    final suffix = _justEvaluated ? '' : (_current == '0' ? '' : _current);
    final text = _tape + suffix;
    return text.isEmpty ? '0' : text;
  }

  // ↕️ নতুন কন্টেন্ট যোগ হলে অটো সবশেষ (নিচের) অংশ পর্যন্ত স্ক্রল —
  // reverse: true থাকায় offset 0 মানেই সবচেয়ে নিচের/সবশেষ কন্টেন্ট
  void _scrollHistoryToEnd() {
    if (!_historyScrollController.hasClients) return;
    if (_historyScrollController.offset > 1) {
      _historyScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  void _onDigit(String d) {
    setState(() {
      if (_justEvaluated) {
        // আগের হিসাবের রেজাল্টের পর নতুন সংখ্যা টাইপ করা শুরু —
        // নতুন লাইনে বসবে
        if (_tape.isNotEmpty) _tape += '\n';
        _current = d;
        _justEvaluated = false;
        return;
      }
      if (_current == '0') {
        _current = d;
      } else if (_current.replaceAll('-', '').replaceAll('.', '').length <
          _maxDigits) {
        _current += d;
      }
    });
  }

  void _onDot() {
    setState(() {
      if (_justEvaluated) {
        if (_tape.isNotEmpty) _tape += '\n';
        _current = '0.';
        _justEvaluated = false;
        return;
      }
      if (!_current.contains('.')) {
        _current += '.';
      }
    });
  }

  void _onOperator(String op) {
    setState(() {
      final currentVal = double.tryParse(_current) ?? 0;

      if (_justEvaluated) {
        // রেজাল্ট থেকেই হিসাব চালিয়ে যাওয়া — সংখ্যাটা তো "=" এর পাশে
        // ইতিমধ্যে দেখা যাচ্ছে, তাই শুধু অপারেটরটা যোগ হবে
        _tape += op;
      } else {
        // 🧾 নম্বর + অপারেটর একসাথে, আগের টেক্সটের সাথে জোড়া লেগে যাবে
        _tape += '${_formatNumber(currentVal)}$op';
      }

      if (_previousValue != null && _pendingOp != null && !_justEvaluated) {
        _previousValue = _applyOp(_previousValue!, currentVal, _pendingOp!);
      } else {
        _previousValue = currentVal;
      }
      _pendingOp = op;
      _current = '0';
      _justEvaluated = false;
    });
  }

  void _onEquals() {
    setState(() {
      if (_pendingOp == null || _previousValue == null) return;
      final currentVal = double.tryParse(_current) ?? 0;
      final result = _applyOp(_previousValue!, currentVal, _pendingOp!);
      final resultText = result.isNaN ? 'Error' : _formatNumber(result);

      // 🧾 পুরো হিসাবটা একসাথে টেপে যোগ হচ্ছে, যেমন "120+125=245"
      _tape += '${_formatNumber(currentVal)}=$resultText';

      _current = resultText;
      _previousValue = null;
      _pendingOp = null;
      _justEvaluated = true;
    });
  }

  void _onBackspace() {
    setState(() {
      if (_justEvaluated) {
        _current = '0';
        _justEvaluated = false;
        return;
      }
      if (_current.length <= 1 ||
          (_current.length == 2 && _current.startsWith('-'))) {
        _current = '0';
      } else {
        _current = _current.substring(0, _current.length - 1);
      }
    });
  }

  void _onToggleSign() {
    setState(() {
      if (_current == '0') return;
      _current =
          _current.startsWith('-') ? _current.substring(1) : '-$_current';
    });
  }

  void _onPercent() {
    setState(() {
      final currentVal = double.tryParse(_current) ?? 0;

      if (_previousValue != null && _pendingOp != null) {
        // যেমন: 100 + 12% → সাথে সাথেই 112 দেখাবে, আলাদা করে = চাপতে হবে না
        final percentVal = (_previousValue! * currentVal) / 100;
        final result = _applyOp(_previousValue!, percentVal, _pendingOp!);
        final resultText = result.isNaN ? 'Error' : _formatNumber(result);

        _tape += '${_formatNumber(currentVal)}%=$resultText';

        _current = resultText;
        _previousValue = null;
        _pendingOp = null;
        _justEvaluated = true;
      } else {
        // স্বাধীনভাবে % চাপ দেওয়া হলে (যেমন: 12% = 0.12)
        _current = _formatNumber(currentVal / 100);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'CALCULATOR',
      icon: Icons.calculate_rounded,
      onReset: _reset,
      content: Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 10),
        child: _buildDisplay(),
      ),
      keypad: _CalculatorKeypad(
        onDigit: _onDigit,
        onDot: _onDot,
        onOperator: _onOperator,
        onEquals: _onEquals,
        onClear: _reset,
        onBackspace: _onBackspace,
        onToggleSign: _onToggleSign,
        onPercent: _onPercent,
      ),
    );
  }

  // 🧾🔢 একটাই টেক্সট — টেপ + বর্তমান ইনপুট একসাথে, স্বাভাবিক
  // ক্যালকুলেটরের মতো র‍্যাপ করে। reverse: true থাকায় কন্টেন্ট কম হলে
  // একদম নিচে (কীপ্যাডের কাছে) থাকবে, বেশি হলে সবসময় সবশেষ এন্ট্রি
  // নিচেই দেখা যাবে আর পুরনোগুলো উপরের দিকে উঠে যাবে।
  Widget _buildDisplay() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollHistoryToEnd());

    return Container(
      width: double.infinity,
      // 🔧 ফিক্সড উচ্চতা — এটা বদলালেই কন্টেইনার ছোট/বড় হবে
      height: _displayHeight,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _historyScrollController,
              reverse: true,
              child: Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  _displayText,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkGreen),
                ),
              ),
            ),
          ),
          // 🔴 লাইভ রানিং টোটাল — চেইন চলাকালীন সবসময় দৃশ্যমান, "="
          // চাপার অপেক্ষা করতে হয় না
          if (_liveTotal != null) ...[
            const SizedBox(height: 4),
            Text(
              '= ${_liveTotal!.isNaN ? 'Error' : _formatNumber(_liveTotal!)}',
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.green),
            ),
          ],
        ],
      ),
    );
  }
}

class _CalculatorKeypad extends StatelessWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback onDot;
  final ValueChanged<String> onOperator;
  final VoidCallback onEquals;
  final VoidCallback onClear;
  final VoidCallback onBackspace;
  final VoidCallback onToggleSign;
  final VoidCallback onPercent;

  // 🔧 কিপ্যাডের সাইজ নিয়ন্ত্রণ
  static const double height = 248;
  static const double gap = 8;

  const _CalculatorKeypad({
    required this.onDigit,
    required this.onDot,
    required this.onOperator,
    required this.onEquals,
    required this.onClear,
    required this.onBackspace,
    required this.onToggleSign,
    required this.onPercent,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                _Btn(
                    label: '%',
                    onTap: onPercent,
                    bg: const Color(0xFFEFEFEF),
                    fg: AppColors.darkGreen),
                _gap(),
                _Btn(
                    label: 'C',
                    onTap: onClear,
                    bg: const Color(0xFFFFE0E0),
                    fg: Colors.red),
                _gap(),
                _Btn(
                    label: '⌫',
                    onTap: onBackspace,
                    bg: const Color(0xFFEFEFEF),
                    fg: AppColors.darkGreen),
                _gap(),
                _Btn(
                    label: '÷',
                    onTap: () => onOperator('÷'),
                    bg: AppColors.orange,
                    fg: Colors.white),
              ],
            ),
          ),
          SizedBox(height: gap),
          Expanded(
            child: Row(
              children: [
                _Btn(label: '7', onTap: () => onDigit('7')),
                _gap(),
                _Btn(label: '8', onTap: () => onDigit('8')),
                _gap(),
                _Btn(label: '9', onTap: () => onDigit('9')),
                _gap(),
                _Btn(
                    label: '×',
                    onTap: () => onOperator('×'),
                    bg: AppColors.orange,
                    fg: Colors.white),
              ],
            ),
          ),
          SizedBox(height: gap),
          Expanded(
            child: Row(
              children: [
                _Btn(label: '4', onTap: () => onDigit('4')),
                _gap(),
                _Btn(label: '5', onTap: () => onDigit('5')),
                _gap(),
                _Btn(label: '6', onTap: () => onDigit('6')),
                _gap(),
                _Btn(
                    label: '-',
                    onTap: () => onOperator('-'),
                    bg: AppColors.orange,
                    fg: Colors.white),
              ],
            ),
          ),
          SizedBox(height: gap),
          Expanded(
            child: Row(
              children: [
                _Btn(label: '1', onTap: () => onDigit('1')),
                _gap(),
                _Btn(label: '2', onTap: () => onDigit('2')),
                _gap(),
                _Btn(label: '3', onTap: () => onDigit('3')),
                _gap(),
                _Btn(
                    label: '+',
                    onTap: () => onOperator('+'),
                    bg: AppColors.orange,
                    fg: Colors.white),
              ],
            ),
          ),
          SizedBox(height: gap),
          Expanded(
            child: Row(
              children: [
                _Btn(
                    label: '±',
                    onTap: onToggleSign,
                    bg: const Color(0xFFEFEFEF),
                    fg: AppColors.darkGreen),
                _gap(),
                _Btn(label: '0', onTap: () => onDigit('0')),
                _gap(),
                _Btn(label: '.', onTap: onDot),
                _gap(),
                _Btn(
                    label: '=',
                    onTap: onEquals,
                    bg: AppColors.green,
                    fg: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _gap() => const SizedBox(width: gap);
}

class _Btn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color bg;
  final Color fg;
  final int flex;

  const _Btn({
    required this.label,
    required this.onTap,
    this.bg = const Color(0xFFF5F5F5),
    this.fg = AppColors.darkGreen,
    this.flex = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w800, color: fg),
            ),
          ),
        ),
      ),
    );
  }
}
