import 'package:flutter/material.dart';
import '../models/keypad_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/calc_scaffold.dart';
import '../widgets/input_card.dart';
import '../widgets/numeric_keypad.dart';
import '../widgets/result_box.dart';

/// Process Loss Calculator
/// ------------------------
/// Before Process Qty (Kg) ইনপুট দিয়ে, তারপর দুটোর মধ্যে যেকোনো একটি
/// (After Process Qty অথবা Target Process Loss %) দিয়ে বাকিটা অটো
/// ক্যালকুলেট হয়। process_loss.txt ওয়্যারফ্রেম অনুযায়ী বানানো হয়েছে।
class ProcessLossScreen extends StatefulWidget {
  const ProcessLossScreen({super.key});

  @override
  State<ProcessLossScreen> createState() => _ProcessLossScreenState();
}

enum _LossInputMode { afterQty, targetPct }

class _ProcessLossScreenState extends State<ProcessLossScreen> {
  // তিনটি ফিল্ড রাখা হয়েছে, কিন্তু একসাথে শুধু 'before' + বর্তমান মোডের
  // ফিল্ডটিই দেখানো ও এডিট করা হয়।
  final ctrl = KeypadFieldController(['before', 'afterQty', 'targetPct']);
  _LossInputMode _mode = _LossInputMode.afterQty;

  double? _lossQty;
  double? _lossPct;
  double? _afterQty;

  void _recalc() {
    final before = ctrl.number('before');
    double? lossQty, lossPct, afterQty;

    if (before != null && before > 0) {
      if (_mode == _LossInputMode.afterQty) {
        final after = ctrl.number('afterQty');
        if (after != null && after >= 0 && after <= before) {
          afterQty = after;
          lossQty = before - after;
          lossPct = (lossQty / before) * 100;
        }
      } else {
        final pct = ctrl.number('targetPct');
        if (pct != null && pct >= 0 && pct <= 100) {
          lossPct = pct;
          lossQty = before * (pct / 100);
          afterQty = before - lossQty;
        }
      }
    }

    setState(() {
      _lossQty = lossQty;
      _lossPct = lossPct;
      _afterQty = afterQty;
    });
  }

  void _switchMode(_LossInputMode mode) {
    if (_mode == mode) return;
    setState(() {
      // মোড বদলানোর সময় অন্য ফিল্ডের পুরোনো ভ্যালু মুছে দেওয়া হয়, যাতে
      // দুটো ইনপুট একসাথে সংঘর্ষ না করে (ওয়্যারফ্রেমে "Choose Any One")
      ctrl.setValue('afterQty', '');
      ctrl.setValue('targetPct', '');
      _mode = mode;
      ctrl.setActive(mode == _LossInputMode.afterQty ? 'afterQty' : 'targetPct');
    });
    _recalc();
  }

