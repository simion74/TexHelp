import 'package:flutter/material.dart';
import '../models/keypad_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/calc_scaffold.dart';
import '../widgets/formula_guide_button.dart';
import '../widgets/input_card.dart';
import '../widgets/numeric_keypad.dart';
import '../widgets/result_box.dart';

/// Fabric Weight (kg) Calculation
/// ইনপুট: Length (meter), Width/Dia (inch), GSM (g/m²)
/// আউটপুট: Weight (kg) — স্বয়ংক্রিয়ভাবে হিসাব হয়
class FabricWeightScreen extends StatefulWidget {
  const FabricWeightScreen({super.key});

  @override
  State<FabricWeightScreen> createState() => _FabricWeightScreenState();
}

class _FabricWeightScreenState extends State<FabricWeightScreen> {
  final ctrl = KeypadFieldController(['length', 'width', 'gsm']);

  double? _weightKg;

  void _recalculate() {
    final lenM = ctrl.number('length');
    final widthIn = ctrl.number('width');
    final gsm = ctrl.number('gsm');

    if (lenM != null && lenM > 0 && widthIn != null && widthIn > 0 && gsm != null) {
      final widthM = widthIn * 0.0254;
      final res = (lenM * widthM * gsm) / 1000;
      setState(() => _weightKg = res);
    } else {
      setState(() => _weightKg = null);
    }
  }

  void _onDigit(String v) => setState(() {
        ctrl.appendDigit(v);
        _recalculate();
      });

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'FABRIC WEIGHT (KG)\nCALCULATOR',
      icon: Icons.monitor_weight_rounded,
      iconAsset: 'assets/homeicon/Fabric weight (kg).webp',
      showIconBackground: false,
      extraHeaderAction: FormulaGuideButton(
        title: 'Fabric Weight (kg) Calculation',
        sections: [
          FormulaGuideSection(
            heading: 'সংজ্ঞা (Definition)',
            body: 'ফেব্রিক রোলের Length, Width এবং GSM জানা থাকলে সেই '
                'রোলের মোট Weight (কেজিতে) হিসাব করা যায়। শিপমেন্টের '
                'আগে বা অর্ডার প্ল্যানিং করার সময় এই হিসাবটা খুবই '
                'গুরুত্বপূর্ণ, কারণ এখান থেকেই কাপড়ের দাম ও শিপিং কস্ট '
                'নির্ধারণ হয়।',
          ),
          FormulaGuideSection(
            heading: 'ফরমুলা (Formula)',
            body: 'Weight (kg) = (Length (m) × Width (inch) × 0.0254 × '
                'GSM) ÷ 1000\n\n'
                'এখানে Width-কে 0.0254 দিয়ে গুণ করে মিটারে আনা হয়, '
                'এবং শেষে 1000 দিয়ে ভাগ করে গ্রাম থেকে কেজিতে '
                'রূপান্তর করা হয়।',
          ),
          FormulaGuideSection(
            heading: 'ধাপে ধাপে ম্যানুয়াল হিসাব',
            body: '১. Width (inch)-কে 0.0254 দিয়ে গুণ করে মিটারে '
                'নিয়ে আসুন।\n'
                '২. Length (m) × Width (m) করে মোট Area (m²) বের '
                'করুন।\n'
                '৩. Area-কে GSM দিয়ে গুণ করুন — এতে Weight গ্রামে '
                'পাওয়া যাবে।\n'
                '৪. প্রাপ্ত মানকে 1000 দিয়ে ভাগ করুন — এতে Weight '
                'কেজিতে পাওয়া যাবে।',
          ),
          FormulaGuideSection(
            heading: 'উদাহরণ (Example)',
            body: 'Length = 100 m, Width = 60 inch, GSM = 180\n\n'
                'Width (m) = 60 × 0.0254 = 1.524 m\n'
                'Area = 100 × 1.524 = 152.4 m²\n'
                'Weight = (152.4 × 180) ÷ 1000 ≈ 27.43 kg',
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
            const SizedBox(height: 10.0),
            ResultBox(
              label: 'Fabric Weight (Kg)',
              value: _weightKg?.toStringAsFixed(2) ?? '0.00',
              borderColor: _weightKg != null ? AppColors.lightGreen : AppColors.inputBorder,
              bgColor: _weightKg != null ? AppColors.gradeAGreenBg : Colors.white,
              textColor: AppColors.darkGreen,
              live: _weightKg != null,
            ),
            const SizedBox(height: 6.0),
            const Text(
              '৩টি মান দিন, Weight স্বয়ংক্রিয়ভাবে দেখাবে',
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
