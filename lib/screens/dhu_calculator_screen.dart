import 'package:flutter/material.dart';
import '../models/keypad_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/calc_scaffold.dart';
import '../widgets/formula_guide_button.dart';
import '../widgets/input_card.dart';
import '../widgets/numeric_keypad.dart';
import '../widgets/result_box.dart';

class DhuCalculatorScreen extends StatefulWidget {
  const DhuCalculatorScreen({super.key});

  @override
  State<DhuCalculatorScreen> createState() => _DhuCalculatorScreenState();
}

class _DhuCalculatorScreenState extends State<DhuCalculatorScreen> {
  final ctrl = KeypadFieldController(['defects', 'pieces']);
  double? _dhu;

  void _recalc() {
    final defects = ctrl.number('defects');
    final pieces = ctrl.number('pieces');

    setState(() {
      if (defects != null && defects >= 0 && pieces != null && pieces > 0) {
        // DHU = (মোট Defect ÷ মোট চেক করা পিস) × 100
        _dhu = (defects / pieces) * 100;
      } else {
        _dhu = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'DHU\nCALCULATOR',
      icon: Icons.fact_check_rounded,
      iconAsset: 'assets/homeicon/dhu_calculator.webp',
      showIconBackground: false,
      onReset: () => setState(() {
        ctrl.resetAll();
        _recalc();
      }),
      extraHeaderAction: FormulaGuideButton(
        title: 'DHU (Defects per Hundred Units)',
        sections: const [
          FormulaGuideSection(
            heading: '📌 সংজ্ঞা (Definition)',
            body: 'DHU (Defects per Hundred Units/Garments) হলো গার্মেন্টস '
                'কোয়ালিটি কন্ট্রোলের সবচেয়ে গুরুত্বপূর্ণ ও বহুল ব্যবহৃত '
                'সূচক। এটা প্রতি ১০০টা চেক করা পিসে গড়ে কতগুলো ডিফেক্ট '
                'পাওয়া গেছে সেটা দেখায় — যত কম DHU, ততই ভালো কোয়ালিটি।',
          ),
          FormulaGuideSection(
            heading: '🧮 ফরমুলা',
            body: 'DHU = (মোট পাওয়া Defect সংখ্যা ÷ মোট চেক করা পিস) × 100\n\n'
                'নোট: একটা পিসে একাধিক ডিফেক্ট থাকলে প্রতিটাই আলাদাভাবে '
                'গণনা করতে হয় (Defect count ≠ Defective pieces count)।',
          ),
          FormulaGuideSection(
            heading: '📝 ধাপে ধাপে হিসাব',
            body: '১. QC ইন্সপেকশনের সময় পাওয়া মোট ডিফেক্ট সংখ্যা যোগ '
                'করুন (একটা পিসে একাধিক ডিফেক্ট থাকলে সবগুলো আলাদাভাবে '
                'গুণুন)\n'
                '২. মোট চেক করা পিসের সংখ্যা লিখুন\n'
                '৩. অ্যাপ স্বয়ংক্রিয়ভাবে DHU বের করে দেবে',
          ),
          FormulaGuideSection(
            heading: '💡 উদাহরণ',
            body: 'ধরুন, ১০০ পিস চেক করে মোট ১২টা ডিফেক্ট পাওয়া গেছে '
                '(কোনো পিসে ২টা, কোনো পিসে ১টা)\n'
                'DHU = (12 ÷ 100) × 100 = 12\n\n'
                'নোট: গ্রহণযোগ্য DHU লেভেল বায়ার/মিলের নিজস্ব '
                'স্ট্যান্ডার্ড অনুযায়ী ভিন্ন হয়, তাই এখানে কোনো একক '
                '"পাস/ফেল" মাত্রা নির্ধারণ করা হয়নি।',
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
              icon: Icons.report_problem_rounded,
              label: 'Total Defects Found',
              subLabel: 'মোট পাওয়া ডিফেক্ট সংখ্যা',
              value: ctrl.values['defects']!,
              unit: 'pcs',
              placeholder: '0',
              iconGradient: AppColors.purpleIconGradient,
              accentColor: AppColors.purple,
              active: ctrl.activeId == 'defects',
              onTap: () => setState(() => ctrl.setActive('defects')),
            ),
            const SizedBox(height: 4.0),
            InputCard(
              icon: Icons.checklist_rounded,
              label: 'Total Pieces Checked',
              subLabel: 'মোট চেক করা পিস',
              value: ctrl.values['pieces']!,
              unit: 'pcs',
              placeholder: '0',
              iconGradient: AppColors.tealIconGradient,
              accentColor: AppColors.teal,
              active: ctrl.activeId == 'pieces',
              onTap: () => setState(() => ctrl.setActive('pieces')),
            ),
            const SizedBox(height: 12),
            ResultBox(
              label: 'DHU (Defects per Hundred Units)',
              value: _dhu?.toStringAsFixed(2) ?? '0.00',
              borderColor:
                  _dhu != null ? AppColors.green : AppColors.inputBorder,
              live: _dhu != null,
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
