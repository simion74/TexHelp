import 'package:flutter/material.dart';
import '../models/keypad_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/calc_scaffold.dart';
import '../widgets/formula_guide_button.dart';
import '../widgets/input_card.dart';
import '../widgets/numeric_keypad.dart';
import '../widgets/result_box.dart';

class WarpYarnRequirementCalculatorScreen extends StatefulWidget {
  const WarpYarnRequirementCalculatorScreen({super.key});

  @override
  State<WarpYarnRequirementCalculatorScreen> createState() =>
      _WarpYarnRequirementCalculatorScreenState();
}

class _WarpYarnRequirementCalculatorScreenState
    extends State<WarpYarnRequirementCalculatorScreen> {
  final ctrl =
      KeypadFieldController(['fabricLength', 'ends', 'crimp', 'tex']);
  double? _weightKg;

  void _recalc() {
    final length = ctrl.number('fabricLength');
    final ends = ctrl.number('ends');
    final crimp = ctrl.number('crimp');
    final tex = ctrl.number('tex');

    setState(() {
      if (length != null &&
          length > 0 &&
          ends != null &&
          ends > 0 &&
          crimp != null &&
          crimp >= 0 &&
          tex != null &&
          tex > 0) {
        // মোট Warp সুতার দৈর্ঘ্য (m) = Fabric Length × Ends × (1 + Crimp%÷100)
        final totalLengthM = length * ends * (1 + crimp / 100);
        // ওজন (kg) = দৈর্ঘ্য(m) × Tex ÷ 1,000,000
        _weightKg = totalLengthM * tex / 1000000;
      } else {
        _weightKg = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'WARP YARN\nREQUIREMENT',
      icon: Icons.view_column_rounded,
      iconAsset: 'assets/homeicon/warp_yarn_requirement_calculator.webp',
      showIconBackground: false,
      onReset: () => setState(() {
        ctrl.resetAll();
        _recalc();
      }),
      extraHeaderAction: FormulaGuideButton(
        title: 'Warp Yarn Requirement',
        sections: const [
          FormulaGuideSection(
            heading: '📌 সংজ্ঞা (Definition)',
            body: 'একটা নির্দিষ্ট দৈর্ঘ্যের ফেব্রিক বুনতে মোট কত ওজনের '
                'Warp সুতা প্রয়োজন হবে, তা ফেব্রিকের দৈর্ঘ্য, মোট Ends '
                'সংখ্যা, Warp Crimp % এবং সুতার Count (Tex) দিয়ে হিসাব '
                'করা যায়।',
          ),
          FormulaGuideSection(
            heading: '🧮 ফরমুলা',
            body: 'ধাপ ১ — মোট Warp সুতার দৈর্ঘ্য (m):\n'
                'Total Length = Fabric Length(m) × Ends × '
                '(1 + Crimp% ÷ 100)\n\n'
                'ধাপ ২ — ওজনে রূপান্তর (kg):\n'
                'Weight = Total Length(m) × Tex ÷ 1,000,000',
          ),
          FormulaGuideSection(
            heading: '📝 ধাপে ধাপে হিসাব',
            body: '১. প্রয়োজনীয় ফেব্রিকের দৈর্ঘ্য (মিটারে) লিখুন\n'
                '২. মোট Warp Ends সংখ্যা লিখুন (সাধারণত EPI × ফেব্রিকের '
                'প্রস্থ ইঞ্চিতে দিয়ে হিসাব করা থাকে)\n'
                '৩. Warp Crimp % লিখুন (আগের "Fabric Crimp %" ক্যালকুলেটর '
                'থেকে বের করা যায়)\n'
                '৪. Warp সুতার Tex মান লিখুন\n'
                '৫. অ্যাপ স্বয়ংক্রিয়ভাবে মোট প্রয়োজনীয় Warp সুতার ওজন '
                '(kg) দেখাবে',
          ),
          FormulaGuideSection(
            heading: '💡 উদাহরণ',
            body: 'ধরুন, Fabric Length = 1000 m, Ends = 4000, Crimp = 8%, '
                'Tex = 20\n'
                'Total Length = 1000 × 4000 × 1.08 = 4,320,000 m\n'
                'Weight = 4,320,000 × 20 ÷ 1,000,000 = 86.4 kg',
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
              icon: Icons.straighten_rounded,
              label: 'Fabric Length',
              subLabel: 'প্রয়োজনীয় ফেব্রিক দৈর্ঘ্য',
              value: ctrl.values['fabricLength']!,
              unit: 'm',
              placeholder: '0.0',
              iconGradient: AppColors.greenIconGradient,
              accentColor: AppColors.green,
              dense: true,
              active: ctrl.activeId == 'fabricLength',
              onTap: () => setState(() => ctrl.setActive('fabricLength')),
            ),
            const SizedBox(height: 3.0),
            InputCard(
              icon: Icons.view_column_rounded,
              label: 'Total Warp Ends',
              subLabel: 'মোট এন্ডস সংখ্যা',
              value: ctrl.values['ends']!,
              unit: 'ends',
              placeholder: '0',
              iconGradient: AppColors.tealIconGradient,
              accentColor: AppColors.teal,
              dense: true,
              active: ctrl.activeId == 'ends',
              onTap: () => setState(() => ctrl.setActive('ends')),
            ),
            const SizedBox(height: 3.0),
            InputCard(
              icon: Icons.waves_rounded,
              label: 'Warp Crimp %',
              subLabel: 'সুতার বাঁক শতাংশ',
              value: ctrl.values['crimp']!,
              unit: '%',
              placeholder: '0.0',
              iconGradient: AppColors.purpleIconGradient,
              accentColor: AppColors.purple,
              dense: true,
              active: ctrl.activeId == 'crimp',
              onTap: () => setState(() => ctrl.setActive('crimp')),
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
            const SizedBox(height: 10),
            ResultBox(
              label: 'TOTAL WARP YARN REQUIRED',
              value: _weightKg != null
                  ? '${_weightKg!.toStringAsFixed(2)} kg'
                  : '0 kg',
              borderColor:
                  _weightKg != null ? AppColors.green : AppColors.inputBorder,
              live: _weightKg != null,
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
