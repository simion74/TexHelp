import 'package:flutter/material.dart';
import '../models/keypad_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/calc_scaffold.dart';
import '../widgets/formula_guide_button.dart';
import '../widgets/input_card.dart';
import '../widgets/numeric_keypad.dart';
import '../widgets/result_box.dart';

enum _WidthUnit { inch, cm }

enum _LengthUnit { meter, yard }

/// Yarn Consumption Calculator (Knitting)
/// ----------------------------------------
/// একটা নির্দিষ্ট পরিমাণ নিটেড ফেব্রিক বানাতে মোট কত সুতা লাগবে (ওয়েস্টেজ
/// সহ) তা বের করে দেয়। GSM, Width ও Length দিয়ে প্রথমে নেট ফেব্রিক
/// ওজন বের হয়, তারপর নিটিং ফ্লোর ওয়েস্টেজ % যোগ করে মোট ইয়ার্ন
/// কনজাম্পশন (kg) পাওয়া যায় — এটাই আসলে মিল যে পরিমাণ সুতা অর্ডার/ইস্যু
/// করে।
class YarnConsumptionScreen extends StatefulWidget {
  const YarnConsumptionScreen({super.key});

  @override
  State<YarnConsumptionScreen> createState() => _YarnConsumptionScreenState();
}

class _YarnConsumptionScreenState extends State<YarnConsumptionScreen> {
  final ctrl = KeypadFieldController(['gsm', 'width', 'length', 'wastage']);

  _WidthUnit _widthUnit = _WidthUnit.inch;
  _LengthUnit _lengthUnit = _LengthUnit.meter;

  double? _netKg;
  double? _wastageKg;
  double? _totalKg;

  void _recalc() {
    final gsm = ctrl.number('gsm');
    final widthVal = ctrl.number('width');
    final lengthVal = ctrl.number('length');
    final wastagePct = ctrl.number('wastage') ?? 0.0;

    if (gsm == null ||
        gsm <= 0 ||
        widthVal == null ||
        widthVal <= 0 ||
        lengthVal == null ||
        lengthVal <= 0) {
      setState(() {
        _netKg = null;
        _wastageKg = null;
        _totalKg = null;
      });
      return;
    }

    final widthM =
        widthVal * (_widthUnit == _WidthUnit.inch ? 0.0254 : 0.01);
    final lengthM =
        lengthVal * (_lengthUnit == _LengthUnit.meter ? 1.0 : 0.9144);

    final netKg = (gsm * widthM * lengthM) / 1000;
    final wastageKg = netKg * (wastagePct / 100);

    setState(() {
      _netKg = netKg;
      _wastageKg = wastageKg;
      _totalKg = netKg + wastageKg;
    });
  }

