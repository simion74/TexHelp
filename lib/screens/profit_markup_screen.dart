import 'package:flutter/material.dart';
import '../models/keypad_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/calc_scaffold.dart';
import '../widgets/formula_guide_button.dart';
import '../widgets/input_card.dart';
import '../widgets/numeric_keypad.dart';
import '../widgets/result_box.dart';

enum _Currency { tk, usd, eur }

/// Profit / Markup Calculator (Costing Section)
/// -----------------------------------------------
/// Cost Price ও Selling Price (Tk/$/€ যেকোনো কারেন্সিতে) দিলে Profit
/// Amount, Profit Margin% এবং Markup% বের করে দেয়। অ্যাপের বাকি সব
/// ক্যালকুলেটরের মতোই একই CalcScaffold, একই NumericKeypad এবং হেডারে
/// একই FormulaGuideButton ব্যবহার করা হয়েছে।
class ProfitMarkupScreen extends StatefulWidget {
  const ProfitMarkupScreen({super.key});

  @override
  State<ProfitMarkupScreen> createState() => _ProfitMarkupScreenState();
}

class _ProfitMarkupScreenState extends State<ProfitMarkupScreen> {
  final ctrl = KeypadFieldController(['cost', 'selling']);

  _Currency _currency = _Currency.tk;

  double? _profit;
  double? _marginPercent;
  double? _markupPercent;

  void _recalc() {
    final costVal = ctrl.number('cost');
    final sellingVal = ctrl.number('selling');

    if (costVal == null ||
        costVal <= 0 ||
        sellingVal == null ||
        sellingVal <= 0) {
      setState(() {
        _profit = null;
        _marginPercent = null;
        _markupPercent = null;
      });
      return;
    }

    final profit = sellingVal - costVal;
    // Margin% = Profit ÷ Selling Price × 100
    final marginPercent = (profit / sellingVal) * 100;
    // Markup% = Profit ÷ Cost Price × 100
    final markupPercent = (profit / costVal) * 100;

    setState(() {
      _profit = profit;
      _marginPercent = marginPercent;
      _markupPercent = markupPercent;
    });
  }

