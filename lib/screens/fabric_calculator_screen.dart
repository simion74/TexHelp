import 'package:flutter/material.dart';
import '../models/keypad_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/calc_scaffold.dart';
import '../widgets/input_card.dart';
import '../widgets/numeric_keypad.dart';

class FabricCalculatorScreen extends StatefulWidget {
  const FabricCalculatorScreen({super.key});

  @override
  State<FabricCalculatorScreen> createState() => _FabricCalculatorScreenState();
}

class _FabricCalculatorScreenState extends State<FabricCalculatorScreen> {
  final ctrl = KeypadFieldController(['length', 'width', 'gsm', 'kg']);
  final Set<String> _resultIds = {}; // কোন ফিল্ডটি অটো-ক্যালকুলেটেড রেজাল্ট

  void _clearResultFlag(String id) => _resultIds.remove(id);

  void _recalc() {
    // active না এমন সব রেজাল্ট ফিল্ড ক্লিয়ার করে দেওয়া (নতুন করে হিসাব করার জন্য)
    for (final id in List<String>.from(_resultIds)) {
      if (id != ctrl.activeId) {
        ctrl.setValue(id, '');
        _resultIds.remove(id);
      }
    }

    final L = ctrl.number('length');
    final Win = ctrl.number('width');
    final G = ctrl.number('gsm');
    final K = ctrl.number('kg');

    final hasL = L != null;
    final hasW = Win != null;
    final hasG = G != null;
    final hasK = K != null;

    final filled = [hasL, hasW, hasG, hasK].where((e) => e).length;
    if (filled == 3) {
      final Wm = (Win ?? 0) * 0.0254;
      if (!hasK) {
        final res = (L! * Wm * G!) / 1000;
        ctrl.setValue('kg', res.toStringAsFixed(2));
        _resultIds.add('kg');
      } else if (!hasL) {
        final res = (K! * 1000) / (Wm * G!);
        ctrl.setValue('length', res.toStringAsFixed(2));
        _resultIds.add('length');
      } else if (!hasW) {
        final resM = (K! * 1000) / (L! * G!);
        final resInch = resM / 0.0254;
        ctrl.setValue('width', resInch.toStringAsFixed(1));
        _resultIds.add('width');
      } else if (!hasG) {
        final res = (K! * 1000) / (L! * Wm);
        ctrl.setValue('gsm', res.toStringAsFixed(0));
        _resultIds.add('gsm');
      }
    }
  }

  void _onDigit(String v) => setState(() {
        if (_resultIds.contains(ctrl.activeId)) {
          _clearResultFlag(ctrl.activeId);
          ctrl.setValue(ctrl.activeId, '');
        }
        ctrl.appendDigit(v);
        _recalc();
      });

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'FABRIC\nCALCULATOR',
      icon: Icons.calculate_rounded,
      onReset: () => setState(() {
        ctrl.resetAll();
        _resultIds.clear();
      }),
      // ১. সম্পূর্ণ কন্টেন্টের চারপাশের প্যাডিং নিয়ন্ত্রণ করার জন্য:
      content: Padding(
        padding: const EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 28.0,
          bottom: 9.0, // <-- এই কাস্টম প্যাডিং মান পরিবর্তন করে নিতে পারেন
        ),
        child: Column(
          children: [
            InputCard(
              icon: Icons.straighten_rounded,
              label: 'Length',
              subLabel: '(Meter)',
              value: ctrl.values['length']!,
              unit: 'm',
              placeholder: 'Enter length',
              iconGradient: AppColors.greenIconGradient,
              accentColor: AppColors.green,
              active: ctrl.activeId == 'length',
              isResult: _resultIds.contains('length'),
              onTap: () => setState(() => ctrl.setActive('length')),
            ),

            // ২. ইনপুট কার্ডগুলোর মাঝের দূরত্ব পরিবর্তন করতে height পরিবর্তন করুন:
            const SizedBox(height: 6.0),

            InputCard(
              icon: Icons.swap_horiz_rounded,
              label: 'Width/Dia',
              subLabel: '(Inch)',
              value: ctrl.values['width']!,
              unit: 'in',
              placeholder: 'Enter width',
              iconGradient: AppColors.tealIconGradient,
              accentColor: AppColors.teal,
              active: ctrl.activeId == 'width',
              isResult: _resultIds.contains('width'),
              onTap: () => setState(() => ctrl.setActive('width')),
            ),

            const SizedBox(height: 6.0),

            InputCard(
              icon: Icons.layers_rounded,
              label: 'GSM',
              subLabel: '(g/m²)',
              value: ctrl.values['gsm']!,
              unit: 'g/m²',
              placeholder: 'Enter GSM',
              iconGradient: AppColors.darkTealIconGradient,
              accentColor: AppColors.darkTeal,
              active: ctrl.activeId == 'gsm',
              isResult: _resultIds.contains('gsm'),
              onTap: () => setState(() => ctrl.setActive('gsm')),
            ),

            const SizedBox(height: 6.0),

            InputCard(
              icon: Icons.monitor_weight_rounded,
              label: 'Weight',
              subLabel: '(Kg)',
              value: ctrl.values['kg']!,
              unit: 'KG',
              placeholder: 'Auto Calculate',
              iconGradient: AppColors.limeIconGradient,
              accentColor: AppColors.lightGreen,
              active: ctrl.activeId == 'kg',
              isResult: _resultIds.contains('kg'),
              onTap: () => setState(() => ctrl.setActive('kg')),
            ),

            const SizedBox(height: 6.0),

            const Text(
              'যেকোনো ৩টি মান দিলে বাকি একটি স্বয়ংক্রিয়ভাবে হিসাব হবে',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.black54),
            ),
          ],
        ),
      ),
      keypad: NumericKeypad(
        onDigit: _onDigit,
        onBackspace: () => setState(() {
          if (_resultIds.contains(ctrl.activeId)) {
            _clearResultFlag(ctrl.activeId);
            ctrl.setValue(ctrl.activeId, '');
          } else {
            ctrl.backspace();
          }
          _recalc();
        }),
        onClear: () => setState(() {
          _clearResultFlag(ctrl.activeId);
          ctrl.clearActive();
          _recalc();
        }),
        onUp: () => setState(() => ctrl.moveField(-1)),
        onDown: () => setState(() => ctrl.moveField(1)),
      ),
    );
  }
}
