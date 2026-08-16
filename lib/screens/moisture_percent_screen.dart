import 'package:flutter/material.dart';
import '../models/keypad_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/calc_scaffold.dart';
import '../widgets/formula_guide_button.dart';
import '../widgets/input_card.dart';
import '../widgets/numeric_keypad.dart';
import '../widgets/result_box.dart';

/// Moisture % Calculator (Lab)
/// -----------------------------
/// Wet Weight (শুকানোর আগে) ও Dry Weight (ওভেন-ড্রাই করার পরে) দিয়ে
/// Moisture Content % এবং Moisture Regain % — দুইটাই একসাথে বের করে
/// দেয় (দুইটার ফরমুলা আলাদা — ডিনোমিনেটর ভিন্ন)। ঐচ্ছিক Standard
/// Regain % দিলে Conditioned (Invoice) Weight-ও বের হয়ে যায় — সুতা/
/// ফাইবার ট্রেডিং-এ ওজন সংশোধনের জন্য ব্যবহার হয়।
class MoisturePercentScreen extends StatefulWidget {
  const MoisturePercentScreen({super.key});

  @override
  State<MoisturePercentScreen> createState() => _MoisturePercentScreenState();
}

class _MoisturePercentScreenState extends State<MoisturePercentScreen> {
  final ctrl = KeypadFieldController(['wet', 'dry', 'stdRegain']);

  double? _mc;
  double? _mr;
  double? _conditionedWeight;

