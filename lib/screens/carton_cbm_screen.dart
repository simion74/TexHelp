import 'package:flutter/material.dart';
import '../models/keypad_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/calc_scaffold.dart';
import '../widgets/formula_guide_button.dart';
import '../widgets/input_card.dart';
import '../widgets/numeric_keypad.dart';
import '../widgets/result_box.dart';

enum _DimUnit { cm, inch }

/// Carton / CBM Calculator (Packing Section)
/// --------------------------------------------
/// Carton-এর Length, Width, Height (cm/inch যেকোনো এককে) এবং Number of
/// Cartons দিলে প্রতি কার্টনের CBM ও মোট CBM বের করে দেয় — যা শিপমেন্ট
/// প্ল্যানিং ও কনটেইনার লোডিং হিসাবে কাজে লাগে। অ্যাপের বাকি সব
/// ক্যালকুলেটরের মতোই একই CalcScaffold, একই NumericKeypad এবং হেডারে
/// একই FormulaGuideButton ব্যবহার করা হয়েছে।
class CartonCbmScreen extends StatefulWidget {
  const CartonCbmScreen({super.key});

  @override
  State<CartonCbmScreen> createState() => _CartonCbmScreenState();
}

class _CartonCbmScreenState extends State<CartonCbmScreen> {
  final ctrl =
      KeypadFieldController(['length', 'width', 'height', 'cartons']);

  _DimUnit _unit = _DimUnit.cm;

  double? _cbmPerCarton;
  double? _totalCbm;

  void _recalc() {
    final lengthVal = ctrl.number('length');
    final widthVal = ctrl.number('width');
    final heightVal = ctrl.number('height');
    final cartonsVal = ctrl.number('cartons') ?? 1.0;

    if (lengthVal == null ||
        lengthVal <= 0 ||
        widthVal == null ||
        widthVal <= 0 ||
        heightVal == null ||
        heightVal <= 0 ||
        cartonsVal <= 0) {
      setState(() {
        _cbmPerCarton = null;
        _totalCbm = null;
      });
      return;
    }

    // inch হলে cm-এ কনভার্ট করা হচ্ছে (1 inch = 2.54 cm)
    final factor = _unit == _DimUnit.inch ? 2.54 : 1.0;
    final lengthCm = lengthVal * factor;
    final widthCm = widthVal * factor;
    final heightCm = heightVal * factor;

    // CBM = (L × W × H in cm) ÷ 1,000,000
    final cbmPerCarton = (lengthCm * widthCm * heightCm) / 1000000;

    setState(() {
      _cbmPerCarton = cbmPerCarton;
      _totalCbm = cbmPerCarton * cartonsVal;
    });
  }

