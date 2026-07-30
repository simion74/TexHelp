import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/calc_scaffold.dart';

/// সাধারণ ক্যালকুলেটর — যোগ, বিয়োগ, গুণ, ভাগ। একটা সাধারণ ক্যালকুলেটরের
/// মতোই বামদিক থেকে ডানদিকে ক্রমান্বয়ে হিসাব করে (যেমন সাধারণ মোবাইল
/// ক্যালকুলেটর করে) — জটিল BODMAS/অগ্রাধিকার নিয়ম নেই, এটা ইচ্ছাকৃত।
class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _current = '0'; // এখন যা টাইপ হচ্ছে / রেজাল্ট
  double? _previousValue; // আগের সংরক্ষিত মান
  String? _pendingOp; // '+', '-', '×', '÷'
  String _expressionLine =
      ''; // উপরে ছোট করে দেখানো চলমান হিসাব (যেমন "12 + 5")
  bool _justEvaluated = false;

  static const int _maxDigits = 12;

  void _reset() {
    setState(() {
      _current = '0';
      _previousValue = null;
      _pendingOp = null;
      _expressionLine = '';
      _justEvaluated = false;
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

  void _onDigit(String d) {
    setState(() {
      if (_justEvaluated) {
        _current = d;
        _expressionLine = '';
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
        _expressionLine = '';
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
      if (_previousValue != null && _pendingOp != null && !_justEvaluated) {
        _previousValue = _applyOp(_previousValue!, currentVal, _pendingOp!);
      } else {
        _previousValue = currentVal;
      }
      _pendingOp = op;
      _expressionLine = '${_formatNumber(_previousValue!)} $op';
      _current = '0';
      _justEvaluated = false;
    });
  }

  void _onEquals() {
    setState(() {
      if (_pendingOp == null || _previousValue == null) return;
      final currentVal = double.tryParse(_current) ?? 0;
      final result = _applyOp(_previousValue!, currentVal, _pendingOp!);
      _expressionLine =
          '${_formatNumber(_previousValue!)} $_pendingOp ${_formatNumber(currentVal)} =';
      _current = result.isNaN ? 'Error' : _formatNumber(result);
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

        _expressionLine =
            '${_formatNumber(_previousValue!)} $_pendingOp ${_formatNumber(currentVal)}% =';
        _current = result.isNaN ? 'Error' : _formatNumber(result);

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
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 20,
                child: Text(
                  _expressionLine,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black45),
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
            ],
          ),
        ),
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