  void _recalc() {
    final wet = ctrl.number('wet');
    final dry = ctrl.number('dry');
    final stdRegain = ctrl.number('stdRegain');

    if (wet == null || dry == null || dry <= 0 || wet < dry) {
      setState(() {
        _mc = null;
        _mr = null;
        _conditionedWeight = null;
      });
      return;
    }

    final moistureLoss = wet - dry;
    final mc = (moistureLoss / wet) * 100;
    final mr = (moistureLoss / dry) * 100;

    double? conditionedWeight;
    if (stdRegain != null && stdRegain >= 0) {
      conditionedWeight = dry * (1 + stdRegain / 100);
    }

    setState(() {
      _mc = mc;
      _mr = mr;
      _conditionedWeight = conditionedWeight;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'MOISTURE %\nCALCULATOR',
      icon: Icons.opacity_rounded,
      iconAsset: 'assets/homeicon/moisture%.webp',
      extraHeaderAction: FormulaGuideButton(
        title: 'Moisture % Calculator',
        sections: [
          FormulaGuideSection(
            heading: 'সংজ্ঞা (Definition)',
            body: 'Moisture Content (MC%) এবং Moisture Regain (MR%) — '
                'দুইটাই ফাইবার/ইয়ার্ন/ফেব্রিকে থাকা আর্দ্রতার পরিমাণ '
                'বোঝায়, কিন্তু হিসাবের ভিত্তি (ডিনোমিনেটর) আলাদা:\n\n'
                '• MC% — মোট (ভেজা) ওজনের সাপেক্ষে আর্দ্রতার শতাংশ।\n'
                '• MR% — শুকনো (বোন-ড্রাই) ওজনের সাপেক্ষে আর্দ্রতার '
                'শতাংশ। টেক্সটাইল ইন্ডাস্ট্রিতে সাধারণত MR% বেশি '
                'ব্যবহৃত হয়।',
          ),
          FormulaGuideSection(
            heading: 'ফরমুলা (Formula)',
            body: 'Moisture Loss (g) = Wet Weight − Dry Weight\n\n'
                'Moisture Content % (MC%) = (Moisture Loss ÷ Wet '
                'Weight) × 100\n\n'
                'Moisture Regain % (MR%) = (Moisture Loss ÷ Dry '
                'Weight) × 100\n\n'
                'Conditioned Weight (g) = Dry Weight × (1 + Standard '
                'Regain % ÷ 100)',
          ),
          FormulaGuideSection(
            heading: 'ম্যানুয়ালি কীভাবে বের করবেন?',
            body: '১) নমুনা প্রথমে স্বাভাবিক অবস্থায় ওজন করুন — এটাই '
                'Wet Weight।\n'
                '২) নমুনা ওভেনে সম্পূর্ণ শুকিয়ে (বোন-ড্রাই) আবার ওজন '
                'করুন — এটাই Dry Weight।\n'
                '৩) দুইটার পার্থক্য বের করে Wet Weight দিয়ে ভাগ করলে '
                'MC%, আর Dry Weight দিয়ে ভাগ করলে MR% পাওয়া যাবে '
                '(দুই ক্ষেত্রেই ১০০ দিয়ে গুণ করতে হবে)।',
          ),
          FormulaGuideSection(
            heading: 'উদাহরণ (Example)',
            body: 'ধরুন Wet Weight = 108.5 g, Dry Weight = 100 g।\n\n'
                'Moisture Loss = 108.5 − 100 = 8.5 g\n'
                'MC% = (8.5 ÷ 108.5) × 100 = 7.83%\n'
                'MR% = (8.5 ÷ 100) × 100 = 8.5%\n\n'
                'লক্ষ্য করুন — একই ডেটায় MC% ও MR% ভিন্ন হয়, কারণ '
                'ডিনোমিনেটর আলাদা।',
          ),
          FormulaGuideSection(
            heading: 'স্ট্যান্ডার্ড রিগেইন রেফারেন্স (%)',
            body: 'বিভিন্ন ফাইবারের প্রচলিত স্ট্যান্ডার্ড রিগেইন মান '
                '(কমার্শিয়াল ইনভয়েস ওজন সংশোধনে ব্যবহৃত):\n\n'
                'Cotton — 8.5%\n'
                'Viscose/Rayon — 13.0%\n'
                'Wool — 16.0–18.25%\n'
                'Silk — 11.0%\n'
                'Nylon (Polyamide) — 4.0–4.5%\n'
                'Polyester — 0.4%\n'
                'Acrylic — 1.5%\n'
                'Jute — 13.75%\n\n'
                '"Standard Regain %" ফিল্ডে এই মান বসালে Conditioned '
                'Weight বের হয়ে যাবে।',
          ),
        ],
      ),
      onReset: () => setState(() {
        ctrl.resetAll();
        _mc = null;
        _mr = null;
        _conditionedWeight = null;
      }),
      content: Padding(
        padding: const EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 28.0,
          bottom: 16.0,
        ),
        child: Column(
          children: [
            InputCard(
              icon: Icons.water_drop_rounded,
              label: 'Wet Weight',
              subLabel: 'Weight Before Drying',
              value: ctrl.values['wet']!,
              unit: 'g',
              placeholder: '0.0',
              iconGradient: AppColors.tealIconGradient,
              accentColor: AppColors.teal,
              active: ctrl.activeId == 'wet',
              onTap: () => setState(() => ctrl.setActive('wet')),
            ),
            const SizedBox(height: 8.0),
            InputCard(
              icon: Icons.wb_sunny_rounded,
              label: 'Dry Weight',
              subLabel: 'Oven-Dry (Bone-Dry) Weight',
              value: ctrl.values['dry']!,
              unit: 'g',
              placeholder: '0.0',
              iconGradient: AppColors.greenIconGradient,
              accentColor: AppColors.green,
              active: ctrl.activeId == 'dry',
              onTap: () => setState(() => ctrl.setActive('dry')),
            ),
            const SizedBox(height: 8.0),
            InputCard(
              icon: Icons.rule_rounded,
              label: 'Standard Regain %',
              subLabel: 'Optional — for Conditioned Weight',
              value: ctrl.values['stdRegain']!,
              unit: '%',
              placeholder: 'e.g. 8.5',
              iconGradient: AppColors.purpleIconGradient,
              accentColor: AppColors.purple,
              active: ctrl.activeId == 'stdRegain',
              onTap: () => setState(() => ctrl.setActive('stdRegain')),
            ),
            const SizedBox(height: 12.0),
            Row(
              children: [
                Expanded(
                  child: ResultBox(
                    label: 'Moisture Content (MC%)',
                    value: _mc != null
                        ? '${_mc!.toStringAsFixed(2)} %'
                        : '0.00 %',
                    borderColor:
                        _mc != null ? AppColors.green : AppColors.inputBorder,
                    live: _mc != null,
                    dense: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ResultBox(
                    label: 'Moisture Regain (MR%)',
                    value: _mr != null
                        ? '${_mr!.toStringAsFixed(2)} %'
                        : '0.00 %',
                    borderColor:
                        _mr != null ? AppColors.green : AppColors.inputBorder,
                    live: _mr != null,
                    dense: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ResultBox(
              label: 'CONDITIONED (INVOICE) WEIGHT',
              value: _conditionedWeight != null
                  ? '${_conditionedWeight!.toStringAsFixed(2)} g'
                  : '— (enter Standard Regain %)',
              borderColor: _conditionedWeight != null
                  ? AppColors.green
                  : AppColors.inputBorder,
              live: _conditionedWeight != null,
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