  String get _widthUnitLabel => _widthUnit == _WidthUnit.inch ? 'inch' : 'cm';
  String get _lengthUnitLabel =>
      _lengthUnit == _LengthUnit.meter ? 'm' : 'yd';

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'YARN CONSUMPTION\nCALCULATOR',
      icon: Icons.grid_on_rounded,
      iconAsset: 'assets/homeicon/yarn_consumption.webp',
      extraHeaderAction: FormulaGuideButton(
        title: 'Yarn Consumption (Knitting)',
        sections: [
          FormulaGuideSection(
            heading: 'সংজ্ঞা (Definition)',
            body: 'Yarn Consumption বলতে বোঝায় — নির্দিষ্ট পরিমাণ নিটেড '
                'ফেব্রিক বানাতে মোট কত সুতা (ওয়েস্টেজ সহ) লাগবে। শুধু '
                'ফেব্রিকের থিওরিটিক্যাল ওজন নয় — নিটিং ফ্লোরে সুতার '
                'ওয়েস্টেজ (মেশিন সেটিং, ট্রায়াল লেংথ, ব্রেকেজ, ওয়েস্ট '
                'ইয়ার্ন) যোগ করেই আসল কনজাম্পশন হিসাব করা হয়, যা দিয়ে '
                'মিল সুতা অর্ডার/ইস্যু করে।',
          ),
          FormulaGuideSection(
            heading: 'ফরমুলা (Formula)',
            body: 'Net Fabric Weight (kg) = (GSM × Width(m) × Length(m)) '
                '÷ 1000\n\n'
                'Wastage Yarn (kg) = Net Fabric Weight × (Wastage % ÷ '
                '100)\n\n'
                'Total Yarn Consumption (kg) = Net Fabric Weight + '
                'Wastage Yarn',
          ),
          FormulaGuideSection(
            heading: 'ম্যানুয়ালি কীভাবে বের করবেন?',
            body: '১) Width ও Length-কে মিটারে নিয়ে আসুন (ইঞ্চি হলে '
                '০.০২৫৪ দিয়ে গুণ করুন, গজ হলে ০.৯১৪৪ দিয়ে)।\n'
                '২) GSM × Width(m) × Length(m) করে ১০০০ দিয়ে ভাগ করলে '
                'নেট ফেব্রিক ওজন (kg) পাওয়া যাবে।\n'
                '৩) নেট ওজনের সাথে ওয়েস্টেজ % যোগ করলে মোট প্রয়োজনীয় '
                'সুতা (kg) পাওয়া যাবে।',
          ),
          FormulaGuideSection(
            heading: 'উদাহরণ (Example)',
            body: 'ধরুন GSM = 180, Width = 60 inch, Length = 1000 '
                'meter, Wastage = 3%।\n\n'
                'Width(m) = 60 × 0.0254 = 1.524 m\n'
                'Net Weight = (180 × 1.524 × 1000) ÷ 1000 = 274.32 kg\n'
                'Wastage = 274.32 × 0.03 = 8.23 kg\n'
                'Total Yarn Consumption = 274.32 + 8.23 = 282.55 kg',
          ),
          FormulaGuideSection(
            heading: 'Wastage % টিপস',
            body: 'সাধারণত সার্কুলার নিটিং-এ ওয়েস্টেজ প্রায় ২–৫% ধরা '
                'হয় (মেশিন, স্ট্রাকচার ও মিলের প্র্যাকটিস অনুযায়ী '
                'ভিন্ন হতে পারে)। এই ফিল্ড খালি রাখলে ০% ধরেই হিসাব '
                'হবে — নিজের মিলের এভারেজ ওয়েস্টেজ % বসিয়ে নিন।',
          ),
        ],
      ),
      onReset: () => setState(() {
        ctrl.resetAll();
        _widthUnit = _WidthUnit.inch;
        _lengthUnit = _LengthUnit.meter;
        _netKg = null;
        _wastageKg = null;
        _totalKg = null;
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
              icon: Icons.scale_rounded,
              label: 'Fabric GSM',
              subLabel: 'Grams per Square Meter',
              value: ctrl.values['gsm']!,
              unit: 'g/m²',
              placeholder: '0.0',
              iconGradient: AppColors.purpleIconGradient,
              accentColor: AppColors.purple,
              active: ctrl.activeId == 'gsm',
              onTap: () => setState(() => ctrl.setActive('gsm')),
            ),
            const SizedBox(height: 14.0),
            _SegmentedToggle<_WidthUnit>(
              value: _widthUnit,
              options: const {
                _WidthUnit.inch: 'Inch',
                _WidthUnit.cm: 'Cm',
              },
              onChanged: (v) => setState(() {
                _widthUnit = v;
                _recalc();
              }),
            ),
            const SizedBox(height: 8.0),
            InputCard(
              icon: Icons.swap_horiz_rounded,
              label: 'Fabric Width',
              subLabel: 'Fabric Width Value',
              value: ctrl.values['width']!,
              unit: _widthUnitLabel,
              placeholder: '0.0',
              iconGradient: AppColors.tealIconGradient,
              accentColor: AppColors.teal,
              active: ctrl.activeId == 'width',
              onTap: () => setState(() => ctrl.setActive('width')),
            ),
            const SizedBox(height: 14.0),
            _SegmentedToggle<_LengthUnit>(
              value: _lengthUnit,
              options: const {
                _LengthUnit.meter: 'Meter',
                _LengthUnit.yard: 'Yard',
              },
              onChanged: (v) => setState(() {
                _lengthUnit = v;
                _recalc();
              }),
            ),
            const SizedBox(height: 8.0),
            InputCard(
              icon: Icons.straighten_rounded,
              label: 'Fabric Length Required',
              subLabel: 'Total Fabric to Produce',
              value: ctrl.values['length']!,
              unit: _lengthUnitLabel,
              placeholder: '0.0',
              iconGradient: AppColors.greenIconGradient,
              accentColor: AppColors.green,
              active: ctrl.activeId == 'length',
              onTap: () => setState(() => ctrl.setActive('length')),
            ),
            const SizedBox(height: 8.0),
            InputCard(
              icon: Icons.delete_outline_rounded,
              label: 'Wastage %',
              subLabel: 'Optional — Knitting Floor Loss',
              value: ctrl.values['wastage']!,
              unit: '%',
              placeholder: 'e.g. 3',
              iconGradient: AppColors.purpleIconGradient,
              accentColor: AppColors.orange,
              active: ctrl.activeId == 'wastage',
              onTap: () => setState(() => ctrl.setActive('wastage')),
            ),
            const SizedBox(height: 12.0),
            Row(
              children: [
                Expanded(
                  child: ResultBox(
                    label: 'Net Fabric Weight',
                    value: _netKg != null
                        ? '${_netKg!.toStringAsFixed(2)} kg'
                        : '0.00 kg',
                    borderColor:
                        _netKg != null ? AppColors.green : AppColors.inputBorder,
                    live: _netKg != null,
                    dense: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ResultBox(
                    label: 'Wastage Yarn',
                    value: _wastageKg != null
                        ? '${_wastageKg!.toStringAsFixed(2)} kg'
                        : '0.00 kg',
                    borderColor: _wastageKg != null
                        ? AppColors.orange
                        : AppColors.inputBorder,
                    live: _wastageKg != null,
                    dense: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ResultBox(
              label: 'TOTAL YARN CONSUMPTION',
              value: _totalKg != null
                  ? '${_totalKg!.toStringAsFixed(2)} kg'
                  : '0.00 kg',
              borderColor:
                  _totalKg != null ? AppColors.green : AppColors.inputBorder,
              live: _totalKg != null,
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

/// N-অপশনের সেগমেন্টেড টগল — yarn_weight_screen.dart-এর মতোই একই ডিজাইন
/// (প্রতিটা স্ক্রিন স্বনির্ভর রাখার জন্য এখানে আলাদাভাবে সংজ্ঞায়িত)।
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
