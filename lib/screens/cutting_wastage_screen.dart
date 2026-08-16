import 'package:flutter/material.dart';
import '../models/keypad_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/calc_scaffold.dart';
import '../widgets/formula_guide_button.dart';
import '../widgets/input_card.dart';
import '../widgets/numeric_keypad.dart';
import '../widgets/result_box.dart';

enum _WeightUnit { kg, gram, lbs }

/// Cutting Wastage Calculator (Cutting Section)
/// ---------------------------------------------
/// Fabric Issued (কাটিং সেকশনে যত ফেব্রিক ইস্যু হয়েছে) ও Fabric
/// Consumed (গার্মেন্টসে আসলে যত ফেব্রিক ব্যবহার হয়েছে) দিলে
/// Cutting Wastage Quantity ও Wastage % বের করে দেয়। অ্যাপের বাকি সব
/// ক্যালকুলেটরের মতোই একই CalcScaffold, একই NumericKeypad এবং হেডারে
/// একই FormulaGuideButton ব্যবহার করা হয়েছে।
class CuttingWastageScreen extends StatefulWidget {
  const CuttingWastageScreen({super.key});

  @override
  State<CuttingWastageScreen> createState() => _CuttingWastageScreenState();
}

class _CuttingWastageScreenState extends State<CuttingWastageScreen> {
  final ctrl = KeypadFieldController(['issued', 'consumed']);

  _WeightUnit _unit = _WeightUnit.kg;

  double? _wastageQty;
  double? _wastagePercent;

  void _recalc() {
    final issuedVal = ctrl.number('issued');
    final consumedVal = ctrl.number('consumed');

    if (issuedVal == null ||
        issuedVal <= 0 ||
        consumedVal == null ||
        consumedVal < 0 ||
        consumedVal > issuedVal) {
      setState(() {
        _wastageQty = null;
        _wastagePercent = null;
      });
      return;
    }

    final wastageQty = issuedVal - consumedVal;
    final wastagePercent = (wastageQty / issuedVal) * 100;

    setState(() {
      _wastageQty = wastageQty;
      _wastagePercent = wastagePercent;
    });
  }

