import 'package:flutter/material.dart';
import '../models/keypad_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/calc_scaffold.dart';
import '../widgets/formula_guide_button.dart';
import '../widgets/input_card.dart';
import '../widgets/numeric_keypad.dart';
import '../widgets/result_box.dart';

class ChemicalDosingCalculatorScreen extends StatefulWidget {
  const ChemicalDosingCalculatorScreen({super.key});

  @override
  State<ChemicalDosingCalculatorScreen> createState() =>
      _ChemicalDosingCalculatorScreenState();
}

class _ChemicalDosingCalculatorScreenState
    extends State<ChemicalDosingCalculatorScreen> {
  final ctrl = KeypadFieldController(['volume', 'dosage']);
  double? _chemicalGrams;

  void _recalc() {
    final volume = ctrl.number('volume');
    final dosage = ctrl.number('dosage');

    setState(() {
      if (volume != null && volume > 0 && dosage != null && dosage > 0) {
        // Chemical Required (g) = Liquor Volume(L) × Dosage(g/L)
        _chemicalGrams = volume * dosage;
      } else {
        _chemicalGrams = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'CHEMICAL DOSING\nCALCULATOR',
      icon: Icons.science_rounded,
      iconAsset: 'assets/homeicon/chemical_dosing_calculator.webp',
      showIconBackground: false,
      onReset: () => setState(() {
        ctrl.resetAll();
        _recalc();
      }),
      extraHeaderAction: FormulaGuideButton(
        title: 'Chemical Dosing Calculator',
        sections: const [
          FormulaGuideSection(
            heading: '📌 সংজ্ঞা (Definition)',
            body: 'ডাইং প্রসেসে সল্ট, সোডা অ্যাশ, অ্যাসিটিক অ্যাসিড ইত্যাদি '
                'কেমিক্যাল সাধারণত মোট Liquor (পানির) পরিমাণের ওপর ভিত্তি '
                'করে গ্রাম/লিটার (g/L) হিসেবে ডোজ করা হয়। এই ক্যালকুলেটর '
                'দিয়ে যেকোনো কেমিক্যালের প্রয়োজনীয় মোট পরিমাণ বের করা যায়।',
          ),
          FormulaGuideSection(
            heading: '🧮 ফরমুলা',
            body: 'Chemical Required (g) = Liquor Volume (Litre) × '
                'Dosage (g/L)\n\n'
                'Liquor Volume আগে "Liquor Ratio Calculator" থেকে বের করে '
                'নিতে পারেন, তারপর সেই মান এখানে ব্যবহার করুন।',
          ),
          FormulaGuideSection(
            heading: '📝 ধাপে ধাপে হিসাব',
            body: '১. মেশিনে ব্যবহৃত মোট Liquor Volume (লিটারে) লিখুন\n'
                '২. রেসিপি অনুযায়ী নির্ধারিত Dosage (g/L) লিখুন — এটা '
                'কেমিক্যাল সাপ্লায়ার বা মিলের নিজস্ব রেসিপি থেকে পাওয়া '
                'যায়\n'
                '৩. দুটো গুণ করলেই মোট প্রয়োজনীয় কেমিক্যালের পরিমাণ '
                '(গ্রামে) পাওয়া যাবে',
          ),
          FormulaGuideSection(
            heading: '💡 উদাহরণ',
            body: 'ধরুন, Liquor Volume = 400 L এবং Salt Dosage = 60 g/L\n'
                'Salt Required = 400 × 60 = 24000 g (24 kg)\n\n'
                'এই একই পদ্ধতিতে সোডা অ্যাশ, লেভেলিং এজেন্ট বা অন্য যেকোনো '
                'g/L ভিত্তিক কেমিক্যালের হিসাবও করা যাবে।',
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
              icon: Icons.water_drop_rounded,
              label: 'Liquor Volume',
              subLabel: 'মোট পানির পরিমাণ',
              value: ctrl.values['volume']!,
              unit: 'L',
              placeholder: '0.0',
              iconGradient: AppColors.greenIconGradient,
              accentColor: AppColors.green,
              active: ctrl.activeId == 'volume',
              onTap: () => setState(() => ctrl.setActive('volume')),
            ),
            const SizedBox(height: 4.0),
            InputCard(
              icon: Icons.science_outlined,
              label: 'Chemical Dosage',
              subLabel: 'যেমন: Salt, Soda Ash',
              value: ctrl.values['dosage']!,
              unit: 'g/L',
              placeholder: '0.0',
              iconGradient: AppColors.darkTealIconGradient,
              accentColor: AppColors.darkTeal,
              active: ctrl.activeId == 'dosage',
              onTap: () => setState(() => ctrl.setActive('dosage')),
            ),
            const SizedBox(height: 12),
            ResultBox(
              label: 'TOTAL CHEMICAL REQUIRED',
              value: _chemicalGrams != null
                  ? '${_chemicalGrams!.toStringAsFixed(1)} g'
                  : '0 g',
              borderColor: _chemicalGrams != null
                  ? AppColors.green
                  : AppColors.inputBorder,
              live: _chemicalGrams != null,
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