  String get _currencyLabel {
    switch (_currency) {
      case _Currency.tk:
        return 'Tk';
      case _Currency.usd:
        return '\$';
      case _Currency.eur:
        return '€';
    }
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'PROFIT / MARKUP\nCALCULATOR',
      icon: Icons.trending_up_rounded,
      iconAsset: 'assets/homeicon/profit_markup.webp',
      extraHeaderAction: FormulaGuideButton(
        title: 'Profit / Markup Calculator',
        sections: [
          FormulaGuideSection(
            heading: 'সংজ্ঞা (Definition)',
            body: 'Profit Margin ও Markup — দুটোই লাভ মাপার হার, কিন্তু '
                'হিসাব আলাদা জায়গা থেকে করা হয়:\n\n'
                '• Profit Margin% — লাভকে Selling Price দিয়ে ভাগ করে '
                'বের করা হয়। এটা বোঝায় বিক্রয় মূল্যের কত শতাংশ লাভ।\n\n'
                '• Markup% — লাভকে Cost Price দিয়ে ভাগ করে বের করা '
                'হয়। এটা বোঝায় কস্ট প্রাইসের উপর কত শতাংশ বাড়িয়ে '
                'বিক্রি করা হচ্ছে।\n\n'
                'দুইটার সংখ্যা কখনোই সমান হয় না — Markup% সবসময় '
                'Margin% এর চেয়ে বেশি হয় (যদি লাভ থাকে)।',
          ),
          FormulaGuideSection(
            heading: 'ফরমুলা (Formula)',
            body: 'Profit = Selling Price − Cost Price\n\n'
                'Profit Margin% = (Profit ÷ Selling Price) × 100\n\n'
                'Markup% = (Profit ÷ Cost Price) × 100',
          ),
          FormulaGuideSection(
            heading: 'ম্যানুয়ালি কীভাবে বের করবেন?',
            body: '১) প্রোডাক্টের মোট Cost Price (কাঁচামাল + CM + '
                'ওভারহেড ইত্যাদি সব মিলিয়ে) লিখুন।\n'
                '২) যে দামে বিক্রি করা হচ্ছে বা হবে সেই Selling Price '
                'লিখুন।\n'
                '৩) Selling Price থেকে Cost Price বাদ দিলে Profit '
                'পাওয়া যাবে।\n'
                '৪) Profit-কে Selling Price দিয়ে ভাগ করে ১০০ দিয়ে '
                'গুণ করলে Margin% পাওয়া যাবে।\n'
                '৫) Profit-কে Cost Price দিয়ে ভাগ করে ১০০ দিয়ে গুণ '
                'করলে Markup% পাওয়া যাবে।',
          ),
          FormulaGuideSection(
            heading: 'উদাহরণ (Example)',
            body: 'ধরুন Cost Price = 200 Tk, Selling Price = 250 Tk।\n\n'
                'Profit = 250 − 200 = 50 Tk\n'
                'Margin% = (50 ÷ 250) × 100 = 20%\n'
                'Markup% = (50 ÷ 200) × 100 = 25%\n\n'
                'অ্যাপে শুধু Cost Price এ 200 এবং Selling Price এ 250 '
                'লিখলেই এই ফলাফল অটো বের হয়ে যাবে।',
          ),
          FormulaGuideSection(
            heading: 'টিপস',
            body: 'গার্মেন্টস কস্টিংয়ে বায়ারের সাথে দরকষাকষির সময় '
                'সাধারণত Margin% ব্যবহার করা হয় (কারণ এটা Selling '
                'Price ভিত্তিক), আর ফ্যাক্টরির ভেতরের প্রফিট প্ল্যানিংয়ে '
                'Markup% বেশি ব্যবহৃত হয় (কারণ এটা Cost ভিত্তিক)। '
                'দুটো নম্বর একসাথে জেনে রাখলে দরকষাকষি সহজ হয়।',
          ),
        ],
      ),
      onReset: () => setState(() {
        ctrl.resetAll();
        _currency = _Currency.tk;
        _profit = null;
        _marginPercent = null;
        _markupPercent = null;
      }),
      content: Padding(
        padding: const EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 28.0,
          bottom: 16.0,
        ),
        child: Column(
          children: [
            _SegmentedToggle<_Currency>(
              value: _currency,
              options: const {
                _Currency.tk: 'Tk',
                _Currency.usd: '\$ USD',
                _Currency.eur: '€ EUR',
              },
              onChanged: (v) => setState(() {
                _currency = v;
                _recalc();
              }),
            ),
            const SizedBox(height: 8.0),
            InputCard(
              icon: Icons.payments_rounded,
              label: 'Cost Price',
              subLabel: 'Total Cost per Unit',
              value: ctrl.values['cost']!,
              unit: _currencyLabel,
              placeholder: '0.0',
              iconGradient: AppColors.purpleIconGradient,
              accentColor: AppColors.purple,
              active: ctrl.activeId == 'cost',
              onTap: () => setState(() => ctrl.setActive('cost')),
            ),
            const SizedBox(height: 8.0),
            InputCard(
              icon: Icons.sell_rounded,
              label: 'Selling Price',
              subLabel: 'Sale Price per Unit',
              value: ctrl.values['selling']!,
              unit: _currencyLabel,
              placeholder: '0.0',
              iconGradient: AppColors.tealIconGradient,
              accentColor: AppColors.teal,
              active: ctrl.activeId == 'selling',
              onTap: () => setState(() => ctrl.setActive('selling')),
            ),
            const SizedBox(height: 12.0),
            ResultBox(
              label: 'Profit Amount',
              value: _profit != null
                  ? '$_currencyLabel ${_profit!.toStringAsFixed(2)}'
                  : '$_currencyLabel 0.00',
              borderColor:
                  _profit != null ? AppColors.green : AppColors.inputBorder,
              live: _profit != null,
              dense: true,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ResultBox(
                    label: 'Profit Margin %',
                    value: _marginPercent != null
                        ? '${_marginPercent!.toStringAsFixed(2)}%'
                        : '0.00%',
                    borderColor: _marginPercent != null
                        ? AppColors.green
                        : AppColors.inputBorder,
                    live: _marginPercent != null,
                    dense: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ResultBox(
                    label: 'Markup %',
                    value: _markupPercent != null
                        ? '${_markupPercent!.toStringAsFixed(2)}%'
                        : '0.00%',
                    borderColor: _markupPercent != null
                        ? AppColors.green
                        : AppColors.inputBorder,
                    live: _markupPercent != null,
                    dense: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      keypad: NumericKeypad(
        onDigit: (v) => setState(() {
          ctrl.appendDigit(v);
          _recalc();
        }),
        onBackspace: () => setState(() {
          ctrl.backspace();
          _recalc();
        }),
        onClear: () => setState(() {
          ctrl.clearActive();
          _recalc();
        }),
        onUp: () => setState(() => ctrl.moveField(-1)),
        onDown: () => setState(() => ctrl.moveField(1)),
      ),
    );
  }
}

/// N-অপশনের সেগমেন্টেড টগল (Currency বেছে নেওয়ার জন্য) —
/// yarn_weight_screen.dart-এর _SegmentedToggle এর সাথে হুবহু একই।
class _SegmentedToggle<T> extends StatelessWidget {
  final T value;
  final Map<T, String> options;
  final ValueChanged<T> onChanged;

  const _SegmentedToggle({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.inputBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Row(
        children: options.entries.map((entry) {
          final selected = entry.key == value;
          return Expanded(
            child: Material(
              color: selected ? AppColors.green : Colors.transparent,
              borderRadius: BorderRadius.circular(9),
              child: InkWell(
                borderRadius: BorderRadius.circular(9),
                onTap: () => onChanged(entry.key),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    entry.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: selected ? Colors.white : AppColors.darkGreen,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
