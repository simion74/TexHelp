import 'package:flutter/material.dart';
import '../models/keypad_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/calc_scaffold.dart';
import '../widgets/formula_guide_button.dart';
import '../widgets/input_card.dart';
import '../widgets/numeric_keypad.dart';
import '../widgets/result_box.dart';

class MarkerConsumptionCalculatorScreen extends StatefulWidget {
  const MarkerConsumptionCalculatorScreen({super.key});

  @override
  State<MarkerConsumptionCalculatorScreen> createState() =>
      _MarkerConsumptionCalculatorScreenState();
}

class _MarkerConsumptionCalculatorScreenState
    extends State<MarkerConsumptionCalculatorScreen> {
  final ctrl = KeypadFieldController(
      ['markerLength', 'markerWidth', 'gsm', 'garmentsInMarker']);
  double? _consumptionKg;
  double? _consumptionG;

  void _recalc() {
    final length = ctrl.number('markerLength');
    final width = ctrl.number('markerWidth');
    final gsm = ctrl.number('gsm');
    final garments = ctrl.number('garmentsInMarker');

    setState(() {
      if (length != null &&
          length > 0 &&
          width != null &&
          width > 0 &&
          gsm != null &&
          gsm > 0 &&
          garments != null &&
          garments > 0) {
        final markerArea = length * width; // m²
        final totalWeightG = markerArea * gsm; // মোট ফেব্রিক ওজন (g)
        _consumptionG = totalWeightG / garments;
        _consumptionKg = _consumptionG! / 1000;
      } else {
        _consumptionKg = null;
        _consumptionG = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'FABRIC CONSUMPTION\n(PER PIECE - MARKER)',
      // 🖼️ TODO: CalcScaffold-এ image icon সাপোর্ট যোগ হলে এই লাইনে
      // icon: Icons.content_cut_rounded এর বদলে নিচের path বসাতে হবে:
      // imagePath: 'assets/homeicon/marker_consumption.webp'
      icon: Icons.content_cut_rounded,
      onReset: () => setState(() {
        ctrl.resetAll();
        _recalc();
      }),
      extraHeaderAction: FormulaGuideButton(
        title: 'Fabric Consumption (Per Piece - Marker)',
        sections: const [
          FormulaGuideSection(
            heading: '📌 সংজ্ঞা (Definition)',
            body: 'একটা মার্কার লে-আউট থেকে একসাথে কয়েকটা গার্মেন্ট কাটা '
                'হয়। মার্কারের দৈর্ঘ্য, প্রস্থ ও ফেব্রিকের GSM জানা '
                'থাকলে, প্রতিটা গার্মেন্ট পিসে গড়ে কতটুকু ফেব্রিক লাগছে '
                'তা হিসাব করা যায় — এটা কস্টিং ও ফেব্রিক অর্ডার প্ল্যান '
                'করতে অপরিহার্য।',
          ),
          FormulaGuideSection(
            heading: '🧮 ফরমুলা',
            body: 'Marker Area (m²) = Marker Length × Marker Width\n\n'
                'Total Fabric Weight (g) = Marker Area × GSM\n\n'
                'Consumption per Piece (g) = Total Fabric Weight ÷ '
                'No. of Garments in Marker',
          ),
          FormulaGuideSection(
            heading: '📝 ধাপে ধাপে হিসাব',
            body: '১. মার্কারের দৈর্ঘ্য (মিটারে) লিখুন\n'
                '২. মার্কারের প্রস্থ (ফেব্রিক রোলের প্রস্থ, মিটারে) '
                'লিখুন\n'
                '৩. ফেব্রিকের GSM লিখুন\n'
                '৪. এই মার্কারে মোট কতগুলো গার্মেন্ট প্যাটার্ন আছে '
                'লিখুন\n'
                '৫. অ্যাপ স্বয়ংক্রিয়ভাবে প্রতি পিসের ফেব্রিক '
                'কনজাম্পশন (গ্রাম ও কেজিতে) দেখাবে',
          ),
          FormulaGuideSection(
            heading: '💡 উদাহরণ',
            body: 'ধরুন, Marker Length = 10 m, Width = 1.5 m, GSM = 180, '
                'গার্মেন্ট সংখ্যা = 20\n'
                'Marker Area = 10 × 1.5 = 15 m²\n'
                'Total Weight = 15 × 180 = 2700 g\n'
                'Consumption/pc = 2700 ÷ 20 = 135 g (0.135 kg)\n\n'
                'নোট: এটা মার্কারের মোট ফেব্রিক এরিয়া দিয়ে হিসাব করা '
                'গড় মান — এতে কাটিং ওয়েস্ট এমনিতেই যোগ হয়ে আছে, আলাদা '
                'করে ওয়েস্ট % যোগ করার দরকার নেই।',
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
              dense: true,
              active: ctrl.activeId == 'markerLength',
              onTap: () => setState(() => ctrl.setActive('markerLength')),
            ),
            const SizedBox(height: 3.0),
            InputCard(
              icon: Icons.swap_horiz_rounded,
              label: 'Marker Width',
              subLabel: 'ফেব্রিক রোলের প্রস্থ',
              value: ctrl.values['markerWidth']!,
              unit: 'm',
              placeholder: '0.0',
              iconGradient: AppColors.tealIconGradient,
              accentColor: AppColors.teal,
              dense: true,
              active: ctrl.activeId == 'markerWidth',
              onTap: () => setState(() => ctrl.setActive('markerWidth')),
            ),
            const SizedBox(height: 3.0),
            InputCard(
              icon: Icons.texture_rounded,
              label: 'Fabric GSM',
              subLabel: 'গ্রাম প্রতি বর্গ মিটার',
              value: ctrl.values['gsm']!,
              unit: 'g/m²',
              placeholder: '0.0',
              iconGradient: AppColors.purpleIconGradient,
              accentColor: AppColors.purple,
              dense: true,
              active: ctrl.activeId == 'gsm',
              onTap: () => setState(() => ctrl.setActive('gsm')),
            ),
            const SizedBox(height: 3.0),
            InputCard(
              icon: Icons.checkroom_rounded,
              label: 'Garments in Marker',
              subLabel: 'মোট প্যাটার্ন সংখ্যা',
              value: ctrl.values['garmentsInMarker']!,
              unit: 'pcs',
              placeholder: '0',
              iconGradient: AppColors.darkTealIconGradient,
              accentColor: AppColors.darkTeal,
              dense: true,
              active: ctrl.activeId == 'garmentsInMarker',
              onTap: () => setState(() => ctrl.setActive('garmentsInMarker')),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ResultBox(
                    label: 'PER PIECE (g)',
                    value: _consumptionG != null
                        ? '${_consumptionG!.toStringAsFixed(1)} g'
                        : '0 g',
                    borderColor: _consumptionG != null
                        ? AppColors.teal
                        : AppColors.inputBorder,
                    textColor: AppColors.teal,
                    dense: true,
                    live: _consumptionG != null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ResultBox(
                    label: 'PER PIECE (kg)',
                    value: _consumptionKg != null
                        ? '${_consumptionKg!.toStringAsFixed(3)} kg'
                        : '0 kg',
                    borderColor: _consumptionKg != null
                        ? AppColors.green
                        : AppColors.inputBorder,
                    dense: true,
                    live: _consumptionKg != null,
                  ),
                ),
              ],
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
