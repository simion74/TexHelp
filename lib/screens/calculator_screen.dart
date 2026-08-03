import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/calc_scaffold.dart';

/// সাধারণ ক্যালকুলেটর — যোগ, বিয়োগ, গুণ, ভাগ। একটা সাধারণ ক্যালকুলেটরের
/// মতোই বামদিক থেকে ডানদিকে ক্রমান্বয়ে হিসাব করে (যেমন সাধারণ মোবাইল
/// ক্যালকুলেটর করে) — জটিল BODMAS/অগ্রাধিকার নিয়ম নেই, এটা ইচ্ছাকৃত।
///
/// 🧾 হিস্ট্রি টেপ: প্রতিটা অপারেটর/সমান চাপার সাথে সাথে সেই নম্বর +
/// অপারেশনটা উপরে "টেপ" আকারে জমা হতে থাকে (যেমন 10+10+140+120 করলে
/// দেখাবে "10 +", "10 +", "140 +", "120 =" আর সবশেষে "= 280")। এতে
/// ইউজার সহজেই চেক করতে পারবে কি কি যোগ/বিয়োগ করেছে। Clear ("C" বা
/// হেডারের রিফ্রেশ আইকন) চাপলে হিস্ট্রি সহ সবকিছু মুছে যায়।
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

  // 🧾 হিস্ট্রি টেপ — প্রতিটা লাইন একটা এন্ট্রি, যেমন "10 +" বা "= 280"
  final List<String> _historyLines = [];
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
      _historyLines.clear(); // 🧹 ক্লিয়ার করলে হিস্ট্রি সহ সব মুছে যাবে
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

  // ↕️ নতুন হিস্ট্রি লাইন যোগ হলে অটো সবশেষ (নিচের) লাইন পর্যন্ত স্ক্রল
  void _scrollHistoryToEnd() {
    if (!_historyScrollController.hasClients) return;
    final maxExtent = _historyScrollController.position.maxScrollExtent;
    if ((_historyScrollController.offset - maxExtent).abs() > 1) {
      _historyScrollController.animateTo(
        maxExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  void _onDigit(String d) {
    setState(() {
      if (_justEvaluated) {
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
      // 🧾 এই নম্বর + অপারেটরটা হিস্ট্রি টেপে যোগ হচ্ছে (যেমন "10 +")
      _historyLines.add('${_formatNumber(currentVal)} $op');

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

      // 🧾 শেষ নম্বরটা "=" সহ, তারপর আলাদা লাইনে ফাইনাল রেজাল্ট
      _historyLines.add('${_formatNumber(currentVal)} =');
      _historyLines.add('= $resultText');

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

        _historyLines.add('${_formatNumber(currentVal)}% =');
        _historyLines.add('= $resultText');

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

  // 🧾+🔢 উপরে স্ক্রলযোগ্য হিস্ট্রি টেপ, নিচে বড় করে বর্তমান ইনপুট/রেজাল্ট
  Widget _buildDisplay() {
    // নতুন হিস্ট্রি লাইন এলে অটো সবশেষ পর্যন্ত স্ক্রল
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
          // 🧾 হিস্ট্রি টেপ — খালি থাকলে জায়গা নেয় না, ভরে গেলে
          // স্ক্রলযোগ্য হয়ে যায়
          Expanded(
            child: _historyLines.isEmpty
                ? const SizedBox.shrink()
                : SingleChildScrollView(
                    controller: _historyScrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: _historyLines.map(_buildHistoryLine).toList(),
                    ),
                  ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              _current,
              style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkGreen),
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

  // "= 280" এর মতো রেজাল্ট লাইনগুলো একটু বোল্ড/সবুজ করে আলাদা করে দেখানো
  Widget _buildHistoryLine(String line) {
    final isResult = line.startsWith('=');
    return Padding(
      padding: EdgeInsets.only(bottom: isResult ? 6 : 2),
      child: Text(
        line,
        style: TextStyle(
          fontSize: isResult ? 14 : 13,
          fontWeight: isResult ? FontWeight.w800 : FontWeight.w600,
          color: isResult ? AppColors.darkGreen : Colors.black45,
        ),
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
