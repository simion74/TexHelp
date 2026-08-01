import 'package:flutter/material.dart';
import '../models/keypad_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/calc_scaffold.dart';
import '../widgets/formula_guide_button.dart';
import '../widgets/input_card.dart';
import '../widgets/numeric_keypad.dart';
import '../widgets/result_box.dart';

class BlendRatioCalculatorScreen extends StatefulWidget {
  const BlendRatioCalculatorScreen({super.key});

  @override
  State<BlendRatioCalculatorScreen> createState() =>
      _BlendRatioCalculatorScreenState();
}

class _BlendRatioCalculatorScreenState
    extends State<BlendRatioCalculatorScreen> {
  final ctrl = KeypadFieldController(['percentA', 'totalWeight']);
  double? _weightA;
  double? _weightB;
  double? _percentB;

  void _recalc() {
    final pA = ctrl.number('percentA');
    final total = ctrl.number('totalWeight');

    setState(() {
      if (pA != null && pA > 0 && pA <= 100 && total != null && total > 0) {
        _percentB = 100 - pA;
        _weightA = total * pA / 100;
        _weightB = total - _weightA!;
      } else {
        _weightA = null;
        _weightB = null;
        _percentB = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'BLEND RATIO\nCALCULATOR',
      icon: Icons.pie_chart_rounded,
      onReset: () => setState(() {
        ctrl.resetAll();
        _recalc();
      }),
      extraHeaderAction: FormulaGuideButton(
        title: 'Blend Ratio Calculator',
        sections: const [
          FormulaGuideSection(
            heading: '📌 সংজ্ঞা (Definition)',
            body: 'বিভিন্ন গুণাগুণের সুতা/ফেব্রিক তৈরির জন্য দুই বা ততোধিক '
                'ফাইবার (যেমন Cotton + Polyester) নির্দিষ্ট অনুপাতে মিশিয়ে '
                'একটা ব্লেন্ড তৈরি করা হয়। এই ক্যালকুলেটর দিয়ে মোট ওজনের '
                'ওপর ভিত্তি করে প্রতিটা ফাইবারের প্রয়োজনীয় ওজন বের করা যায়।',
          ),
          FormulaGuideSection(
            heading: '🧮 ফরমুলা',
            body: 'Fiber A Weight = Total Weight × (Fiber A % ÷ 100)\n'
                'Fiber B Weight = Total Weight − Fiber A Weight\n'
                'Fiber B % = 100 − Fiber A %',
          ),
          FormulaGuideSection(
            heading: '📝 ধাপে ধাপে হিসাব',
            body: '১. প্রথম ফাইবারের শতাংশ (%) লিখুন — যেমন 65% Cotton\n'
                '২. মোট ব্যাচের ওজন লিখুন (kg)\n'
                '৩. অ্যাপ স্বয়ংক্রিয়ভাবে দুটো ফাইবারের আলাদা ওজন ও '
                'দ্বিতীয় ফাইবারের শতাংশ বের করে দেবে',
          ),
          FormulaGuideSection(
            heading: '💡 উদাহরণ',
            body: 'ধরুন, Cotton 65%, মোট ওজন 100 kg\n'
                'Cotton Weight = 100 × 0.65 = 65 kg\n'
                'Polyester % = 100 − 65 = 35%\n'
                'Polyester Weight = 100 − 65 = 35 kg',
          ),
        ],
      ),
      content: Padding(
        padding: const EdgeInsets.only(
          left: 18.0,
          right: 18.0,
          top: 30.0,
          bottom: 10.0,
        ),
        child: Column(
          children: [
            InputCard(
              icon: Icons.percent_rounded,
              label: 'Fiber A %',
              subLabel: 'যেমন: Cotton',
              value: ctrl.values['percentA']!,
              unit: '%',
              placeholder: '0.0',
              iconGradient: AppColors.greenIconGradient,
              accentColor: AppColors.green,
              active: ctrl.activeId == 'percentA',
              onTap: () => setState(() => ctrl.setActive('percentA')),
            ),
            const SizedBox(height: 4.0),
            InputCard(
              icon: Icons.scale_rounded,
              label: 'Total Batch Weight',
              subLabel: 'মোট মিশ্রণের ওজন',
              value: ctrl.values['totalWeight']!,
              unit: 'kg',
              placeholder: '0.0',
              iconGradient: AppColors.tealIconGradient,
              accentColor: AppColors.teal,
              active: ctrl.activeId == 'totalWeight',
              onTap: () => setState(() => ctrl.setActive('totalWeight')),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ResultBox(
                    label:
                        'FIBER A WEIGHT',
                    value: _weightA != null
                        ? '${_weightA!.toStringAsFixed(2)} kg'
                        : '0 kg',
                    borderColor: _weightA != null
                        ? AppColors.green
                        : AppColors.inputBorder,
                    live: _weightA != null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ResultBox(
                    label: 'FIBER B WEIGHT (${_percentB?.toStringAsFixed(0) ?? '0'}%)',
                    value: _weightB != null
                        ? '${_weightB!.toStringAsFixed(2)} kg'
                        : '0 kg',
                    borderColor: _weightB != null
                        ? AppColors.teal
                        : AppColors.inputBorder,
                    textColor: AppColors.teal,
                    live: _weightB != null,
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
