import 'package:flutter/material.dart';
import '../models/keypad_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/calc_scaffold.dart';
import '../widgets/formula_guide_button.dart';
import '../widgets/input_card.dart';
import '../widgets/numeric_keypad.dart';
import '../widgets/result_box.dart';

class LoomProductionCalculatorScreen extends StatefulWidget {
  const LoomProductionCalculatorScreen({super.key});

  @override
  State<LoomProductionCalculatorScreen> createState() =>
      _LoomProductionCalculatorScreenState();
}

class _LoomProductionCalculatorScreenState
    extends State<LoomProductionCalculatorScreen> {
  final ctrl = KeypadFieldController(['rpm', 'ppi', 'efficiency', 'hours']);
  double? _productionM;

  void _recalc() {
    final rpm = ctrl.number('rpm');
    final ppi = ctrl.number('ppi');
    final eff = ctrl.number('efficiency');
    final hours = ctrl.number('hours');

    setState(() {
      if (rpm != null &&
          rpm > 0 &&
          ppi != null &&
          ppi > 0 &&
          eff != null &&
          eff > 0 &&
          hours != null &&
          hours > 0) {
        // মোট পিক সংখ্যা = RPM × 60 × Hours × Efficiency%
        final totalPicks = rpm * 60 * hours * (eff / 100);
        // ফেব্রিক দৈর্ঘ্য (ইঞ্চি) = মোট পিক ÷ PPI
        final lengthInch = totalPicks / ppi;
        // মিটারে রূপান্তর (1 মিটার = 39.37 ইঞ্চি)
        _productionM = lengthInch / 39.37;
      } else {
        _productionM = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'LOOM PRODUCTION\nCALCULATOR',
      icon: Icons.precision_manufacturing_rounded,
      iconAsset: 'assets/homeicon/loom_production_calculator.webp',
      showIconBackground: false,
      onReset: () => setState(() {
        ctrl.resetAll();
        _recalc();
      }),
      extraHeaderAction: FormulaGuideButton(
        title: 'Loom Production Calculator',
        sections: const [
          FormulaGuideSection(
            heading: '📌 সংজ্ঞা (Definition)',
            body: 'তাঁতের (Loom) প্রতিটা ঘূর্ণনে একটা Weft পিক ফেব্রিকে '
                'যোগ হয়। মেশিনের RPM, ফেব্রিকের PPI (Picks per Inch) ও '
                'Efficiency % জানা থাকলে নির্দিষ্ট সময়ে কতটুকু ফেব্রিক '
                '(দৈর্ঘ্যে) উৎপাদন হবে তা হিসাব করা যায়।',
          ),
          FormulaGuideSection(
            heading: '🧮 ফরমুলা',
            body: 'মোট Picks = RPM × 60 × Working Hours × '
                '(Efficiency% ÷ 100)\n\n'
                'Fabric Length (inch) = মোট Picks ÷ PPI\n\n'
                'Fabric Length (m) = Length (inch) ÷ 39.37',
          ),
          FormulaGuideSection(
            heading: '📝 ধাপে ধাপে হিসাব',
            body: '১. তাঁতের RPM (প্রতি মিনিটে পিক ইনসার্শন) লিখুন\n'
                '২. ফেব্রিকের নির্ধারিত PPI (Picks per Inch) লিখুন\n'
                '৩. মেশিনের Efficiency % (স্টপেজ/লস বাদে) লিখুন\n'
                '৪. কাজের সময় (ঘণ্টায়) লিখুন\n'
                '৫. অ্যাপ স্বয়ংক্রিয়ভাবে উৎপাদিত ফেব্রিকের দৈর্ঘ্য '
                '(মিটারে) দেখাবে',
          ),
          FormulaGuideSection(
            heading: '💡 উদাহরণ',
            body: 'ধরুন, RPM = 500, PPI = 60, Efficiency = 85%, Hours = 8\n'
                'মোট Picks = 500 × 60 × 8 × 0.85 = 204,000\n'
                'Length (inch) = 204,000 ÷ 60 = 3,400 inch\n'
                'Length (m) = 3,400 ÷ 39.37 ≈ 86.4 m',
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
              icon: Icons.speed_rounded,
              label: 'Loom RPM',
              subLabel: 'প্রতি মিনিটে পিক',
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
              icon: Icons.density_medium_rounded,
              label: 'PPI',
              subLabel: 'Picks per Inch',
              value: ctrl.values['ppi']!,
              unit: 'PPI',
              placeholder: '0.0',
              iconGradient: AppColors.tealIconGradient,
              accentColor: AppColors.teal,
              dense: true,
              active: ctrl.activeId == 'ppi',
              onTap: () => setState(() => ctrl.setActive('ppi')),
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
              iconGradient: AppColors.purpleIconGradient,
              accentColor: AppColors.purple,
              dense: true,
              active: ctrl.activeId == 'hours',
              onTap: () => setState(() => ctrl.setActive('hours')),
            ),
            const SizedBox(height: 10),
            ResultBox(
              label: 'ESTIMATED PRODUCTION',
              value: _productionM != null
                  ? '${_productionM!.toStringAsFixed(2)} m'
                  : '0 m',
              borderColor: _productionM != null
                  ? AppColors.green
                  : AppColors.inputBorder,
              live: _productionM != null,
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
