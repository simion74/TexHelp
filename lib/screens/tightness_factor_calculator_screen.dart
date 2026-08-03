import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/keypad_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/calc_scaffold.dart';
import '../widgets/formula_guide_button.dart';
import '../widgets/input_card.dart';
import '../widgets/numeric_keypad.dart';
import '../widgets/result_box.dart';

class TightnessFactorCalculatorScreen extends StatefulWidget {
  const TightnessFactorCalculatorScreen({super.key});

  @override
  State<TightnessFactorCalculatorScreen> createState() =>
      _TightnessFactorCalculatorScreenState();
}

class _TightnessFactorCalculatorScreenState
    extends State<TightnessFactorCalculatorScreen> {
  final ctrl = KeypadFieldController(['tex', 'loopLength']);
  double? _tf;

  void _recalc() {
    final tex = ctrl.number('tex');
    final loopMm = ctrl.number('loopLength');

    setState(() {
      if (tex != null && tex > 0 && loopMm != null && loopMm > 0) {
        // Munden's Tightness Factor: K = √Tex ÷ Loop Length (cm)
        final loopCm = loopMm / 10;
        _tf = math.sqrt(tex) / loopCm;
      } else {
        _tf = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'TIGHTNESS FACTOR\nCALCULATOR',
      icon: Icons.compress_rounded,
      iconAsset: 'assets/homeicon/tightness_factor_calculator.webp',
      showIconBackground: false,
      onReset: () => setState(() {
        ctrl.resetAll();
        _recalc();
      }),
      extraHeaderAction: FormulaGuideButton(
        title: 'Tightness Factor (K)',
        sections: const [
          FormulaGuideSection(
            heading: '📌 সংজ্ঞা (Definition)',
            body: 'Tightness Factor (K), যা Munden\'s Tightness Factor '
                'নামেও পরিচিত, দিয়ে বোঝা যায় একটা নিটেড ফেব্রিক কতটা '
                '"টাইট" বা "লুজ" বোনা হয়েছে — যদি একই সুতা দিয়ে ছোট Loop '
                'Length ব্যবহার করা হয়, ফেব্রিক বেশি টাইট (K বেশি) হবে।',
          ),
          FormulaGuideSection(
            heading: '🧮 ফরমুলা',
            body: 'K = √(Tex) ÷ Loop Length (cm)\n\n'
                'এখানে Tex হলো সুতার লিনিয়ার ডেনসিটি (গ্রাম প্রতি ১০০০ '
                'মিটার), আর Loop Length হলো একটা লুপ তৈরিতে ব্যবহৃত সুতার '
                'দৈর্ঘ্য (সেন্টিমিটারে)।',
          ),
          FormulaGuideSection(
            heading: '📝 ধাপে ধাপে হিসাব',
            body: '১. ব্যবহৃত সুতার Tex মান নির্ণয় করুন\n'
                '২. মেশিন সেটিং বা ফেব্রিক টেস্ট থেকে Loop Length (mm) '
                'বের করুন — এই ক্যালকুলেটরে mm-এ দিন, হিসাবে এটা নিজে '
                'থেকেই cm-এ রূপান্তরিত হবে\n'
                '৩. Tex-এর বর্গমূল বের করে Loop Length (cm) দিয়ে ভাগ '
                'করলেই K পাওয়া যাবে',
          ),
          FormulaGuideSection(
            heading: '💡 সাধারণ K রেঞ্জ (Plain Jersey)',
            body: 'সাধারণত Plain Single Jersey ফেব্রিকের জন্য K এর মান '
                '১.২ থেকে ১.৬ এর মধ্যে থাকে বলে টেক্সটাইল রেফারেন্সে '
                'উল্লেখ থাকে।\n\n'
                'নোট: এই রেঞ্জ ফেব্রিক স্ট্রাকচার (Jersey/Rib/Interlock) '
                'ও ব্যবহারের ওপর নির্ভর করে ভিন্ন হতে পারে — এটা একটা '
                'সাধারণ নির্দেশনা মাত্র, প্রতিটা মিলের নিজস্ব স্ট্যান্ডার্ড '
                'অনুসরণ করাই ভালো।',
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
              icon: Icons.tag_rounded,
              label: 'Yarn Count',
              subLabel: 'Tex System',
              value: ctrl.values['tex']!,
              unit: 'Tex',
              placeholder: '0.0',
              iconGradient: AppColors.greenIconGradient,
              accentColor: AppColors.green,
              active: ctrl.activeId == 'tex',
              onTap: () => setState(() => ctrl.setActive('tex')),
            ),
            const SizedBox(height: 4.0),
            InputCard(
              icon: Icons.all_out_rounded,
              label: 'Loop Length',
              subLabel: 'Stitch Length (mm)',
              value: ctrl.values['loopLength']!,
              unit: 'mm',
              placeholder: '0.0',
              iconGradient: AppColors.tealIconGradient,
              accentColor: AppColors.teal,
              active: ctrl.activeId == 'loopLength',
              onTap: () => setState(() => ctrl.setActive('loopLength')),
            ),
            const SizedBox(height: 12),
            ResultBox(
              label: 'TIGHTNESS FACTOR (K)',
              value: _tf?.toStringAsFixed(2) ?? '0.00',
              borderColor:
                  _tf != null ? AppColors.green : AppColors.inputBorder,
              live: _tf != null,
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
