import 'package:flutter/material.dart';
import '../models/keypad_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/calc_scaffold.dart';
import '../widgets/formula_guide_button.dart';
import '../widgets/input_card.dart';
import '../widgets/numeric_keypad.dart';
import '../widgets/result_box.dart';

class WetPickupCalculatorScreen extends StatefulWidget {
  const WetPickupCalculatorScreen({super.key});

  @override
  State<WetPickupCalculatorScreen> createState() =>
      _WetPickupCalculatorScreenState();
}

class _WetPickupCalculatorScreenState
    extends State<WetPickupCalculatorScreen> {
  final ctrl = KeypadFieldController(['dryWeight', 'wetWeight']);
  double? _wpu;

  void _recalc() {
    final dry = ctrl.number('dryWeight');
    final wet = ctrl.number('wetWeight');

    setState(() {
      if (dry != null && dry > 0 && wet != null && wet > dry) {
        // Wet Pick-up % = ((Wet Weight − Dry Weight) ÷ Dry Weight) × 100
        _wpu = ((wet - dry) / dry) * 100;
      } else {
        _wpu = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'WET PICK-UP %\nCALCULATOR',
      icon: Icons.opacity_rounded,
      iconAsset: 'assets/homeicon/wet_pickup_calculator.webp',
      showIconBackground: false,
      onReset: () => setState(() {
        ctrl.resetAll();
        _recalc();
      }),
      extraHeaderAction: FormulaGuideButton(
        title: 'Wet Pick-up % Calculator',
        sections: const [
          FormulaGuideSection(
            heading: '📌 সংজ্ঞা (Definition)',
            body: 'Wet Pick-up % (WPU%) দিয়ে বোঝা যায় প্যাডিং মেশিন দিয়ে '
                'যাওয়ার পর ফেব্রিক তার নিজের শুকনো ওজনের তুলনায় কতটুকু '
                'লিকার (পানি + কেমিক্যাল দ্রবণ) শোষণ করেছে। এটা Finishing '
                'রেসিপি হিসাবের সবচেয়ে গুরুত্বপূর্ণ প্রথম ধাপ।',
          ),
          FormulaGuideSection(
            heading: '🧮 ফরমুলা',
            body: 'WPU% = ((Wet Weight − Dry Weight) ÷ Dry Weight) × 100',
          ),
          FormulaGuideSection(
            heading: '📝 ধাপে ধাপে হিসাব',
            body: '১. একটা ফেব্রিক নমুনার শুকনো ওজন (Dry Weight) মাপুন\n'
                '২. প্যাডিং মেশিন দিয়ে পার করার পর (nip pressure সেট করা '
                'অবস্থায়) সেই একই নমুনা আবার ওজন করুন — এটাই Wet Weight\n'
                '৩. দুটোর পার্থক্য বের করে Dry Weight দিয়ে ভাগ করে ১০০ '
                'দিয়ে গুণ করলেই WPU% পাওয়া যাবে',
          ),
          FormulaGuideSection(
            heading: '💡 উদাহরণ',
            body: 'ধরুন, Dry Weight = 100 g এবং Wet Weight = 180 g\n'
                'WPU% = ((180 − 100) ÷ 100) × 100 = 80%\n\n'
                'এই মানটাই পরে "Chemical Add-on Calculator"-এ ব্যবহার করে '
                'প্রয়োজনীয় কেমিক্যালের পরিমাণ বের করা যাবে।',
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
              icon: Icons.crop_square_rounded,
              label: 'Dry Weight',
              subLabel: 'প্যাডিং-এর আগের ওজন',
              value: ctrl.values['dryWeight']!,
              unit: 'g',
              placeholder: '0.0',
              iconGradient: AppColors.greenIconGradient,
              accentColor: AppColors.green,
              active: ctrl.activeId == 'dryWeight',
              onTap: () => setState(() => ctrl.setActive('dryWeight')),
            ),
            const SizedBox(height: 4.0),
            InputCard(
              icon: Icons.water_drop_rounded,
              label: 'Wet Weight',
              subLabel: 'প্যাডিং-এর পরের ওজন',
              value: ctrl.values['wetWeight']!,
              unit: 'g',
              placeholder: '0.0',
              iconGradient: AppColors.tealIconGradient,
              accentColor: AppColors.teal,
              active: ctrl.activeId == 'wetWeight',
              onTap: () => setState(() => ctrl.setActive('wetWeight')),
            ),
            const SizedBox(height: 12),
            ResultBox(
              label: 'WET PICK-UP %',
              value: _wpu != null ? '${_wpu!.toStringAsFixed(1)}%' : '0%',
              borderColor:
                  _wpu != null ? AppColors.green : AppColors.inputBorder,
              live: _wpu != null,
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
