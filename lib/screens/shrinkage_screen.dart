import 'package:flutter/material.dart';
import '../models/keypad_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/calc_scaffold.dart';
import '../widgets/compact_input_card.dart';
import '../widgets/formula_guide_button.dart';
import '../widgets/numeric_keypad.dart';
import '../widgets/result_box.dart';

class ShrinkageScreen extends StatefulWidget {
  const ShrinkageScreen({super.key});

  @override
  State<ShrinkageScreen> createState() => _ShrinkageScreenState();
}

class _ShrinkageScreenState extends State<ShrinkageScreen> {
  final ctrl = KeypadFieldController(['l1', 'w1', 'l2', 'w2']);

  double? _lengthShrink;
  double? _widthShrink;

  void _recalc() {
    final l1 = ctrl.number('l1');
    final w1 = ctrl.number('w1');
    final l2 = ctrl.number('l2');
    final w2 = ctrl.number('w2');

    setState(() {
      _lengthShrink =
          (l1 != null && l2 != null && l1 > 0) ? ((l1 - l2) / l1) * 100 : null;
      _widthShrink =
          (w1 != null && w2 != null && w1 > 0) ? ((w1 - w2) / w1) * 100 : null;
    });
  }

  Widget _sectionTitle(String text, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 4, left: 2),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, size: 11, color: Colors.white),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.darkGreen,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'SHRINKAGE\nMEASUREMENT',
      icon: Icons.local_laundry_service_rounded,
      iconAsset: 'assets/homeicon/Shrinkage_measurement.webp',
      extraHeaderAction: FormulaGuideButton(
        title: 'Shrinkage Measurement',
        sections: const [
          FormulaGuideSection(
            heading: '📌 সংজ্ঞা',
            body: 'ওয়াশ/প্রসেসের আগে ও পরে ফেব্রিকের দৈর্ঘ্য-প্রস্থ '
                'মেপে Length Shrinkage ও Width Shrinkage হিসাব করা হয় — '
                'ফেব্রিক ওয়াশের পর কতটা সংকুচিত হচ্ছে তা যাচাইয়ের '
                'জন্য এটা একটা অত্যাবশ্যকীয় টেস্ট।',
          ),
          FormulaGuideSection(
            heading: '🧮 ফরমুলা',
            body: 'Length Shrink % = ((L1 − L2) ÷ L1) × 100\n'
                'Width Shrink % = ((W1 − W2) ÷ W1) × 100',
          ),
          FormulaGuideSection(
            heading: '📝 ধাপে ধাপে',
            body: '১. ওয়াশের আগে নমুনার দৈর্ঘ্য (L1) ও প্রস্থ (W1) মাপুন\n'
                '২. নির্ধারিত ওয়াশ/প্রসেস সম্পন্ন করুন\n'
                '৩. ওয়াশের পরে একই নমুনার দৈর্ঘ্য (L2) ও প্রস্থ (W2) '
                'মাপুন\n'
                '৪. অ্যাপ স্বয়ংক্রিয়ভাবে দুটোর শতাংশ শ্রিংকেজ দেখাবে',
          ),
          FormulaGuideSection(
            heading: '💡 নোট',
            body: 'ফেব্রিক স্পাইরালিটি/টুইস্ট আলাদা একটা ফিচার — "Twisting '
                'Measurement" ক্যালকুলেটরে সেটা মাপা যাবে।',
          ),
        ],
      ),
      onReset: () => setState(() {
        ctrl.resetAll();
        _recalc();
      }),
      content: Padding(
        padding: const EdgeInsets.only(
          left: 14.0,
          right: 14.0,
          top: 30.0,
          bottom: 18.0,
        ),
        child: Column(
          children: [
            _sectionTitle(
                'Before Wash', Icons.checkroom_rounded, AppColors.teal),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CompactInputCard(
                    icon: Icons.straighten_rounded,
                    label: 'Length',
                    value: ctrl.values['l1']!,
                    unit: 'cm',
                    iconGradient: AppColors.tealIconGradient,
                    accentColor: AppColors.teal,
                    active: ctrl.activeId == 'l1',
                    onTap: () => setState(() => ctrl.setActive('l1')),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CompactInputCard(
                    icon: Icons.swap_horiz_rounded,
                    label: 'Width',
                    value: ctrl.values['w1']!,
                    unit: 'cm',
                    iconGradient: AppColors.tealIconGradient,
                    accentColor: AppColors.teal,
                    active: ctrl.activeId == 'w1',
                    onTap: () => setState(() => ctrl.setActive('w1')),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6.0),
            _sectionTitle(
                'After Wash', Icons.water_drop_rounded, AppColors.purple),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CompactInputCard(
                    icon: Icons.straighten_rounded,
                    label: 'Length',
                    value: ctrl.values['l2']!,
                    unit: 'cm',
                    iconGradient: AppColors.purpleIconGradient,
                    accentColor: AppColors.purple,
                    active: ctrl.activeId == 'l2',
                    onTap: () => setState(() => ctrl.setActive('l2')),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CompactInputCard(
                    icon: Icons.swap_horiz_rounded,
                    label: 'Width',
                    value: ctrl.values['w2']!,
                    unit: 'cm',
                    iconGradient: AppColors.purpleIconGradient,
                    accentColor: AppColors.purple,
                    active: ctrl.activeId == 'w2',
                    onTap: () => setState(() => ctrl.setActive('w2')),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14.0),
            Row(
              children: [
                Expanded(
                  child: ResultBox(
                    label: 'LENGTH SHRINK %',
                    value: _lengthShrink != null
                        ? '${_lengthShrink!.toStringAsFixed(2)}%'
                        : '0.00',
                    borderColor: _lengthShrink != null
                        ? AppColors.teal
                        : AppColors.inputBorder,
                    live: _lengthShrink != null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ResultBox(
                    label: 'WIDTH SHRINK %',
                    value: _widthShrink != null
                        ? '${_widthShrink!.toStringAsFixed(2)}%'
                        : '0.00',
                    borderColor: _widthShrink != null
                        ? AppColors.purple
                        : AppColors.inputBorder,
                    live: _widthShrink != null,
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