  String get _unitLabel {
    switch (_unit) {
      case _WeightUnit.kg:
        return 'kg';
      case _WeightUnit.gram:
        return 'g';
      case _WeightUnit.lbs:
        return 'lbs';
    }
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'CUTTING WASTAGE\nCALCULATOR',
      icon: Icons.content_cut_rounded,
      iconAsset: 'assets/homeicon/cutting_wastage.webp',
      extraHeaderAction: FormulaGuideButton(
        title: 'Cutting Wastage Calculator',
        sections: [
          FormulaGuideSection(
            heading: 'সংজ্ঞা (Definition)',
            body: 'কাটিং সেকশনে ফেব্রিক ইস্যু করার পর মার্কার লস, এন্ড '
                'বিট, ফল্ট ফেব্রিক ইত্যাদির কারণে কিছু ফেব্রিক নষ্ট বা '
                'অব্যবহৃত থেকে যায়। ইস্যু করা মোট ফেব্রিক এবং গার্মেন্টসে '
                'আসলে ব্যবহৃত ফেব্রিকের পার্থক্যকে Cutting Wastage বলা '
                'হয়, যা সাধারণত শতকরা হারে (%) প্রকাশ করা হয়।',
          ),
          FormulaGuideSection(
            heading: 'ফরমুলা (Formula)',
            body: 'Wastage Quantity = Fabric Issued − Fabric Consumed\n\n'
                'Wastage % = (Wastage Quantity ÷ Fabric Issued) × 100',
          ),
          FormulaGuideSection(
            heading: 'ম্যানুয়ালি কীভাবে বের করবেন?',
            body: '১) কাটিং সেকশনে মোট যত ফেব্রিক ইস্যু হয়েছে তা লিখুন '
                '(Fabric Issued)।\n'
                '২) গার্মেন্টসে আসলে যত ফেব্রিক ব্যবহার হয়েছে তা লিখুন '
                '(Fabric Consumed) — এটা সাধারণত গার্মেন্টস প্রতি '
                'ফেব্রিক কনজাম্পশন × মোট পিস সংখ্যা থেকে পাওয়া যায়।\n'
                '৩) Issued থেকে Consumed বাদ দিলে Wastage Quantity পাওয়া '
                'যাবে।\n'
                '৪) Wastage Quantity কে Issued দিয়ে ভাগ করে ১০০ দিয়ে '
                'গুণ করলে Wastage % পাওয়া যাবে।',
          ),
          FormulaGuideSection(
            heading: 'উদাহরণ (Example)',
            body: 'ধরুন Fabric Issued = 500 kg, Fabric Consumed = 460 kg।\n\n'
                'Wastage Quantity = 500 − 460 = 40 kg\n'
                'Wastage % = (40 ÷ 500) × 100 = 8%\n\n'
                'অ্যাপে শুধু Fabric Issued এ 500 এবং Fabric Consumed এ '
                '460 লিখলেই এই ফলাফল অটো বের হয়ে যাবে।',
          ),
          FormulaGuideSection(
            heading: 'টিপস',
            body: 'সাধারণত গার্মেন্টস ইন্ডাস্ট্রিতে ওভেন ফেব্রিকের জন্য '
                '৩–৭% এবং নিটেড ফেব্রিকের জন্য ৮–১৫% এর কাছাকাছি Cutting '
                'Wastage গ্রহণযোগ্য ধরা হয়। এর চেয়ে বেশি হলে মার্কার '
                'প্ল্যানিং বা ফেব্রিক কোয়ালিটি চেক করা উচিত।',
          ),
        ],
      ),
      onReset: () => setState(() {
        ctrl.resetAll();
        _unit = _WeightUnit.kg;
        _wastageQty = null;
        _wastagePercent = null;
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
            _SegmentedToggle<_WeightUnit>(
              value: _unit,
              options: const {
                _WeightUnit.kg: 'Kg',
                _WeightUnit.gram: 'Gram',
                _WeightUnit.lbs: 'Lbs',
              },
              onChanged: (v) => setState(() {
                _unit = v;
                _recalc();
              }),
            ),
            const SizedBox(height: 8.0),
            InputCard(
              icon: Icons.local_shipping_rounded,
              label: 'Fabric Issued',
              subLabel: 'Total Issued Quantity',
              value: ctrl.values['issued']!,
              unit: _unitLabel,
              placeholder: '0.0',
              iconGradient: AppColors.purpleIconGradient,
              accentColor: AppColors.purple,
              active: ctrl.activeId == 'issued',
              onTap: () => setState(() => ctrl.setActive('issued')),
            ),
            const SizedBox(height: 14.0),
            InputCard(
              icon: Icons.checkroom_rounded,
              label: 'Fabric Consumed',
              subLabel: 'Actual Used in Garments',
              value: ctrl.values['consumed']!,
              unit: _unitLabel,
              placeholder: '0.0',
              iconGradient: AppColors.tealIconGradient,
              accentColor: AppColors.teal,
              active: ctrl.activeId == 'consumed',
              onTap: () => setState(() => ctrl.setActive('consumed')),
            ),
            const SizedBox(height: 12.0),
            Row(
              children: [
                Expanded(
                  child: ResultBox(
                    label: 'Wastage Qty',
                    value: _wastageQty != null
                        ? '${_wastageQty!.toStringAsFixed(2)} $_unitLabel'
                        : '0.00 $_unitLabel',
                    borderColor: _wastageQty != null
                        ? AppColors.green
                        : AppColors.inputBorder,
                    live: _wastageQty != null,
                    dense: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ResultBox(
                    label: 'Wastage %',
                    value: _wastagePercent != null
                        ? '${_wastagePercent!.toStringAsFixed(2)}%'
                        : '0.00%',
                    borderColor: _wastagePercent != null
                        ? AppColors.green
                        : AppColors.inputBorder,
                    live: _wastagePercent != null,
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

/// N-অপশনের সেগমেন্টেড টগল (Weight Unit বেছে নেওয়ার জন্য) —
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
