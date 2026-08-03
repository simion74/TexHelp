import 'package:flutter/material.dart';
import '../models/keypad_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/calc_scaffold.dart';
import '../widgets/formula_guide_button.dart';
import '../widgets/input_card.dart';
import '../widgets/numeric_keypad.dart';
import '../widgets/result_box.dart';

class StitchDensityCalculatorScreen extends StatefulWidget {
  const StitchDensityCalculatorScreen({super.key});

  @override
  State<StitchDensityCalculatorScreen> createState() =>
      _StitchDensityCalculatorScreenState();
}

class _StitchDensityCalculatorScreenState
    extends State<StitchDensityCalculatorScreen> {
  final ctrl = KeypadFieldController(['cpi', 'wpi']);
  double? _sd;

  void _recalc() {
    final cpi = ctrl.number('cpi');
    final wpi = ctrl.number('wpi');

    setState(() {
      if (cpi != null && cpi > 0 && wpi != null && wpi > 0) {
        // Stitch Density = Courses per inch × Wales per inch
        _sd = cpi * wpi;
      } else {
        _sd = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'STITCH DENSITY\nCALCULATOR',
      icon: Icons.grid_on_rounded,
      iconAsset: 'assets/homeicon/stitch_density_calculator.webp',
      showIconBackground: false,
      onReset: () => setState(() {
        ctrl.resetAll();
        _recalc();
      }),
      extraHeaderAction: FormulaGuideButton(
        title: 'Stitch Density Calculator',
        sections: const [
          FormulaGuideSection(
            heading: '📌 সংজ্ঞা (Definition)',
            body: 'নিটেড ফেব্রিকে Course হলো আনুভূমিক (horizontal) লুপের '
                'সারি, আর Wale হলো উলম্ব (vertical) লুপের সারি। Stitch '
                'Density (SD) দিয়ে বোঝা যায় ফেব্রিকের প্রতি বর্গ ইঞ্চিতে '
                'মোট কতগুলো লুপ (স্টিচ) আছে — এটা ফেব্রিকের কম্প্যাক্টনেস '
                '(ঘনত্ব) নির্দেশ করে।',
          ),
          FormulaGuideSection(
            heading: '🧮 ফরমুলা',
            body: 'Stitch Density (SD) = Courses per Inch (CPI) × '
                'Wales per Inch (WPI)\n\n'
                'CPI ও WPI দুটোই সাধারণত একটা Pick Glass/Counting Glass '
                'দিয়ে ফেব্রিকের উপর সরাসরি গুণে বের করা হয়।',
          ),
          FormulaGuideSection(
            heading: '📝 ধাপে ধাপে হিসাব',
            body: '১. Pick Glass দিয়ে ফেব্রিকের ১ ইঞ্চিতে কতগুলো Course '
                '(অনুভূমিক সারি) আছে গুণুন\n'
                '২. একইভাবে ১ ইঞ্চিতে কতগুলো Wale (উলম্ব সারি) আছে গুণুন\n'
                '৩. দুটো সংখ্যা গুণ করলেই Stitch Density পাওয়া যাবে',
          ),
          FormulaGuideSection(
            heading: '💡 উদাহরণ',
            body: 'ধরুন, CPI = 40 এবং WPI = 32\n'
                'Stitch Density = 40 × 32 = 1280 stitches/sq.inch\n\n'
                'নোট: বেশি Stitch Density মানে ফেব্রিক বেশি কম্প্যাক্ট/ভারী, '
                'কম Stitch Density মানে ফেব্রিক বেশি খোলামেলা/হালকা।',
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
              icon: Icons.horizontal_rule_rounded,
              label: 'Courses per Inch',
              subLabel: 'CPI (আনুভূমিক সারি/ইঞ্চি)',
              value: ctrl.values['cpi']!,
              unit: 'CPI',
              placeholder: '0.0',
              iconGradient: AppColors.greenIconGradient,
              accentColor: AppColors.green,
              active: ctrl.activeId == 'cpi',
              onTap: () => setState(() => ctrl.setActive('cpi')),
            ),
            const SizedBox(height: 4.0),
            InputCard(
              icon: Icons.height_rounded,
              label: 'Wales per Inch',
              subLabel: 'WPI (উলম্ব সারি/ইঞ্চি)',
              value: ctrl.values['wpi']!,
              unit: 'WPI',
              placeholder: '0.0',
              iconGradient: AppColors.tealIconGradient,
              accentColor: AppColors.teal,
              active: ctrl.activeId == 'wpi',
              onTap: () => setState(() => ctrl.setActive('wpi')),
            ),
            const SizedBox(height: 12),
            ResultBox(
              label: 'STITCH DENSITY (per sq.inch)',
              value: _sd?.toStringAsFixed(0) ?? '0',
              borderColor:
                  _sd != null ? AppColors.green : AppColors.inputBorder,
              live: _sd != null,
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