  String get _dimUnitLabel {
    switch (_unit) {
      case _DimUnit.cm:
        return 'cm';
      case _DimUnit.inch:
        return 'in';
    }
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'CARTON / CBM\nCALCULATOR',
      icon: Icons.inventory_2_rounded,
      iconAsset: 'assets/homeicon/carton_cbm.webp',
      extraHeaderAction: FormulaGuideButton(
        title: 'Carton / CBM Calculator',
        sections: [
          FormulaGuideSection(
            heading: 'সংজ্ঞা (Definition)',
            body: 'CBM (Cubic Meter) হলো একটি কার্টনের আয়তন ঘনমিটার '
                'এককে। শিপমেন্ট বুকিং, ফ্রেইট কস্ট হিসাব এবং কনটেইনার '
                'লোডিং প্ল্যানের জন্য CBM জানা অত্যন্ত জরুরি — কারণ '
                'শিপিং লাইনগুলো ওজন অথবা CBM, যেটা বেশি হয় তার উপর '
                'ভাড়া নির্ধারণ করে।',
          ),
          FormulaGuideSection(
            heading: 'ফরমুলা (Formula)',
            body: 'CBM per Carton (m³) = (Length × Width × Height in cm) '
                '÷ 1,000,000\n\n'
                'Total CBM = CBM per Carton × Number of Cartons\n\n'
                'Inch থেকে cm কনভার্সন: cm = inch × 2.54',
          ),
          FormulaGuideSection(
            heading: 'ম্যানুয়ালি কীভাবে বের করবেন?',
            body: '১) কার্টনের Length, Width, Height মেপে নিন (cm হলে '
                'সরাসরি, inch হলে ২.৫৪ দিয়ে গুণ করে cm-এ আনুন)।\n'
                '২) তিনটা মাপ একসাথে গুণ করুন — ফলাফল আসবে ঘন সেন্টিমিটারে '
                '(cm³)।\n'
                '৩) সেই সংখ্যাকে ১০,০০,০০০ দিয়ে ভাগ করলে প্রতি কার্টনের '
                'CBM পাওয়া যাবে।\n'
                '৪) প্রতি কার্টনের CBM-কে মোট কার্টন সংখ্যা দিয়ে গুণ '
                'করলে Total CBM পাওয়া যাবে।',
          ),
          FormulaGuideSection(
            heading: 'উদাহরণ (Example)',
            body: 'ধরুন কার্টনের মাপ 60 × 40 × 35 cm এবং মোট কার্টন = 100।\n\n'
                'CBM per Carton = (60 × 40 × 35) ÷ 1,000,000 = 0.084 m³\n'
                'Total CBM = 0.084 × 100 = 8.4 m³\n\n'
                'অ্যাপে শুধু Length 60, Width 40, Height 35 এবং Cartons '
                '100 লিখলেই এই ফলাফল অটো বের হয়ে যাবে।',
          ),
          FormulaGuideSection(
            heading: 'কনটেইনার ক্যাপাসিটি (রেফারেন্স)',
            body: 'সাধারণত ব্যবহৃত কনটেইনারের আনুমানিক CBM ক্যাপাসিটি:\n\n'
                '• 20ft Container ≈ 28 CBM\n'
                '• 40ft Container ≈ 58 CBM\n'
                '• 40ft HQ Container ≈ 68 CBM\n\n'
                'Total CBM কে এই ক্যাপাসিটি দিয়ে ভাগ করে আন্দাজ করা যায় '
                'কোন কনটেইনারে শিপমেন্ট আঁটবে (প্র্যাকটিক্যালি স্ট্যাকিং '
                'লসের জন্য ৮০–৮৫% ব্যবহারযোগ্য ধরা ভালো)।',
          ),
        ],
      ),
      onReset: () => setState(() {
        ctrl.resetAll();
        _unit = _DimUnit.cm;
        _cbmPerCarton = null;
        _totalCbm = null;
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
            _SegmentedToggle<_DimUnit>(
              value: _unit,
              options: const {
                _DimUnit.cm: 'CM',
                _DimUnit.inch: 'Inch',
              },
              onChanged: (v) => setState(() {
                _unit = v;
                _recalc();
              }),
            ),
            const SizedBox(height: 8.0),
            InputCard(
              icon: Icons.straighten_rounded,
              label: 'Length',
              subLabel: 'Carton Length',
              value: ctrl.values['length']!,
              unit: _dimUnitLabel,
              placeholder: '0.0',
              iconGradient: AppColors.purpleIconGradient,
              accentColor: AppColors.purple,
              active: ctrl.activeId == 'length',
              onTap: () => setState(() => ctrl.setActive('length')),
            ),
            const SizedBox(height: 8.0),
            InputCard(
              icon: Icons.swap_horiz_rounded,
              label: 'Width',
              subLabel: 'Carton Width',
              value: ctrl.values['width']!,
              unit: _dimUnitLabel,
              placeholder: '0.0',
              iconGradient: AppColors.tealIconGradient,
              accentColor: AppColors.teal,
              active: ctrl.activeId == 'width',
              onTap: () => setState(() => ctrl.setActive('width')),
            ),
            const SizedBox(height: 8.0),
            InputCard(
              icon: Icons.height_rounded,
              label: 'Height',
              subLabel: 'Carton Height',
              value: ctrl.values['height']!,
              unit: _dimUnitLabel,
              placeholder: '0.0',
              iconGradient: AppColors.greenIconGradient,
              accentColor: AppColors.green,
              active: ctrl.activeId == 'height',
              onTap: () => setState(() => ctrl.setActive('height')),
            ),
            const SizedBox(height: 8.0),
            InputCard(
              icon: Icons.filter_none_rounded,
              label: 'Number of Cartons',
              subLabel: 'Optional — default 1',
              value: ctrl.values['cartons']!,
              unit: 'pcs',
              placeholder: '1',
              iconGradient: AppColors.purpleIconGradient,
              accentColor: AppColors.purple,
              active: ctrl.activeId == 'cartons',
              onTap: () => setState(() => ctrl.setActive('cartons')),
            ),
            const SizedBox(height: 12.0),
            Row(
              children: [
                Expanded(
                  child: ResultBox(
                    label: 'CBM / Carton',
                    value: _cbmPerCarton != null
                        ? '${_cbmPerCarton!.toStringAsFixed(4)} m³'
                        : '0.0000 m³',
                    borderColor: _cbmPerCarton != null
                        ? AppColors.green
                        : AppColors.inputBorder,
                    live: _cbmPerCarton != null,
                    dense: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ResultBox(
                    label: 'Total CBM',
                    value: _totalCbm != null
                        ? '${_totalCbm!.toStringAsFixed(3)} m³'
                        : '0.000 m³',
                    borderColor: _totalCbm != null
                        ? AppColors.green
                        : AppColors.inputBorder,
                    live: _totalCbm != null,
                    dense: true,
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

/// ২-অপশনের সেগমেন্টেড টগল (Dimension Unit বেছে নেওয়ার জন্য) —
/// yarn_weight_screen.dart-এর _SegmentedToggle এর সাথে হুবহু একই।
class _SegmentedToggle<T> extends StatelessWidget {
  final T value;
  final Map<T, String> options;
  final ValueChanged<T> onChanged;

  const _SegmentedToggle({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.inputBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Row(
        children: options.entries.map((entry) {
          final selected = entry.key == value;
          return Expanded(
            child: Material(
              color: selected ? AppColors.green : Colors.transparent,
              borderRadius: BorderRadius.circular(9),
              child: InkWell(
                borderRadius: BorderRadius.circular(9),
                onTap: () => onChanged(entry.key),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    entry.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: selected ? Colors.white : AppColors.darkGreen,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