  // শুধু 'before' এবং বর্তমান মোডের দৃশ্যমান ফিল্ডের মধ্যেই up/down দিয়ে
  // সরানো হয় — অদৃশ্য ফিল্ডে যেন কখনো active না হয়।
  void _moveField() {
    setState(() {
      final modeId = _mode == _LossInputMode.afterQty ? 'afterQty' : 'targetPct';
      ctrl.setActive(ctrl.activeId == 'before' ? modeId : 'before');
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAfterMode = _mode == _LossInputMode.afterQty;

    return CalcScaffold(
      title: 'PROCESS LOSS\nCALCULATOR',
      icon: Icons.compress_rounded,
      onReset: () => setState(() {
        ctrl.resetAll();
        _mode = _LossInputMode.afterQty;
        _lossQty = null;
        _lossPct = null;
        _afterQty = null;
      }),
      content: Padding(
        padding: const EdgeInsets.only(left: 14, right: 14, top: 20, bottom: 10),
        child: Column(
          children: [
            InputCard(
              icon: Icons.scale_rounded,
              label: 'Before Process Qty',
              subLabel: 'Fabric Qty Before Process',
              value: ctrl.values['before']!,
              unit: 'kg',
              placeholder: '0.0',
              iconGradient: AppColors.greenIconGradient,
              accentColor: AppColors.green,
              active: ctrl.activeId == 'before',
              onTap: () => setState(() => ctrl.setActive('before')),
            ),
            const SizedBox(height: 6),
            _ModeToggle(
              isAfterMode: isAfterMode,
              onSelect: _switchMode,
            ),
            const SizedBox(height: 6),
            isAfterMode
                ? InputCard(
                    key: const ValueKey('afterQty'),
                    icon: Icons.local_shipping_rounded,
                    label: 'After Process Qty',
                    subLabel: 'Fabric Qty After Process',
                    value: ctrl.values['afterQty']!,
                    unit: 'kg',
                    placeholder: '0.0',
                    iconGradient: AppColors.tealIconGradient,
                    accentColor: AppColors.teal,
                    active: ctrl.activeId == 'afterQty',
                    onTap: () => setState(() => ctrl.setActive('afterQty')),
                  )
                : InputCard(
                    key: const ValueKey('targetPct'),
                    icon: Icons.percent_rounded,
                    label: 'Target Process Loss',
                    subLabel: 'Expected Loss %',
                    value: ctrl.values['targetPct']!,
                    unit: '%',
                    placeholder: '0.0',
                    iconGradient: AppColors.purpleIconGradient,
                    accentColor: AppColors.purple,
                    active: ctrl.activeId == 'targetPct',
                    onTap: () => setState(() => ctrl.setActive('targetPct')),
                  ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ResultBox(
                    label: 'PROCESS LOSS (QTY)',
                    value: _lossQty != null ? '${_lossQty!.toStringAsFixed(2)} kg' : '0.00 kg',
                    borderColor: _lossQty != null ? AppColors.orange : AppColors.inputBorder,
                    live: _lossQty != null,
                    dense: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ResultBox(
                    label: 'PROCESS LOSS (%)',
                    value: _lossPct != null ? '${_lossPct!.toStringAsFixed(1)} %' : '0.0 %',
                    borderColor: _lossPct != null ? AppColors.orange : AppColors.inputBorder,
                    live: _lossPct != null,
                    dense: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ResultBox(
              label: 'EXPECTED DELIVERY FABRIC (AFTER PROCESS)',
              value: _afterQty != null ? '${_afterQty!.toStringAsFixed(2)} kg' : '0.00 kg',
              borderColor: _afterQty != null ? AppColors.green : AppColors.inputBorder,
              live: _afterQty != null,
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
        onUp: _moveField,
        onDown: _moveField,
      ),
    );
  }
}

/// After Process Qty / Target Process Loss % — এর মধ্যে যেকোনো একটি
/// বেছে নেওয়ার সেগমেন্টেড টগল (ওয়্যারফ্রেমের "Choose Any One")
class _ModeToggle extends StatelessWidget {
  final bool isAfterMode;
  final ValueChanged<_LossInputMode> onSelect;

  const _ModeToggle({required this.isAfterMode, required this.onSelect});

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
        children: [
          Expanded(
            child: _segment(
              label: 'After Qty (Kg)',
              selected: isAfterMode,
              onTap: () => onSelect(_LossInputMode.afterQty),
            ),
          ),
          Expanded(
            child: _segment(
              label: 'Target Loss (%)',
              selected: !isAfterMode,
              onTap: () => onSelect(_LossInputMode.targetPct),
            ),
          ),
        ],
      ),
    );
  }

  Widget _segment({required String label, required bool selected, required VoidCallback onTap}) {
    return Material(
      color: selected ? AppColors.green : Colors.transparent,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        borderRadius: BorderRadius.circular(9),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: selected ? Colors.white : AppColors.darkGreen,
            ),
          ),
        ),
      ),
    );
  }
}
