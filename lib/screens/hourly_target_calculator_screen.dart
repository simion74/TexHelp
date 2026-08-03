import 'package:flutter/material.dart';
import '../models/keypad_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/calc_scaffold.dart';
import '../widgets/formula_guide_button.dart';
import '../widgets/input_card.dart';
import '../widgets/numeric_keypad.dart';
import '../widgets/result_box.dart';

class HourlyTargetCalculatorScreen extends StatefulWidget {
  const HourlyTargetCalculatorScreen({super.key});

  @override
  State<HourlyTargetCalculatorScreen> createState() =>
      _HourlyTargetCalculatorScreenState();
}

class _HourlyTargetCalculatorScreenState
    extends State<HourlyTargetCalculatorScreen> {
  final ctrl = KeypadFieldController(['smv', 'operators', 'efficiency']);
  double? _targetPcs;

  void _recalc() {
    final smv = ctrl.number('smv');
    final operators = ctrl.number('operators');
    final eff = ctrl.number('efficiency');

    setState(() {
      if (smv != null && smv > 0 && operators != null && operators > 0) {
        final effValue = (eff != null && eff > 0) ? eff : 100;
        // Target/hr = (60 ÷ SMV) × Operators × (Efficiency% ÷ 100)
        _targetPcs = (60 / smv) * operators * (effValue / 100);
      } else {
        _targetPcs = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'HOURLY TARGET\nCALCULATOR',
      icon: Icons.speed_rounded,
      iconAsset: 'assets/homeicon/hourly_target_calculator.webp',
      showIconBackground: false,
      onReset: () => setState(() {
        ctrl.resetAll();
        _recalc();
      }),
      extraHeaderAction: FormulaGuideButton(
        title: 'Hourly Target Calculator',
        sections: const [
          FormulaGuideSection(
            heading: '📌 সংজ্ঞা (Definition)',
            body: 'SMV (Standard Minute Value) হলো একটা নির্দিষ্ট অপারেশন '
                '(যেমন একটা সেলাই) সম্পন্ন করতে একজন গড় দক্ষ অপারেটরের '
                'কত মিনিট সময় লাগে তার মান। এই মান দিয়ে একটা লাইনের '
                'ঘণ্টাপ্রতি প্রোডাকশন টার্গেট বের করা যায়।',
          ),
          FormulaGuideSection(
            heading: '🧮 ফরমুলা',
            body: 'Target (pcs/hr) = (60 ÷ SMV) × Operators × '
                '(Efficiency% ÷ 100)\n\n'
                'Efficiency % না দিলে ডিফল্টভাবে ১০০% ধরে হিসাব হবে '
                '(অর্থাৎ তাত্ত্বিক সর্বোচ্চ টার্গেট)।',
          ),
          FormulaGuideSection(
            heading: '📝 ধাপে ধাপে হিসাব',
            body: '১. প্রোডাক্টের SMV (মিনিটে) লিখুন\n'
                '২. লাইনে মোট কতজন অপারেটর আছেন লিখুন\n'
                '৩. লাইনের প্রত্যাশিত Efficiency % লিখুন (ঐচ্ছিক — না '
                'দিলে ১০০% ধরা হবে)\n'
                '৪. অ্যাপ স্বয়ংক্রিয়ভাবে ঘণ্টাপ্রতি টার্গেট (পিসে) '
                'দেখাবে',
          ),
          FormulaGuideSection(
            heading: '💡 উদাহরণ',
            body: 'ধরুন, SMV = 0.5 min, Operators = 30, Efficiency = 65%\n'
                'Target = (60 ÷ 0.5) × 30 × 0.65 = 2,340 pcs/hr',
          ),
        ],
      ),
      content: Padding(
        padding: const EdgeInsets.only(
          left: 18.0,
          right: 18.0,
          top: 26.0,
          bottom: 8.0,
        ),
        child: Column(
          children: [
            InputCard(
              icon: Icons.timer_rounded,
              label: 'SMV',
              subLabel: 'Standard Minute Value',
              value: ctrl.values['smv']!,
              unit: 'min',
              placeholder: '0.0',
              iconGradient: AppColors.greenIconGradient,
              accentColor: AppColors.green,
              active: ctrl.activeId == 'smv',
              onTap: () => setState(() => ctrl.setActive('smv')),
            ),
            const SizedBox(height: 4.0),
            InputCard(
              icon: Icons.people_alt_rounded,
              label: 'No. of Operators',
              subLabel: 'লাইনের অপারেটর সংখ্যা',
              value: ctrl.values['operators']!,
              unit: 'pcs',
              placeholder: '0',
              iconGradient: AppColors.tealIconGradient,
              accentColor: AppColors.teal,
              active: ctrl.activeId == 'operators',
              onTap: () => setState(() => ctrl.setActive('operators')),
            ),
            const SizedBox(height: 4.0),
            InputCard(
              icon: Icons.percent_rounded,
              label: 'Efficiency % (ঐচ্ছিক)',
              subLabel: 'না দিলে 100% ধরা হবে',
              value: ctrl.values['efficiency']!,
              unit: '%',
              placeholder: '0.0',
              iconGradient: AppColors.purpleIconGradient,
              accentColor: AppColors.purple,
              active: ctrl.activeId == 'efficiency',
              onTap: () => setState(() => ctrl.setActive('efficiency')),
            ),
            const SizedBox(height: 10),
            ResultBox(
              label: 'HOURLY TARGET',
              value: _targetPcs != null
                  ? '${_targetPcs!.toStringAsFixed(0)} pcs/hr'
                  : '0 pcs/hr',
              borderColor: _targetPcs != null
                  ? AppColors.green
                  : AppColors.inputBorder,
              live: _targetPcs != null,
            ),
          ],
        ),
      ),
      keypad: NumericKeypad(
        height: 200,
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
