import 'package:flutter/material.dart';
import '../models/keypad_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/calc_scaffold.dart';
import '../widgets/formula_guide_button.dart';
import '../widgets/input_card.dart';
import '../widgets/numeric_keypad.dart';
import '../widgets/result_box.dart';

class LiquorRatioCalculatorScreen extends StatefulWidget {
  const LiquorRatioCalculatorScreen({super.key});

  @override
  State<LiquorRatioCalculatorScreen> createState() =>
      _LiquorRatioCalculatorScreenState();
}

class _LiquorRatioCalculatorScreenState
    extends State<LiquorRatioCalculatorScreen> {
  final ctrl = KeypadFieldController(['weight', 'ratio']);
  double? _volume;

  void _recalc() {
    final weight = ctrl.number('weight');
    final ratio = ctrl.number('ratio');

    setState(() {
      if (weight != null && weight > 0 && ratio != null && ratio > 0) {
        // Liquor Volume (L) = Fabric Weight (kg) × Liquor Ratio
        _volume = weight * ratio;
      } else {
        _volume = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'LIQUOR RATIO\nCALCULATOR',
      icon: Icons.water_drop_rounded,
      iconAsset: 'assets/homeicon/liquor_ratio_calculator.webp',
      showIconBackground: false,
      onReset: () => setState(() {
        ctrl.resetAll();
        _recalc();
      }),
      extraHeaderAction: FormulaGuideButton(
        title: 'Liquor Ratio Calculator',
        sections: const [
          FormulaGuideSection(
            heading: '📌 সংজ্ঞা (Definition)',
            body: 'Liquor Ratio (L:R) হলো ডাইং মেশিনে ব্যবহৃত মোট পানি '
                '(লিটারে) এবং ফেব্রিক/ইয়ার্নের ওজনের (kg) অনুপাত। যেমন '
                '1:10 মানে প্রতি ১ কেজি ফেব্রিকের জন্য ১০ লিটার পানি '
                'ব্যবহার হবে। এই অনুপাতের ওপর ভিত্তি করেই বাকি সব কেমিক্যাল '
                'ও ডাইয়ের ডোজ হিসাব করা হয়।',
          ),
          FormulaGuideSection(
            heading: '🧮 ফরমুলা',
            body: 'Liquor Volume (Litre) = Fabric Weight (kg) × '
                'Liquor Ratio\n\n'
                'যেমন Liquor Ratio 1:10 হলে শুধু "10" সংখ্যাটা ইনপুট '
                'দিতে হবে।',
          ),
          FormulaGuideSection(
            heading: '📝 ধাপে ধাপে হিসাব',
            body: '১. মেশিনে লোড করা ফেব্রিক/ইয়ার্নের মোট ওজন (kg) লিখুন\n'
                '২. প্রসেস/মেশিন অনুযায়ী নির্ধারিত Liquor Ratio-র শেষ '
                'সংখ্যাটা লিখুন (যেমন 1:10 হলে 10)\n'
                '৩. দুটো গুণ করলেই মোট প্রয়োজনীয় পানির পরিমাণ (লিটারে) '
                'পাওয়া যাবে',
          ),
          FormulaGuideSection(
            heading: '💡 উদাহরণ',
            body: 'ধরুন, Fabric Weight = 50 kg এবং Liquor Ratio = 1:8\n'
                'Liquor Volume = 50 × 8 = 400 Litre\n\n'
                'অর্থাৎ এই ব্যাচের জন্য মোট ৪০০ লিটার পানি প্রয়োজন হবে।',
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
              icon: Icons.scale_rounded,
              label: 'Fabric/Yarn Weight',
              subLabel: 'মেশিনে লোড করা ওজন',
              value: ctrl.values['weight']!,
              unit: 'kg',
              placeholder: '0.0',
              iconGradient: AppColors.greenIconGradient,
              accentColor: AppColors.green,
              active: ctrl.activeId == 'weight',
              onTap: () => setState(() => ctrl.setActive('weight')),
            ),
            const SizedBox(height: 4.0),
            InputCard(
              icon: Icons.balance_rounded,
              label: 'Liquor Ratio',
              subLabel: 'যেমন 1:10 হলে শুধু 10 লিখুন',
              value: ctrl.values['ratio']!,
              unit: ': 1',
              placeholder: '0.0',
              iconGradient: AppColors.tealIconGradient,
              accentColor: AppColors.teal,
              active: ctrl.activeId == 'ratio',
              onTap: () => setState(() => ctrl.setActive('ratio')),
            ),
            const SizedBox(height: 12),
            ResultBox(
              label: 'TOTAL LIQUOR VOLUME',
              value:
                  _volume != null ? '${_volume!.toStringAsFixed(1)} L' : '0 L',
              borderColor:
                  _volume != null ? AppColors.green : AppColors.inputBorder,
              live: _volume != null,
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
