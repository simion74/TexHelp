import 'package:flutter/material.dart';
import '../models/keypad_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/calc_scaffold.dart';
import '../widgets/formula_guide_button.dart';
import '../widgets/input_card.dart';
import '../widgets/numeric_keypad.dart';
import '../widgets/result_box.dart';

class MarkerEfficiencyCalculatorScreen extends StatefulWidget {
  const MarkerEfficiencyCalculatorScreen({super.key});

  @override
  State<MarkerEfficiencyCalculatorScreen> createState() =>
      _MarkerEfficiencyCalculatorScreenState();
}

class _MarkerEfficiencyCalculatorScreenState
    extends State<MarkerEfficiencyCalculatorScreen> {
  final ctrl =
      KeypadFieldController(['markerLength', 'markerWidth', 'patternArea']);
  double? _efficiency;

  void _recalc() {
    final length = ctrl.number('markerLength');
    final width = ctrl.number('markerWidth');
    final patternArea = ctrl.number('patternArea');

    setState(() {
      if (length != null &&
          length > 0 &&
          width != null &&
          width > 0 &&
          patternArea != null &&
          patternArea > 0) {
        final markerArea = length * width;
        // Marker Efficiency % = (Total Pattern Area ÷ Total Marker Area) × 100
        _efficiency = (patternArea / markerArea) * 100;
      } else {
        _efficiency = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'MARKER EFFICIENCY %\nCALCULATOR',
      // 🖼️ TODO: CalcScaffold-এ image icon সাপোর্ট যোগ হলে এই লাইনে
      // icon: Icons.grid_view_rounded এর বদলে নিচের path বসাতে হবে:
      // imagePath: 'assets/homeicon/marker_efficiency.webp'
      icon: Icons.grid_view_rounded,
      onReset: () => setState(() {
        ctrl.resetAll();
        _recalc();
      }),
      extraHeaderAction: FormulaGuideButton(
        title: 'Marker Efficiency % Calculator',
        sections: const [
          FormulaGuideSection(
            heading: '📌 সংজ্ঞা (Definition)',
            body: 'কাটিং-এর আগে মার্কার (প্যাটার্ন পিসগুলো ফেব্রিকের '
                'ওপর কীভাবে সাজানো হবে তার লে-আউট) তৈরি করা হয়। Marker '
                'Efficiency % দিয়ে বোঝা যায় মোট ফেব্রিক এরিয়ার কত '
                'শতাংশ প্রকৃতপক্ষে গার্মেন্ট প্যাটার্ন দিয়ে ব্যবহার '
                'হচ্ছে — যত বেশি Efficiency, ফেব্রিক ওয়েস্ট তত কম।',
          ),
          FormulaGuideSection(
            heading: '🧮 ফরমুলা',
            body: 'Marker Area = Marker Length × Marker Width\n\n'
                'Marker Efficiency % = (Total Pattern Area ÷ Marker Area) '
                '× 100',
          ),
          FormulaGuideSection(
            heading: '📝 ধাপে ধাপে হিসাব',
            body: '১. মার্কারের মোট দৈর্ঘ্য (মিটারে) লিখুন\n'
                '২. মার্কারের প্রস্থ (ফেব্রিক রোলের প্রস্থ, মিটারে) '
                'লিখুন\n'
                '৩. মার্কারে থাকা সব প্যাটার্ন পিসের মোট এরিয়া (বর্গ '
                'মিটারে) লিখুন — এটা সাধারণত CAD মার্কার-মেকিং '
                'সফটওয়্যার থেকে পাওয়া যায়\n'
                '৪. অ্যাপ স্বয়ংক্রিয়ভাবে Marker Efficiency % দেখাবে',
          ),
          FormulaGuideSection(
            heading: '💡 উদাহরণ',
            body: 'ধরুন, Marker Length = 10 m, Width = 1.5 m, Pattern '
                'Area = 12 m²\n'
                'Marker Area = 10 × 1.5 = 15 m²\n'
                'Efficiency % = (12 ÷ 15) × 100 = 80%\n\n'
                'অর্থাৎ ২০% ফেব্রিক ওয়েস্ট/কাটিং লস হচ্ছে।',
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
              label: 'Marker Length',
              subLabel: 'মার্কারের মোট দৈর্ঘ্য',
              value: ctrl.values['markerLength']!,
              unit: 'm',
              placeholder: '0.0',
              iconGradient: AppColors.greenIconGradient,
              accentColor: AppColors.green,
              active: ctrl.activeId == 'markerLength',
              onTap: () => setState(() => ctrl.setActive('markerLength')),
            ),
            const SizedBox(height: 4.0),
            InputCard(
              icon: Icons.swap_horiz_rounded,
              label: 'Marker Width',
              subLabel: 'ফেব্রিক রোলের প্রস্থ',
              value: ctrl.values['markerWidth']!,
              unit: 'm',
              placeholder: '0.0',
              iconGradient: AppColors.tealIconGradient,
              accentColor: AppColors.teal,
              active: ctrl.activeId == 'markerWidth',
              onTap: () => setState(() => ctrl.setActive('markerWidth')),
            ),
            const SizedBox(height: 4.0),
            InputCard(
              icon: Icons.crop_free_rounded,
              label: 'Total Pattern Area',
              subLabel: 'সব প্যাটার্ন পিসের এরিয়া',
              value: ctrl.values['patternArea']!,
              unit: 'm²',
              placeholder: '0.0',
              iconGradient: AppColors.purpleIconGradient,
              accentColor: AppColors.purple,
              active: ctrl.activeId == 'patternArea',
              onTap: () => setState(() => ctrl.setActive('patternArea')),
            ),
            const SizedBox(height: 10),
            ResultBox(
              label: 'MARKER EFFICIENCY %',
              value: _efficiency != null
                  ? '${_efficiency!.toStringAsFixed(1)}%'
                  : '0%',
              borderColor: _efficiency != null
                  ? AppColors.green
                  : AppColors.inputBorder,
              live: _efficiency != null,
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
