import 'package:flutter/material.dart';
import '../models/keypad_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/calc_scaffold.dart';
import '../widgets/formula_guide_button.dart';
import '../widgets/input_card.dart';
import '../widgets/numeric_keypad.dart';
import '../widgets/result_box.dart';

/// Roll Dia / Width Calculation
/// ইনপুট: Length (meter), GSM (g/m²), Weight (kg)
/// আউটপুট: Width / Dia (inch) — স্বয়ংক্রিয়ভাবে হিসাব হয়
class RollDiaWidthScreen extends StatefulWidget {
  const RollDiaWidthScreen({super.key});

  @override
  State<RollDiaWidthScreen> createState() => _RollDiaWidthScreenState();
}

class _RollDiaWidthScreenState extends State<RollDiaWidthScreen> {
  final ctrl = KeypadFieldController(['length', 'gsm', 'kg']);

  double? _widthIn;

  void _recalculate() {
    final lenM = ctrl.number('length');
    final gsm = ctrl.number('gsm');
    final kg = ctrl.number('kg');

    if (lenM != null && lenM > 0 && gsm != null && gsm > 0 && kg != null) {
      final widthM = (kg * 1000) / (lenM * gsm);
      final widthInch = widthM / 0.0254;
      setState(() => _widthIn = widthInch);
    } else {
      setState(() => _widthIn = null);
    }
  }

  void _onDigit(String v) => setState(() {
        ctrl.appendDigit(v);
        _recalculate();
      });

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'ROLL DIA/WIDTH\nCALCULATOR',
      icon: Icons.swap_horiz_rounded,
      iconAsset: 'assets/homeicon/Roll_DIA_Width_Calculator.webp',
      showIconBackground: false,
      extraHeaderAction: FormulaGuideButton(
        title: 'Roll Dia / Width Calculation',
        sections: [
          FormulaGuideSection(
            heading: 'সংজ্ঞা (Definition)',
            body: 'ফেব্রিক রোলের Length, GSM এবং মোট Weight জানা থাকলে '
                'সেই রোলের Width বা Dia (ব্যাস) হিসাব করা যায়। রোল '
                'বেশি বড় হলে বা লেবেল না থাকলে সরাসরি মেপে Width বের '
                'করা কঠিন হয়ে যায়, তখন এই ফরমুলা কাজে লাগে।',
          ),
          FormulaGuideSection(
            heading: 'ফরমুলা (Formula)',
            body: 'Width (inch) = [(Weight (kg) × 1000) ÷ '
                '(Length (m) × GSM)] ÷ 0.0254\n\n'
                'প্রথমে Width মিটার এককে বের করা হয়, তারপর 0.0254 '
                'দিয়ে ভাগ করে ইঞ্চিতে রূপান্তর করা হয় (যেহেতু '
                '1 inch = 0.0254 meter)।',
          ),
          FormulaGuideSection(
            heading: 'ধাপে ধাপে ম্যানুয়াল হিসাব',
            body: '১. Weight (kg)-কে 1000 দিয়ে গুণ করে গ্রামে নিয়ে '
                'আসুন।\n'
                '২. ধাপ ১-এর ফলাফলকে (Length (m) × GSM) দিয়ে ভাগ '
                'করুন — এতে Width মিটারে পাওয়া যাবে।\n'
                '৩. প্রাপ্ত মিটার মানকে 0.0254 দিয়ে ভাগ করুন — এতে '
                'Width ইঞ্চিতে পাওয়া যাবে।',
          ),
          FormulaGuideSection(
            heading: 'উদাহরণ (Example)',
            body: 'Length = 118.9 m, GSM = 180, Weight = 32.62 kg\n\n'
                'Width (m) = (32.62 × 1000) ÷ (118.9 × 180)\n'
                'Width (m) ≈ 1.524 m\n'
                'Width (inch) = 1.524 ÷ 0.0254 ≈ 60 inch',
          ),
        ],
      ),
      onReset: () => setState(() {
        ctrl.resetAll();
        _recalculate();
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
            InputCard(
              icon: Icons.straighten_rounded,
              label: 'Length',
              subLabel: 'Fabric Length',
              value: ctrl.values['length']!,
              unit: 'mtr',
              placeholder: '0.0',
              iconGradient: AppColors.greenIconGradient,
              accentColor: AppColors.green,
              active: ctrl.activeId == 'length',
              onTap: () => setState(() => ctrl.setActive('length')),
            ),
            const SizedBox(height: 8.0),
            InputCard(
              icon: Icons.layers_rounded,
              label: 'GSM',
              subLabel: '(g/m²)',
              value: ctrl.values['gsm']!,
              unit: 'g/m²',
              placeholder: '0.0',
              iconGradient: AppColors.darkTealIconGradient,
              accentColor: AppColors.darkTeal,
              active: ctrl.activeId == 'gsm',
              onTap: () => setState(() => ctrl.setActive('gsm')),
            ),
            const SizedBox(height: 8.0),
            InputCard(
              icon: Icons.monitor_weight_rounded,
              label: 'Weight',
              subLabel: '(Kg)',
              value: ctrl.values['kg']!,
              unit: 'KG',
              placeholder: '0.0',
              iconGradient: AppColors.limeIconGradient,
              accentColor: AppColors.lightGreen,
              active: ctrl.activeId == 'kg',
              onTap: () => setState(() => ctrl.setActive('kg')),
            ),
            const SizedBox(height: 10.0),
            ResultBox(
              label: 'Roll Width / Dia (Inch)',
              value: _widthIn?.toStringAsFixed(2) ?? '0.00',
              borderColor: _widthIn != null ? AppColors.teal : AppColors.inputBorder,
              bgColor: _widthIn != null ? AppColors.gradeAGreenBg : Colors.white,
              textColor: AppColors.darkGreen,
              live: _widthIn != null,
            ),
            const SizedBox(height: 6.0),
            const Text(
              '৩টি মান দিন, Width/Dia স্বয়ংক্রিয়ভাবে দেখাবে',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.black54),
            ),
          ],
        ),
      ),
      keypad: NumericKeypad(
        onDigit: _onDigit,
        onBackspace: () => setState(() {
          ctrl.backspace();
          _recalculate();
        }),
        onClear: () => setState(() {
          ctrl.clearActive();
          _recalculate();
        }),
        onUp: () => setState(() => ctrl.moveField(-1)),
        onDown: () => setState(() => ctrl.moveField(1)),
      ),
    );
  }
}
