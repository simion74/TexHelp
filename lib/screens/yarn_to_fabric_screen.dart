import 'package:flutter/material.dart';
import '../models/keypad_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/calc_scaffold.dart';
import '../widgets/compact_input_card.dart';
import '../widgets/formula_guide_button.dart';
import '../widgets/numeric_keypad.dart';
import '../widgets/result_box.dart';

class YarnToFabricScreen extends StatefulWidget {
  const YarnToFabricScreen({super.key});

  @override
  State<YarnToFabricScreen> createState() => _YarnToFabricScreenState();
}

class _YarnToFabricScreenState extends State<YarnToFabricScreen> {
  final ctrl = KeypadFieldController(['yarnWeight', 'wastage', 'gsm', 'width']);

  double? _meters;
  double? _yards;
  double? _netWeight;

  @override
  void initState() {
    super.initState();
    // নিটিং ওয়েস্টেজ সাধারণত ৩% থেকে শুরু হয়, তাই ডিফল্ট মান ৩ দেওয়া হলো
    ctrl.setValue('wastage', '3');
  }

  void _recalc() {
    final yarnKg = ctrl.number('yarnWeight');
    final gsmVal = ctrl.number('gsm');
    final widthInch = ctrl.number('width');
    final wastePct = ctrl.number('wastage') ?? 0;

    setState(() {
      if (yarnKg != null &&
          yarnKg > 0 &&
          gsmVal != null &&
          gsmVal > 0 &&
          widthInch != null &&
          widthInch > 0) {
        final netWeightKg = yarnKg * (1 - (wastePct / 100));
        _netWeight = netWeightKg;

        // সূত্র: (নিট ওজন * ৩৯৩৭০) / (GSM * প্রস্থ ইঞ্চিতে)
        final lengthMeters = (netWeightKg * 39370) / (gsmVal * widthInch);
        _meters = lengthMeters;
        _yards = lengthMeters * 1.09361;
      } else {
        _netWeight = null;
        _meters = null;
        _yards = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'YARN TO KNIT\nFABRIC',
      icon: Icons.sync_alt_rounded,
      iconAsset: 'assets/homeicon/Yarn_to_knit_fabric.webp',
      extraHeaderAction: FormulaGuideButton(
        title: 'Yarn to Knit Fabric',
        sections: const [
          FormulaGuideSection(
            heading: '📌 সংজ্ঞা',
            body: 'নির্দিষ্ট পরিমাণ সুতা (ওয়েস্টেজ বাদে) দিয়ে কত মিটার/'
                'গজ নিট ফেব্রিক তৈরি হবে তা GSM ও ফেব্রিকের প্রস্থ '
                'অনুযায়ী হিসাব করা হয়।',
          ),
          FormulaGuideSection(
            heading: '🧮 ফরমুলা',
            body: 'Net Yarn (kg) = Yarn Weight × (1 − (Wastage% ÷ 100))\n\n'
                'Length (m) = (Net Yarn(kg) × 39370) ÷ (GSM × Width(inch))\n\n'
                'Yards = Length(m) × 1.09361',
          ),
        ],
      ),
      onReset: () => setState(() {
        ctrl.resetAll();
        ctrl.setValue('wastage', '3');
        _recalc();
      }),
      content: Padding(
        // আপনার পছন্দমতো প্যাডিং সেট করার জায়গা
        padding: const EdgeInsets.only(
          left: 9.0,
          right: 9.0,
          top: 28.0,
          bottom: 8.0,
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CompactInputCard(
                    icon: Icons.shopping_bag_rounded,
                    label: 'Yarn Weight',
                    value: ctrl.values['yarnWeight']!,
                    unit: 'kg',
                    iconGradient: AppColors.greenIconGradient,
                    accentColor: AppColors.green,
                    active: ctrl.activeId == 'yarnWeight',
                    onTap: () => setState(() => ctrl.setActive('yarnWeight')),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CompactInputCard(
                    icon: Icons.percent_rounded,
                    label: 'Wastage',
                    value: ctrl.values['wastage']!,
                    unit: '%',
                    iconGradient: AppColors.tealIconGradient,
                    accentColor: AppColors.teal,
                    active: ctrl.activeId == 'wastage',
                    onTap: () => setState(() => ctrl.setActive('wastage')),
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
                    icon: Icons.layers_rounded,
                    label: 'Target GSM',
                    value: ctrl.values['gsm']!,
                    unit: 'gsm',
                    iconGradient: AppColors.purpleIconGradient,
                    accentColor: AppColors.purple,
                    active: ctrl.activeId == 'gsm',
                    onTap: () => setState(() => ctrl.setActive('gsm')),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CompactInputCard(
                    icon: Icons.swap_horiz_rounded,
                    label: 'Width',
                    value: ctrl.values['width']!,
                    unit: 'in',
                    iconGradient: AppColors.darkTealIconGradient,
                    accentColor: AppColors.darkTeal,
                    active: ctrl.activeId == 'width',
                    onTap: () => setState(() => ctrl.setActive('width')),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ResultBox(
              label: 'Total Fabric (Yards)',
              value: _yards?.toStringAsFixed(2) ?? '0.00',
              borderColor:
                  _yards != null ? AppColors.teal : AppColors.inputBorder,
              textColor: AppColors.teal,
              live: _yards != null,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ResultBox(
                    label: 'Meters',
                    value: _meters?.toStringAsFixed(2) ?? '0.00',
                    borderColor: _meters != null
                        ? AppColors.green
                        : AppColors.inputBorder,
                    live: _meters != null,
                    dense: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ResultBox(
                    label: 'Net Weight (kg)',
                    value: _netWeight?.toStringAsFixed(2) ?? '0.00',
                    borderColor: _netWeight != null
                        ? AppColors.purple
                        : AppColors.inputBorder,
                    live: _netWeight != null,
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
