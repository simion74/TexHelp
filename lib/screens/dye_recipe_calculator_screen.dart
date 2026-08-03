import 'package:flutter/material.dart';
import '../models/keypad_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/calc_scaffold.dart';
import '../widgets/formula_guide_button.dart';
import '../widgets/input_card.dart';
import '../widgets/numeric_keypad.dart';
import '../widgets/result_box.dart';

class DyeRecipeCalculatorScreen extends StatefulWidget {
  const DyeRecipeCalculatorScreen({super.key});

  @override
  State<DyeRecipeCalculatorScreen> createState() =>
      _DyeRecipeCalculatorScreenState();
}

class _DyeRecipeCalculatorScreenState
    extends State<DyeRecipeCalculatorScreen> {
  final ctrl = KeypadFieldController(['weight', 'shade']);
  double? _dyeGrams;

  void _recalc() {
    final weight = ctrl.number('weight');
    final shade = ctrl.number('shade');

    setState(() {
      if (weight != null && weight > 0 && shade != null && shade > 0) {
        // Dye Required (g) = Fabric Weight(kg) × 1000 × (Shade% ÷ 100)
        _dyeGrams = weight * 1000 * (shade / 100);
      } else {
        _dyeGrams = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'DYE RECIPE\n(SHADE %) CALCULATOR',
      icon: Icons.format_color_fill_rounded,
      iconAsset: 'assets/homeicon/dye_recipe_calculator.webp',
      showIconBackground: false,
      onReset: () => setState(() {
        ctrl.resetAll();
        _recalc();
      }),
      extraHeaderAction: FormulaGuideButton(
        title: 'Dye Recipe (Shade %)',
        sections: const [
          FormulaGuideSection(
            heading: '📌 সংজ্ঞা (Definition)',
            body: 'Shade % (যাকে %owf — "on the weight of fabric"-ও বলা '
                'হয়) দিয়ে বোঝানো হয় ফেব্রিকের ওজনের তুলনায় কতটুকু ডাই '
                '(রং) ব্যবহার করতে হবে। যেমন 1% Shade মানে ১০০ কেজি '
                'ফেব্রিকের জন্য ১ কেজি ডাই প্রয়োজন।',
          ),
          FormulaGuideSection(
            heading: '🧮 ফরমুলা',
            body: 'Dye Required (g) = Fabric Weight (kg) × 1000 × '
                '(Shade % ÷ 100)\n\n'
                'ফেব্রিক ওজনকে ১০০০ দিয়ে গুণ করলে গ্রামে পাওয়া যায়, '
                'তারপর Shade %-এর সাথে গুণ করলেই প্রয়োজনীয় ডাইয়ের '
                'পরিমাণ (গ্রামে) বের হয়ে যায়।',
          ),
          FormulaGuideSection(
            heading: '📝 ধাপে ধাপে হিসাব',
            body: '১. মেশিনে লোড করা ফেব্রিকের মোট ওজন (kg) লিখুন\n'
                '২. রেসিপি অনুযায়ী নির্ধারিত Shade % লিখুন\n'
                '৩. অ্যাপ স্বয়ংক্রিয়ভাবে প্রয়োজনীয় ডাইয়ের পরিমাণ '
                '(গ্রামে) বের করে দেবে',
          ),
          FormulaGuideSection(
            heading: '💡 উদাহরণ',
            body: 'ধরুন, Fabric Weight = 100 kg এবং Shade = 1.5%\n'
                'Dye Required = 100 × 1000 × (1.5 ÷ 100) = 1500 g (1.5 kg)\n\n'
                'একাধিক ডাই মিশিয়ে রেসিপি বানাতে হলে, প্রতিটা আলাদা ডাইয়ের '
                'জন্য এই একই ক্যালকুলেশন আলাদাভাবে করতে হবে (প্রতিটার '
                'নিজস্ব Shade % দিয়ে)।',
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
              icon: Icons.percent_rounded,
              label: 'Shade %',
              subLabel: '%owf (on weight of fabric)',
              value: ctrl.values['shade']!,
              unit: '%',
              placeholder: '0.0',
              iconGradient: AppColors.purpleIconGradient,
              accentColor: AppColors.purple,
              active: ctrl.activeId == 'shade',
              onTap: () => setState(() => ctrl.setActive('shade')),
            ),
            const SizedBox(height: 12),
            ResultBox(
              label: 'DYE REQUIRED',
              value: _dyeGrams != null
                  ? '${_dyeGrams!.toStringAsFixed(2)} g'
                  : '0 g',
              borderColor:
                  _dyeGrams != null ? AppColors.green : AppColors.inputBorder,
              live: _dyeGrams != null,
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
