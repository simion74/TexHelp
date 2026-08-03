import 'package:flutter/material.dart';
import '../models/keypad_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/calc_scaffold.dart';
import '../widgets/formula_guide_button.dart';
import '../widgets/input_card.dart';
import '../widgets/numeric_keypad.dart';
import '../widgets/result_box.dart';

class SeamEfficiencyCalculatorScreen extends StatefulWidget {
  const SeamEfficiencyCalculatorScreen({super.key});

  @override
  State<SeamEfficiencyCalculatorScreen> createState() =>
      _SeamEfficiencyCalculatorScreenState();
}

class _SeamEfficiencyCalculatorScreenState
    extends State<SeamEfficiencyCalculatorScreen> {
  final ctrl = KeypadFieldController(['fabricStrength', 'seamStrength']);
  double? _efficiency;

  void _recalc() {
    final fabric = ctrl.number('fabricStrength');
    final seam = ctrl.number('seamStrength');

    setState(() {
      if (fabric != null && fabric > 0 && seam != null && seam >= 0) {
        // Seam Efficiency % = (Seam Strength ÷ Fabric Strength) × 100
        _efficiency = (seam / fabric) * 100;
      } else {
        _efficiency = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'SEAM EFFICIENCY %\nCALCULATOR',
      icon: Icons.linear_scale_rounded,
      iconAsset: 'assets/homeicon/seam_efficiency_calculator.webp',
      showIconBackground: false,
      onReset: () => setState(() {
        ctrl.resetAll();
        _recalc();
      }),
      extraHeaderAction: FormulaGuideButton(
        title: 'Seam Efficiency % Calculator',
        sections: const [
          FormulaGuideSection(
            heading: '📌 সংজ্ঞা (Definition)',
            body: 'সেলাই করার সময় ফেব্রিকে সুচের ছিদ্র হওয়ায় এবং সুতার '
                'টেনশনের কারণে, সেলাই করা জায়গার স্ট্রেংথ মূল ফেব্রিকের '
                'স্ট্রেংথের চেয়ে কিছুটা কম হয়। Seam Efficiency % দিয়ে '
                'বোঝা যায় সেলাই মূল ফেব্রিকের স্ট্রেংথের কত শতাংশ ধরে '
                'রাখতে পেরেছে।',
          ),
          FormulaGuideSection(
            heading: '🧮 ফরমুলা',
            body: 'Seam Efficiency % = (Seam Strength ÷ Fabric Strength) '
                '× 100\n\n'
                'দুটো মানই সাধারণত একই ইউনিটে (যেমন Newton বা lbs) '
                'একটা Tensile Strength Tester মেশিনে টেস্ট করে বের করা হয়।',
          ),
          FormulaGuideSection(
            heading: '📝 ধাপে ধাপে হিসাব',
            body: '১. একটা সেলাই ছাড়া ফেব্রিক নমুনার Breaking Strength '
                'টেস্ট করুন (Fabric Strength)\n'
                '২. একই ফেব্রিকের সেলাই করা নমুনার Breaking Strength '
                'টেস্ট করুন (Seam Strength)\n'
                '৩. Seam Strength-কে Fabric Strength দিয়ে ভাগ করে ১০০ '
                'দিয়ে গুণ করলেই Seam Efficiency % পাওয়া যাবে',
          ),
          FormulaGuideSection(
            heading: '💡 উদাহরণ',
            body: 'ধরুন, Fabric Strength = 250 N এবং Seam Strength = '
                '210 N\n'
                'Seam Efficiency % = (210 ÷ 250) × 100 = 84%\n\n'
                'নোট: গ্রহণযোগ্য Seam Efficiency % ফেব্রিক টাইপ, সেলাই '
                'ধরন ও বায়ারের নিজস্ব স্ট্যান্ডার্ড অনুযায়ী ভিন্ন হয়।',
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
              icon: Icons.texture_rounded,
              label: 'Fabric Strength',
              subLabel: 'সেলাই ছাড়া ফেব্রিকের স্ট্রেংথ',
              value: ctrl.values['fabricStrength']!,
              unit: 'N',
              placeholder: '0.0',
              iconGradient: AppColors.greenIconGradient,
              accentColor: AppColors.green,
              active: ctrl.activeId == 'fabricStrength',
              onTap: () => setState(() => ctrl.setActive('fabricStrength')),
            ),
            const SizedBox(height: 4.0),
            InputCard(
              icon: Icons.content_cut_rounded,
              label: 'Seam Strength',
              subLabel: 'সেলাই করা জায়গার স্ট্রেংথ',
              value: ctrl.values['seamStrength']!,
              unit: 'N',
              placeholder: '0.0',
              iconGradient: AppColors.tealIconGradient,
              accentColor: AppColors.teal,
              active: ctrl.activeId == 'seamStrength',
              onTap: () => setState(() => ctrl.setActive('seamStrength')),
            ),
            const SizedBox(height: 12),
            ResultBox(
              label: 'SEAM EFFICIENCY %',
              value: _efficiency != null
                  ? '${_efficiency!.toStringAsFixed(1)}%'
                  : '0%',
              borderColor: _efficiency != null
                  ? AppColors.green
                  : AppColors.inputBorder,
              live: _efficiency != null,
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
