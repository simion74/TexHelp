import 'package:flutter/material.dart';
import '../models/keypad_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/calc_scaffold.dart';
import '../widgets/compact_input_card.dart';
import '../widgets/formula_guide_button.dart';
import '../widgets/numeric_keypad.dart';
import '../widgets/result_box.dart';

class FabricConsumptionScreen extends StatefulWidget {
  const FabricConsumptionScreen({super.key});

  @override
  State<FabricConsumptionScreen> createState() =>
      _FabricConsumptionScreenState();
}

class _FabricConsumptionScreenState extends State<FabricConsumptionScreen> {
  final ctrl =
      KeypadFieldController(['body', 'sleeve', 'chest', 'allowance', 'gsm']);
  double? _kgPerDozen;

  void _recalc() {
    final body = ctrl.number('body') ?? 0;
    final sleeve = ctrl.number('sleeve') ?? 0;
    final chest = ctrl.number('chest') ?? 0;
    final allowance = ctrl.number('allowance') ?? 0;
    final gsm = ctrl.number('gsm') ?? 0;

    setState(() {
      if (body > 0 && chest > 0 && gsm > 0) {
        final totalLength = body + sleeve + allowance;
        final totalWidth = chest + (allowance / 2);
        _kgPerDozen = (totalLength * totalWidth * 2 * gsm * 12) / 10000000;
      } else {
        _kgPerDozen = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'FABRIC\nCONSUMPTION',
      icon: Icons.checkroom_rounded,
      iconAsset: 'assets/homeicon/Fabric_consumption.webp',
      extraHeaderAction: FormulaGuideButton(
        title: 'Fabric Consumption (Per Dozen)',
        sections: const [
          FormulaGuideSection(
            heading: '📌 সংজ্ঞা',
            body: 'গার্মেন্টের বডি লেংথ, স্লিভ লেংথ, চেস্ট চওড়া ও এলাউন্স '
                'থেকে এক ডজন গার্মেন্ট তৈরিতে কী পরিমাণ ফেব্রিক (কেজিতে) '
                'লাগবে তা হিসাব করা হয়।',
          ),
          FormulaGuideSection(
            heading: '🧮 ফরমুলা',
            body: 'Total Length = Body + Sleeve + Allowance\n'
                'Total Width = Chest + (Allowance ÷ 2)\n\n'
                'Fabric (kg/dozen) = (Length × Width × 2 × GSM × 12) ÷ '
                '10,000,000',
          ),
          FormulaGuideSection(
            heading: '📝 ধাপে ধাপে',
            body: '১. Body ও Sleeve লেংথ (ইঞ্চিতে) লিখুন\n'
                '২. Chest চওড়া (ইঞ্চিতে) লিখুন\n'
                '৩. কাটিং/সিম Allowance লিখুন\n'
                '৪. ফেব্রিকের GSM লিখুন — বাকিটা স্বয়ংক্রিয়ভাবে হিসাব '
                'হয়ে যাবে',
          ),
        ],
      ),
      onReset: () => setState(() {
        ctrl.resetAll();
        _recalc();
      }),
      content: Padding(
        // ইচ্ছেমতো চারপাশে প্যাডিং পরিবর্তনের জন্য
        padding: const EdgeInsets.only(
          left: 8.0,
          right: 5.0,
          top: 35.0,
          bottom: 12.0,
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CompactInputCard(
                    icon: Icons.height_rounded,
                    label: 'Body Length',
                    value: ctrl.values['body']!,
                    unit: 'cm',
                    iconGradient: AppColors.greenIconGradient,
                    accentColor: AppColors.green,
                    active: ctrl.activeId == 'body',
                    onTap: () => setState(() => ctrl.setActive('body')),
                    labelFontSize: 9,
                    labelMaxLines: 2,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CompactInputCard(
                    icon: Icons.back_hand_rounded,
                    label: 'Sleeve Length',
                    value: ctrl.values['sleeve']!,
                    unit: 'cm',
                    iconGradient: AppColors.tealIconGradient,
                    accentColor: AppColors.teal,
                    active: ctrl.activeId == 'sleeve',
                    onTap: () => setState(() => ctrl.setActive('sleeve')),
                    labelFontSize: 9,
                    labelMaxLines: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CompactInputCard(
                    icon: Icons.swap_horiz_rounded,
                    label: 'Chest Width',
                    value: ctrl.values['chest']!,
                    unit: 'cm',
                    iconGradient: AppColors.purpleIconGradient,
                    accentColor: AppColors.purple,
                    active: ctrl.activeId == 'chest',
                    onTap: () => setState(() => ctrl.setActive('chest')),
                    labelFontSize: 9,
                    labelMaxLines: 2,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CompactInputCard(
                    icon: Icons.content_cut_rounded,
                    label: 'Allowance',
                    value: ctrl.values['allowance']!,
                    unit: 'cm',
                    iconGradient: AppColors.darkTealIconGradient,
                    accentColor: AppColors.darkTeal,
                    active: ctrl.activeId == 'allowance',
                    onTap: () => setState(() => ctrl.setActive('allowance')),
                    labelFontSize: 9,
                    labelMaxLines: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // GSM ইনপুট এবং রেজাল্ট পাশাপাশি
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CompactInputCard(
                    icon: Icons.layers_rounded,
                    label: 'Fabric GSM',
                    value: ctrl.values['gsm']!,
                    unit: 'gsm',
                    iconGradient: AppColors.limeIconGradient,
                    accentColor: AppColors.lightGreen,
                    active: ctrl.activeId == 'gsm',
                    onTap: () => setState(() => ctrl.setActive('gsm')),
                    labelFontSize: 9,
                    labelMaxLines: 2,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ResultBox(
                    label: 'Consumption / Dozen',
                    value: '${_kgPerDozen?.toStringAsFixed(3) ?? '0.000'} kg',
                    bgColor: AppColors.darkGreen,
                    borderColor: AppColors.darkGreen,
                    textColor: Colors.white,
                    labelColor: Colors.white70,
                    live: _kgPerDozen != null,
                    dense: true,
                  ),
                ),
              ],
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
