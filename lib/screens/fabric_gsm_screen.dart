import 'package:flutter/material.dart';
import '../models/keypad_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/calc_scaffold.dart';
import '../widgets/formula_guide_button.dart';
import '../widgets/input_card.dart';
import '../widgets/numeric_keypad.dart';
import '../widgets/result_box.dart';

/// Fabric GSM Calculation
/// ইনপুট: Length (meter), Width/Dia (inch), Weight (kg)
/// আউটপুট: GSM (g/m²) — স্বয়ংক্রিয়ভাবে হিসাব হয়
class FabricGsmScreen extends StatefulWidget {
  const FabricGsmScreen({super.key});

  @override
  State<FabricGsmScreen> createState() => _FabricGsmScreenState();
}

class _FabricGsmScreenState extends State<FabricGsmScreen> {
  final ctrl = KeypadFieldController(['length', 'width', 'kg']);

  double? _gsm;

  void _recalculate() {
    final lenM = ctrl.number('length');
    final widthIn = ctrl.number('width');
    final kg = ctrl.number('kg');

    if (lenM != null && lenM > 0 && widthIn != null && widthIn > 0 && kg != null) {
      final widthM = widthIn * 0.0254;
      final res = (kg * 1000) / (lenM * widthM);
      setState(() => _gsm = res);
    } else {
      setState(() => _gsm = null);
    }
  }

  void _onDigit(String v) => setState(() {
        ctrl.appendDigit(v);
        _recalculate();
      });

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'FABRIC GSM\nCALCULATOR',
      icon: Icons.layers_rounded,
      iconAsset: 'assets/homeicon/Fabric_GSM.webp',
      showIconBackground: false,
      extraHeaderAction: FormulaGuideButton(
        title: 'Fabric GSM Calculation',
        sections: [
          FormulaGuideSection(
            heading: 'সংজ্ঞা (Definition)',
            body: 'GSM মানে Grams per Square Meter — অর্থাৎ প্রতি বর্গমিটার '
                'ফেব্রিকের ওজন কত গ্রাম। ফেব্রিক রোলের Length, Width এবং '
                'মোট Weight জানা থাকলে সেই ফেব্রিকের GSM হিসাব করা যায়। '
                'GSM দিয়ে ফেব্রিকের ঘনত্ব/মোটাত্ব বোঝা যায়।',
          ),
          FormulaGuideSection(
            heading: 'ফরমুলা (Formula)',
            body: 'GSM = (Weight (kg) × 1000) ÷ '
                '(Length (m) × Width (inch) × 0.0254)\n\n'
                'এখানে Width-কে 0.0254 দিয়ে গুণ করে মিটারে আনা হয়, '
                'কারণ GSM সবসময় বর্গমিটার (m²) এককে হিসাব করা হয়।',
          ),
          FormulaGuideSection(
            heading: 'ধাপে ধাপে ম্যানুয়াল হিসাব',
            body: '১. Width (inch)-কে 0.0254 দিয়ে গুণ করে মিটারে '
                'নিয়ে আসুন।\n'
                '২. Length (m) × Width (m) করে মোট Area (m²) বের '
                'করুন।\n'
                '৩. Weight (kg)-কে 1000 দিয়ে গুণ করে গ্রামে (g) '
                'রূপান্তর করুন।\n'
                '৪. ধাপ ৩-এর ফলাফলকে ধাপ ২-এর Area দিয়ে ভাগ করুন — '
                'এটাই GSM।',
          ),
          FormulaGuideSection(
            heading: 'উদাহরণ (Example)',
            body: 'Length = 100 m, Width = 60 inch, Weight = 27.43 kg\n\n'
                'Width (m) = 60 × 0.0254 = 1.524 m\n'
                'Area = 100 × 1.524 = 152.4 m²\n'
                'GSM = (27.43 × 1000) ÷ 152.4 ≈ 180 g/m²',
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
              label: 'Fabric GSM (g/m²)',
              value: _gsm?.toStringAsFixed(1) ?? '0.0',
              borderColor: _gsm != null ? AppColors.darkTeal : AppColors.inputBorder,
              bgColor: _gsm != null ? AppColors.gradeAGreenBg : Colors.white,
              textColor: AppColors.darkGreen,
              live: _gsm != null,
            ),
            const SizedBox(height: 6.0),
            const Text(
              '৩টি মান দিন, GSM স্বয়ংক্রিয়ভাবে দেখাবে',
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
