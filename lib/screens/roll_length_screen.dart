import 'package:flutter/material.dart';
import '../models/keypad_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/calc_scaffold.dart';
import '../widgets/formula_guide_button.dart';
import '../widgets/input_card.dart';
import '../widgets/numeric_keypad.dart';
import '../widgets/result_box.dart';

/// Roll Length Calculation
/// ইনপুট: Width/Dia (inch), GSM (g/m²), Weight (kg)
/// আউটপুট: Length (meter) — স্বয়ংক্রিয়ভাবে হিসাব হয়
class RollLengthScreen extends StatefulWidget {
  const RollLengthScreen({super.key});

  @override
  State<RollLengthScreen> createState() => _RollLengthScreenState();
}

class _RollLengthScreenState extends State<RollLengthScreen> {
  final ctrl = KeypadFieldController(['width', 'gsm', 'kg']);

  double? _lengthM;

  void _recalculate() {
    final widthIn = ctrl.number('width');
    final gsm = ctrl.number('gsm');
    final kg = ctrl.number('kg');

    if (widthIn != null && widthIn > 0 && gsm != null && gsm > 0 && kg != null) {
      final widthM = widthIn * 0.0254;
      final res = (kg * 1000) / (widthM * gsm);
      setState(() => _lengthM = res);
    } else {
      setState(() => _lengthM = null);
    }
  }

  void _onDigit(String v) => setState(() {
        ctrl.appendDigit(v);
        _recalculate();
      });

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'ROLL LENGTH\nCALCULATOR',
      icon: Icons.straighten_rounded,
      iconAsset: 'assets/homeicon/Roll_Length.webp',
      showIconBackground: false,
      extraHeaderAction: FormulaGuideButton(
        title: 'Roll Length Calculation',
        sections: [
          FormulaGuideSection(
            heading: 'সংজ্ঞা (Definition)',
            body: 'ফেব্রিক রোলের Width, GSM এবং মোট Weight জানা থাকলে '
                'সেই রোলের Length (দৈর্ঘ্য) হিসাব করা যায়। কাপড় কেনা-বেচার '
                'সময় বা ইনভেন্টরি চেক করার সময় এই হিসাব খুব দরকারি হয়, '
                'কারণ রোলের গায়ে সবসময় Length লেখা না-ও থাকতে পারে।',
          ),
          FormulaGuideSection(
            heading: 'ফরমুলা (Formula)',
            body: 'Length (m) = (Weight (kg) × 1000) ÷ '
                '(Width (inch) × 0.0254 × GSM)\n\n'
                'এখানে Width (inch) × 0.0254 করে প্রথমে Width-কে '
                'মিটারে রূপান্তর করা হয়, কারণ GSM (g/m²) মিটার এককে '
                'হিসাব করা।',
          ),
          FormulaGuideSection(
            heading: 'ধাপে ধাপে ম্যানুয়াল হিসাব',
            body: '১. Width (inch)-কে 0.0254 দিয়ে গুণ করে মিটারে '
                'নিয়ে আসুন।\n'
                '২. Weight (kg)-কে 1000 দিয়ে গুণ করে গ্রামে (g) '
                'রূপান্তর করুন।\n'
                '৩. ধাপ ২-এর ফলাফলকে (Width in meter × GSM) দিয়ে '
                'ভাগ করুন।\n'
                '৪. প্রাপ্ত সংখ্যাটিই হলো রোলের Length (মিটারে)।',
          ),
          FormulaGuideSection(
            heading: 'উদাহরণ (Example)',
            body: 'Width = 60 inch, GSM = 180, Weight = 32.62 kg\n\n'
                'Width (m) = 60 × 0.0254 = 1.524 m\n'
                'Length = (32.62 × 1000) ÷ (1.524 × 180)\n'
                'Length ≈ 118.9 meter',
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
              icon: Icons.swap_horiz_rounded,
              label: 'Width / Dia',
              subLabel: 'Fabric Width',
              value: ctrl.values['width']!,
              unit: 'inch',
              placeholder: '0.0',
              iconGradient: AppColors.tealIconGradient,
              accentColor: AppColors.teal,
              active: ctrl.activeId == 'width',
              onTap: () => setState(() => ctrl.setActive('width')),
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
              label: 'Roll Length (Meter)',
              value: _lengthM?.toStringAsFixed(2) ?? '0.00',
              borderColor: _lengthM != null ? AppColors.green : AppColors.inputBorder,
              bgColor: _lengthM != null ? AppColors.gradeAGreenBg : Colors.white,
              textColor: AppColors.darkGreen,
              live: _lengthM != null,
            ),
            const SizedBox(height: 6.0),
            const Text(
              '৩টি মান দিন, Length স্বয়ংক্রিয়ভাবে দেখাবে',
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
