import 'package:flutter/material.dart';
import '../models/keypad_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/calc_scaffold.dart';
import '../widgets/compact_input_card.dart';
import '../widgets/input_card.dart';
import '../widgets/numeric_keypad.dart';
import '../widgets/result_box.dart';

class ShrinkageScreen extends StatefulWidget {
  const ShrinkageScreen({super.key});

  @override
  State<ShrinkageScreen> createState() => _ShrinkageScreenState();
}

class _ShrinkageScreenState extends State<ShrinkageScreen> {
  final ctrl = KeypadFieldController(['l1', 'w1', 'l2', 'w2', 'displacement']);

  double? _lengthShrink;
  double? _widthShrink;
  double? _spirality;

  void _recalc() {
    final l1 = ctrl.number('l1');
    final w1 = ctrl.number('w1');
    final l2 = ctrl.number('l2');
    final w2 = ctrl.number('w2');
    final d = ctrl.number('displacement');

    setState(() {
      _lengthShrink =
          (l1 != null && l2 != null && l1 > 0) ? ((l1 - l2) / l1) * 100 : null;
      _widthShrink =
          (w1 != null && w2 != null && w1 > 0) ? ((w1 - w2) / w1) * 100 : null;
      _spirality = (d != null && l1 != null && l1 > 0) ? (d / l1) * 100 : null;
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
      onReset: () => setState(() {
        ctrl.resetAll();
        _recalc();
      }),
      // ১. সম্পূর্ণ কন্টেন্টের বাইরের প্যাডিং কাস্টমাইজ করতে এটি ব্যবহার করুন:
      content: Padding(
        padding: const EdgeInsets.only(
          left: 12.0,
          right: 12.0,
          top: 28.0,
          bottom: 18.0, // <-- প্রয়োজন অনুযায়ী বাড়াতে/কমাতে পারেন
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

            // ২. সেকশনগুলোর মাঝের ভার্টিক্যাল গ্যাপ কাস্টমাইজ করতে height ছোট/বড় করুন:
            const SizedBox(height: 4.0),

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

            const SizedBox(height: 4.0),

            InputCard(
              icon: Icons.rotate_right_rounded,
              label: 'Displacement (D)',
              subLabel: 'Spirality Dev.',
              value: ctrl.values['displacement']!,
              unit: 'cm',
              placeholder: '0.0',
              iconGradient: AppColors.greenIconGradient,
              accentColor: AppColors.green,
              active: ctrl.activeId == 'displacement',
              dense: true,
              onTap: () => setState(() => ctrl.setActive('displacement')),
            ),

            const SizedBox(height: 6.0),

            Row(
              children: [
                Expanded(
                  child: ResultBox(
                    label: 'Length %',
                    value: _lengthShrink != null
                        ? '${_lengthShrink!.toStringAsFixed(2)}%'
                        : '0.00',
                    borderColor: _lengthShrink != null
                        ? AppColors.teal
                        : AppColors.inputBorder,
                    live: _lengthShrink != null,
                    dense: true,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: ResultBox(
                    label: 'Width %',
                    value: _widthShrink != null
                        ? '${_widthShrink!.toStringAsFixed(2)}%'
                        : '0.00',
                    borderColor: _widthShrink != null
                        ? AppColors.purple
                        : AppColors.inputBorder,
                    live: _widthShrink != null,
                    dense: true,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: ResultBox(
                    label: 'Spirality %',
                    value: _spirality != null
                        ? '${_spirality!.toStringAsFixed(2)}%'
                        : '0.00',
                    borderColor: _spirality != null
                        ? AppColors.green
                        : AppColors.inputBorder,
                    live: _spirality != null,
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
