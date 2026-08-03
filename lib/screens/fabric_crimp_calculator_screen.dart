import 'package:flutter/material.dart';
import '../models/keypad_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/calc_scaffold.dart';
import '../widgets/formula_guide_button.dart';
import '../widgets/input_card.dart';
import '../widgets/numeric_keypad.dart';
import '../widgets/result_box.dart';

class FabricCrimpCalculatorScreen extends StatefulWidget {
  const FabricCrimpCalculatorScreen({super.key});

  @override
  State<FabricCrimpCalculatorScreen> createState() =>
      _FabricCrimpCalculatorScreenState();
}

class _FabricCrimpCalculatorScreenState
    extends State<FabricCrimpCalculatorScreen> {
  final ctrl = KeypadFieldController(['fabricLength', 'yarnLength']);
  double? _crimp;

  void _recalc() {
    final fabric = ctrl.number('fabricLength');
    final yarn = ctrl.number('yarnLength');

    setState(() {
      if (fabric != null && fabric > 0 && yarn != null && yarn > fabric) {
        // Crimp % = ((Yarn Length − Fabric Length) ÷ Fabric Length) × 100
        _crimp = ((yarn - fabric) / fabric) * 100;
      } else {
        _crimp = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'FABRIC CRIMP %\nCALCULATOR',
      icon: Icons.waves_rounded,
      iconAsset: 'assets/homeicon/fabric_crimp_calculator.webp',
      showIconBackground: false,
      onReset: () => setState(() {
        ctrl.resetAll();
        _recalc();
      }),
      extraHeaderAction: FormulaGuideButton(
        title: 'Fabric Crimp % Calculator',
        sections: const [
          FormulaGuideSection(
            heading: '📌 সংজ্ঞা (Definition)',
            body: 'উইভিং-এ সুতা ফেব্রিকের মধ্যে সোজা না থেকে ঢেউয়ের মতো '
                '(up-down) বেঁকে থাকে — একে Crimp বলে। এই বাঁকের কারণে '
                'ফেব্রিকের মধ্যে থাকা সুতার প্রকৃত দৈর্ঘ্য, ফেব্রিকের '
                'সরাসরি দৈর্ঘ্যের চেয়ে বেশি হয়। Crimp % জানা থাকলে '
                'সঠিক ইয়ার্ন রিকোয়্যারমেন্ট হিসাব করা যায়।',
          ),
          FormulaGuideSection(
            heading: '🧮 ফরমুলা',
            body: 'Crimp % = ((Yarn Length in Fabric − Fabric Length) ÷ '
                'Fabric Length) × 100',
          ),
          FormulaGuideSection(
            heading: '📝 ধাপে ধাপে হিসাব',
            body: '১. ফেব্রিকের একটা নির্দিষ্ট অংশের দৈর্ঘ্য মাপুন (Fabric '
                'Length)\n'
                '২. সেই একই অংশ থেকে সুতা খুলে সোজা করে তার দৈর্ঘ্য মাপুন '
                '(Yarn Length) — এটা সবসময় Fabric Length-এর চেয়ে বেশি '
                'হবে\n'
                '৩. পার্থক্য বের করে Fabric Length দিয়ে ভাগ করে ১০০ '
                'দিয়ে গুণ করলেই Crimp % পাওয়া যাবে',
          ),
          FormulaGuideSection(
            heading: '💡 উদাহরণ',
            body: 'ধরুন, Fabric Length = 100 cm এবং সোজা করা Yarn Length '
                '= 106 cm\n'
                'Crimp % = ((106 − 100) ÷ 100) × 100 = 6%\n\n'
                'Warp ও Weft-এর Crimp % সাধারণত আলাদা আলাদা হয়, তাই দুটোই '
                'আলাদাভাবে মাপা উচিত।',
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
              icon: Icons.straighten_rounded,
              label: 'Fabric Length',
              subLabel: 'ফেব্রিকের সরাসরি দৈর্ঘ্য',
              value: ctrl.values['fabricLength']!,
              unit: 'cm',
              placeholder: '0.0',
              iconGradient: AppColors.greenIconGradient,
              accentColor: AppColors.green,
              active: ctrl.activeId == 'fabricLength',
              onTap: () => setState(() => ctrl.setActive('fabricLength')),
            ),
            const SizedBox(height: 4.0),
            InputCard(
              icon: Icons.waves_rounded,
              label: 'Yarn Length (Uncrimped)',
              subLabel: 'সুতা সোজা করার পর দৈর্ঘ্য',
              value: ctrl.values['yarnLength']!,
              unit: 'cm',
              placeholder: '0.0',
              iconGradient: AppColors.tealIconGradient,
              accentColor: AppColors.teal,
              active: ctrl.activeId == 'yarnLength',
              onTap: () => setState(() => ctrl.setActive('yarnLength')),
            ),
            const SizedBox(height: 12),
            ResultBox(
              label: 'CRIMP %',
              value: _crimp != null ? '${_crimp!.toStringAsFixed(2)}%' : '0%',
              borderColor:
                  _crimp != null ? AppColors.green : AppColors.inputBorder,
              live: _crimp != null,
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
