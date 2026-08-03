import 'package:flutter/material.dart';
import '../models/keypad_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/calc_scaffold.dart';
import '../widgets/formula_guide_button.dart';
import '../widgets/input_card.dart';
import '../widgets/numeric_keypad.dart';
import '../widgets/result_box.dart';

class KnittingProductionCalculatorScreen extends StatefulWidget {
  const KnittingProductionCalculatorScreen({super.key});

  @override
  State<KnittingProductionCalculatorScreen> createState() =>
      _KnittingProductionCalculatorScreenState();
}

class _KnittingProductionCalculatorScreenState
    extends State<KnittingProductionCalculatorScreen> {
  final ctrl = KeypadFieldController(
      ['rpm', 'feeders', 'loopLength', 'tex', 'efficiency', 'hours']);
  double? _weightKg;
  double? _lengthM;

  void _recalc() {
    final rpm = ctrl.number('rpm');
    final feeders = ctrl.number('feeders');
    final loopMm = ctrl.number('loopLength');
    final tex = ctrl.number('tex');
    final eff = ctrl.number('efficiency');
    final hours = ctrl.number('hours');

    setState(() {
      if (rpm != null &&
          rpm > 0 &&
          feeders != null &&
          feeders > 0 &&
          loopMm != null &&
          loopMm > 0 &&
          tex != null &&
          tex > 0 &&
          eff != null &&
          eff > 0 &&
          hours != null &&
          hours > 0) {
        final loopM = loopMm / 1000;
        // মোট ব্যবহৃত সুতার দৈর্ঘ্য (মিটার) = RPM × Feeders × Loop Length(m)
        // × 60(min/hr) × Hours × Efficiency%
        _lengthM = rpm * feeders * loopM * 60 * hours * (eff / 100);
        // ওজন(kg) = দৈর্ঘ্য(m) × Tex ÷ 1,000,000
        _weightKg = _lengthM! * tex / 1000000;
      } else {
        _lengthM = null;
        _weightKg = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'KNITTING MACHINE\nPRODUCTION',
      icon: Icons.precision_manufacturing_rounded,
      iconAsset: 'assets/homeicon/knitting_production_calculator.webp',
      showIconBackground: false,
      onReset: () => setState(() {
        ctrl.resetAll();
        _recalc();
      }),
      extraHeaderAction: FormulaGuideButton(
        title: 'Knitting Machine Production',
        sections: const [
          FormulaGuideSection(
            heading: '📌 সংজ্ঞা (Definition)',
            body: 'সার্কুলার নিটিং মেশিনে নির্দিষ্ট সময়ে (শিফট/ঘণ্টা) কতটুকু '
                'ফেব্রিক (ওজনে) উৎপাদন হবে, তা মেশিনের RPM, ফিডার সংখ্যা, '
                'Loop Length ও Efficiency দিয়ে আন্দাজ করা যায় — এটা '
                'সুতার ব্যবহার (Yarn Consumption) হিসাব করে বের করা হয়।',
          ),
          FormulaGuideSection(
            heading: '🧮 ফরমুলা',
            body: 'ধাপ ১ — মোট সুতার দৈর্ঘ্য (মিটার):\n'
                'Length = RPM × Feeders × Loop Length(m) × 60 × Hours × '
                '(Efficiency ÷ 100)\n\n'
                'ধাপ ২ — ওজনে রূপান্তর (kg):\n'
                'Weight = Length(m) × Tex ÷ 1,000,000',
          ),
          FormulaGuideSection(
            heading: '📝 ধাপে ধাপে হিসাব',
            body: '১. মেশিনের RPM (প্রতি মিনিটে ঘূর্ণন) লিখুন\n'
                '২. মেশিনে মোট কতগুলো Feeder সক্রিয় আছে লিখুন\n'
                '৩. ব্যবহৃত Loop Length (mm) লিখুন\n'
                '৪. সুতার Tex মান লিখুন\n'
                '৫. মেশিনের Efficiency % (স্টপেজ/লস বাদ দিয়ে প্রকৃত কর্মদক্ষতা) '
                'লিখুন\n'
                '৬. কাজের সময় (ঘণ্টায়) লিখুন — যেমন একটা শিফট ৮ ঘণ্টা হলে '
                '৮ লিখুন',
          ),
          FormulaGuideSection(
            heading: '⚠️ গুরুত্বপূর্ণ নোট',
            body: 'এটা একটা তাত্ত্বিক (theoretical) আন্দাজ — সুতার ব্যবহার '
                'অনুযায়ী উৎপাদিত ফেব্রিকের ওজন হিসাব করে। বাস্তবে ফেব্রিক '
                'ওয়েস্ট, শ্রিংকেজ, ও অন্যান্য প্রসেস লসের কারণে প্রকৃত '
                'আউটপুট এখানকার হিসাবের চেয়ে কিছুটা কম হতে পারে।',
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
              icon: Icons.speed_rounded,
              label: 'Machine RPM',
              subLabel: 'ঘূর্ণন প্রতি মিনিট',
              value: ctrl.values['rpm']!,
              unit: 'RPM',
              placeholder: '0.0',
              iconGradient: AppColors.greenIconGradient,
              accentColor: AppColors.green,
              dense: true,
              active: ctrl.activeId == 'rpm',
              onTap: () => setState(() => ctrl.setActive('rpm')),
            ),
            const SizedBox(height: 3.0),
            InputCard(
              icon: Icons.input_rounded,
              label: 'No. of Feeders',
              subLabel: 'সক্রিয় ফিডার সংখ্যা',
              value: ctrl.values['feeders']!,
              unit: 'pcs',
              placeholder: '0',
              iconGradient: AppColors.tealIconGradient,
              accentColor: AppColors.teal,
              dense: true,
              active: ctrl.activeId == 'feeders',
              onTap: () => setState(() => ctrl.setActive('feeders')),
            ),
            const SizedBox(height: 3.0),
            InputCard(
              icon: Icons.all_out_rounded,
              label: 'Loop Length',
              subLabel: 'Stitch Length',
              value: ctrl.values['loopLength']!,
              unit: 'mm',
              placeholder: '0.0',
              iconGradient: AppColors.purpleIconGradient,
              accentColor: AppColors.purple,
              dense: true,
              active: ctrl.activeId == 'loopLength',
              onTap: () => setState(() => ctrl.setActive('loopLength')),
            ),
            const SizedBox(height: 3.0),
            InputCard(
              icon: Icons.tag_rounded,
              label: 'Yarn Count',
              subLabel: 'Tex System',
              value: ctrl.values['tex']!,
              unit: 'Tex',
              placeholder: '0.0',
              iconGradient: AppColors.darkTealIconGradient,
              accentColor: AppColors.darkTeal,
              dense: true,
              active: ctrl.activeId == 'tex',
              onTap: () => setState(() => ctrl.setActive('tex')),
            ),
            const SizedBox(height: 3.0),
            InputCard(
              icon: Icons.percent_rounded,
              label: 'Machine Efficiency',
              subLabel: 'কর্মদক্ষতা %',
              value: ctrl.values['efficiency']!,
              unit: '%',
              placeholder: '0.0',
              iconGradient: AppColors.limeIconGradient,
              accentColor: AppColors.lightGreen,
              dense: true,
              active: ctrl.activeId == 'efficiency',
              onTap: () => setState(() => ctrl.setActive('efficiency')),
            ),
            const SizedBox(height: 3.0),
            InputCard(
              icon: Icons.schedule_rounded,
              label: 'Working Hours',
              subLabel: 'শিফট/কাজের সময়',
              value: ctrl.values['hours']!,
              unit: 'hr',
              placeholder: '0.0',
              iconGradient: AppColors.greenIconGradient,
              accentColor: AppColors.green,
              dense: true,
              active: ctrl.activeId == 'hours',
              onTap: () => setState(() => ctrl.setActive('hours')),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ResultBox(
                    label: 'YARN CONSUMED',
                    value: _lengthM != null
                        ? '${_lengthM!.toStringAsFixed(0)} m'
                        : '0 m',
                    borderColor: _lengthM != null
                        ? AppColors.teal
                        : AppColors.inputBorder,
                    textColor: AppColors.teal,
                    dense: true,
                    live: _lengthM != null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ResultBox(
                    label: 'ESTIMATED PRODUCTION',
                    value: _weightKg != null
                        ? '${_weightKg!.toStringAsFixed(2)} kg'
                        : '0 kg',
                    borderColor: _weightKg != null
                        ? AppColors.green
                        : AppColors.inputBorder,
                    dense: true,
                    live: _weightKg != null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      keypad: NumericKeypad(
        height: 190,
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
