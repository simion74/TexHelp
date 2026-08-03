import 'package:flutter/material.dart';
import '../models/keypad_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/calc_scaffold.dart';
import '../widgets/formula_guide_button.dart';
import '../widgets/input_card.dart';
import '../widgets/numeric_keypad.dart';
import '../widgets/result_box.dart';

class ChemicalAddOnCalculatorScreen extends StatefulWidget {
  const ChemicalAddOnCalculatorScreen({super.key});

  @override
  State<ChemicalAddOnCalculatorScreen> createState() =>
      _ChemicalAddOnCalculatorScreenState();
}

class _ChemicalAddOnCalculatorScreenState
    extends State<ChemicalAddOnCalculatorScreen> {
  final ctrl = KeypadFieldController(['wpu', 'concentration', 'fabricWeight']);
  double? _addOnPercent;
  double? _chemicalGrams;

  void _recalc() {
    final wpu = ctrl.number('wpu');
    final conc = ctrl.number('concentration');
    final weight = ctrl.number('fabricWeight');

    setState(() {
      if (wpu != null && wpu > 0 && conc != null && conc > 0) {
        // Add-on % (owf) = (WPU% × Concentration g/L) ÷ 1000
        _addOnPercent = (wpu * conc) / 1000;
        if (weight != null && weight > 0) {
          _chemicalGrams = weight * 10 * _addOnPercent!;
        } else {
          _chemicalGrams = null;
        }
      } else {
        _addOnPercent = null;
        _chemicalGrams = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'CHEMICAL ADD-ON\nCALCULATOR',
      icon: Icons.science_rounded,
      iconAsset: 'assets/homeicon/chemical_addon_calculator.webp',
      showIconBackground: false,
      onReset: () => setState(() {
        ctrl.resetAll();
        _recalc();
      }),
      extraHeaderAction: FormulaGuideButton(
        title: 'Chemical Add-on Calculator',
        sections: const [
          FormulaGuideSection(
            heading: '📌 সংজ্ঞা (Definition)',
            body: 'Finishing প্যাডিং প্রসেসে (যেমন Softener, Resin '
                'ফিনিশ) ফেব্রিকের ওজনের তুলনায় কতটুকু কেমিক্যাল আসলে '
                'ফেব্রিকে বসছে (Add-on %), তা নির্ভর করে Wet Pick-up % '
                'এবং বাথের কেমিক্যাল কনসেন্ট্রেশনের ওপর।',
          ),
          FormulaGuideSection(
            heading: '🧮 ফরমুলা',
            body: 'Add-on % (owf) = (Wet Pick-up % × Bath Concentration '
                '(g/L)) ÷ 1000\n\n'
                'Chemical Required (g) = Fabric Weight (kg) × 10 × '
                'Add-on %',
          ),
          FormulaGuideSection(
            heading: '📝 ধাপে ধাপে হিসাব',
            body: '১. "Wet Pick-up % Calculator" থেকে বের করা WPU% লিখুন\n'
                '২. প্যাডিং বাথে কেমিক্যালের কনসেন্ট্রেশন (গ্রাম/লিটার) '
                'লিখুন\n'
                '৩. অ্যাপ Add-on % বের করে দেবে\n'
                '৪. চাইলে মোট ফেব্রিক ওজন দিলে সরাসরি প্রয়োজনীয় '
                'কেমিক্যালের পরিমাণ (গ্রামে)-ও দেখাবে',
          ),
          FormulaGuideSection(
            heading: '💡 উদাহরণ',
            body: 'ধরুন, WPU% = 80%, Bath Concentration = 30 g/L\n'
                'Add-on % = (80 × 30) ÷ 1000 = 2.4%\n\n'
                'এবার Fabric Weight = 100 kg হলে —\n'
                'Chemical Required = 100 × 10 × 2.4 = 2400 g (2.4 kg)',
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
              icon: Icons.opacity_rounded,
              label: 'Wet Pick-up %',
              subLabel: 'প্যাডিং মেশিনের WPU%',
              value: ctrl.values['wpu']!,
              unit: '%',
              placeholder: '0.0',
              iconGradient: AppColors.greenIconGradient,
              accentColor: AppColors.green,
              dense: true,
              active: ctrl.activeId == 'wpu',
              onTap: () => setState(() => ctrl.setActive('wpu')),
            ),
            const SizedBox(height: 3.0),
            InputCard(
              icon: Icons.science_outlined,
              label: 'Bath Concentration',
              subLabel: 'বাথে কেমিক্যাল ঘনত্ব',
              value: ctrl.values['concentration']!,
              unit: 'g/L',
              placeholder: '0.0',
              iconGradient: AppColors.tealIconGradient,
              accentColor: AppColors.teal,
              dense: true,
              active: ctrl.activeId == 'concentration',
              onTap: () => setState(() => ctrl.setActive('concentration')),
            ),
            const SizedBox(height: 3.0),
            InputCard(
              icon: Icons.scale_rounded,
              label: 'Fabric Weight (ঐচ্ছিক)',
              subLabel: 'মোট প্রয়োজনীয় কেমিক্যাল জানতে',
              value: ctrl.values['fabricWeight']!,
              unit: 'kg',
              placeholder: '0.0',
              iconGradient: AppColors.purpleIconGradient,
              accentColor: AppColors.purple,
              dense: true,
              active: ctrl.activeId == 'fabricWeight',
              onTap: () => setState(() => ctrl.setActive('fabricWeight')),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ResultBox(
                    label: 'ADD-ON % (owf)',
                    value: _addOnPercent != null
                        ? '${_addOnPercent!.toStringAsFixed(2)}%'
                        : '0%',
                    borderColor: _addOnPercent != null
                        ? AppColors.teal
                        : AppColors.inputBorder,
                    textColor: AppColors.teal,
                    dense: true,
                    live: _addOnPercent != null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ResultBox(
                    label: 'CHEMICAL REQUIRED',
                    value: _chemicalGrams != null
                        ? '${_chemicalGrams!.toStringAsFixed(0)} g'
                        : '0 g',
                    borderColor: _chemicalGrams != null
                        ? AppColors.green
                        : AppColors.inputBorder,
                    dense: true,
                    live: _chemicalGrams != null,
                  ),
                ),
              ],
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
