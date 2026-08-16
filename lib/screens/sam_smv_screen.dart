import 'package:flutter/material.dart';
import '../models/keypad_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/calc_scaffold.dart';
import '../widgets/formula_guide_button.dart';
import '../widgets/input_card.dart';
import '../widgets/numeric_keypad.dart';
import '../widgets/result_box.dart';

enum _TimeUnit { seconds, minutes }

/// SAM / SMV Calculator (Sewing Section)
/// ---------------------------------------
/// Observed Time (Second/Minute যেকোনো এককে), Performance Rating (%)
/// এবং Allowance (%) দিলে Standard Minute Value (SMV / SAM) এবং
/// Standard Output per Hour বের করে দেয়। অ্যাপের বাকি সব ক্যালকুলেটরের
/// মতোই একই CalcScaffold, একই NumericKeypad এবং হেডারে একই
/// FormulaGuideButton ব্যবহার করা হয়েছে।
class SamSmvScreen extends StatefulWidget {
  const SamSmvScreen({super.key});

  @override
  State<SamSmvScreen> createState() => _SamSmvScreenState();
}

class _SamSmvScreenState extends State<SamSmvScreen> {
  final ctrl = KeypadFieldController(['observed', 'rating', 'allowance']);

  _TimeUnit _timeUnit = _TimeUnit.seconds;

  double? _smv;
  double? _outputPerHour;

  void _recalc() {
    final observedVal = ctrl.number('observed');
    final ratingVal = ctrl.number('rating') ?? 100.0;
    final allowanceVal = ctrl.number('allowance') ?? 0.0;

    if (observedVal == null || observedVal <= 0 || ratingVal <= 0) {
      setState(() {
        _smv = null;
        _outputPerHour = null;
      });
      return;
    }

    // Observed Time কে মিনিটে কনভার্ট করা হচ্ছে
    final observedMin =
        _timeUnit == _TimeUnit.seconds ? observedVal / 60 : observedVal;

    // Basic Time = Observed Time × (Rating ÷ 100)
    final basicTime = observedMin * (ratingVal / 100);

    // SMV = Basic Time + (Basic Time × Allowance%)
    final smv = basicTime * (1 + allowanceVal / 100);

    setState(() {
      _smv = smv;
      _outputPerHour = smv > 0 ? 60 / smv : null;
    });
  }

  String get _timeUnitLabel {
    switch (_timeUnit) {
      case _TimeUnit.seconds:
        return 'sec';
      case _TimeUnit.minutes:
        return 'min';
    }
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'SAM / SMV\nCALCULATOR',
      icon: Icons.timer_rounded,
      iconAsset: 'assets/homeicon/sam_smv.webp',
      extraHeaderAction: FormulaGuideButton(
        title: 'SAM / SMV Calculator',
        sections: [
          FormulaGuideSection(
            heading: 'সংজ্ঞা (Definition)',
            body: 'SMV (Standard Minute Value) — যাকে SAM (Standard '
                'Allowed Minute) ও বলা হয় — হলো একটি নির্দিষ্ট সেলাই '
                'অপারেশন বা সম্পূর্ণ একটি গার্মেন্ট তৈরি করতে একজন '
                'দক্ষ অপারেটরের গড়ে যে সময় (মিনিটে) লাগে তার '
                'স্ট্যান্ডার্ড পরিমাপ। এটা Observed Time, Performance '
                'Rating এবং Allowance — এই তিনটার উপর নির্ভর করে বের '
                'করা হয়।',
          ),
          FormulaGuideSection(
            heading: 'ফরমুলা (Formula)',
            body: 'Basic Time (min) = Observed Time (min) × (Rating% ÷ 100)\n\n'
                'SMV / SAM (min) = Basic Time × (1 + Allowance% ÷ 100)\n\n'
                'Standard Output per Hour (pcs) = 60 ÷ SMV',
          ),
          FormulaGuideSection(
            heading: 'ম্যানুয়ালি কীভাবে বের করবেন?',
            body: '১) স্টপওয়াচ দিয়ে অপারেটরের Observed (Cycle) Time '
                'মেপে সেকেন্ড বা মিনিটে লিখুন।\n'
                '২) অপারেটরের কাজের গতি অনুযায়ী Performance Rating% '
                'বসান (স্ট্যান্ডার্ড গতি হলে ১০০%)।\n'
                '৩) Observed Time কে Rating% দিয়ে গুণ করে Basic Time '
                'বের করুন।\n'
                '৪) Personal, Fatigue ও অন্যান্য Allowance% যোগ করে '
                'Basic Time থেকে SMV বের করুন।\n'
                '৫) ৬০ কে SMV দিয়ে ভাগ করলে প্রতি ঘণ্টায় স্ট্যান্ডার্ড '
                'আউটপুট (পিস) পাওয়া যাবে।',
          ),
          FormulaGuideSection(
            heading: 'উদাহরণ (Example)',
            body: 'ধরুন Observed Time = 36 sec, Rating = 100%, '
                'Allowance = 15%।\n\n'
                'Observed Time (min) = 36 ÷ 60 = 0.60 min\n'
                'Basic Time = 0.60 × (100 ÷ 100) = 0.60 min\n'
                'SMV = 0.60 × (1 + 15 ÷ 100) = 0.69 min\n'
                'Output/Hour = 60 ÷ 0.69 ≈ 87 pcs\n\n'
                'অ্যাপে শুধু Observed Time এ 36 (একক Second), Rating '
                'এ 100 এবং Allowance এ 15 লিখলেই এই ফলাফল অটো বের হয়ে '
                'যাবে।',
          ),
          FormulaGuideSection(
            heading: 'টিপস',
            body: 'Rating ফিল্ড খালি রাখলে ডিফল্ট হিসেবে ১০০% ধরা হবে। '
                'গার্মেন্টস ইন্ডাস্ট্রিতে সাধারণত Allowance ১০–২০% এর '
                'মধ্যে ব্যবহার করা হয় (Personal, Fatigue ও Contingency '
                'Allowance মিলিয়ে)। পুরো গার্মেন্টের SAM বের করতে হলে '
                'সব অপারেশনের SMV একসাথে যোগ করতে হয়।',
          ),
        ],
      ),
      onReset: () => setState(() {
        ctrl.resetAll();
        _timeUnit = _TimeUnit.seconds;
        _smv = null;
        _outputPerHour = null;
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
            _SegmentedToggle<_TimeUnit>(
              value: _timeUnit,
              options: const {
                _TimeUnit.seconds: 'Second',
                _TimeUnit.minutes: 'Minute',
              },
              onChanged: (v) => setState(() {
                _timeUnit = v;
                _recalc();
              }),
            ),
            const SizedBox(height: 8.0),
            InputCard(
              icon: Icons.timer_outlined,
              label: 'Observed Time',
              subLabel: 'Cycle Time Value',
              value: ctrl.values['observed']!,
              unit: _timeUnitLabel,
              placeholder: '0.0',
              iconGradient: AppColors.purpleIconGradient,
              accentColor: AppColors.purple,
              active: ctrl.activeId == 'observed',
              onTap: () => setState(() => ctrl.setActive('observed')),
            ),
            const SizedBox(height: 8.0),
            InputCard(
              icon: Icons.speed_rounded,
              label: 'Performance Rating',
              subLabel: 'Optional — default 100%',
              value: ctrl.values['rating']!,
              unit: '%',
              placeholder: '100',
              iconGradient: AppColors.tealIconGradient,
              accentColor: AppColors.teal,
              active: ctrl.activeId == 'rating',
              onTap: () => setState(() => ctrl.setActive('rating')),
            ),
            const SizedBox(height: 8.0),
            InputCard(
              icon: Icons.self_improvement_rounded,
              label: 'Allowance',
              subLabel: 'Personal + Fatigue + Contingency',
              value: ctrl.values['allowance']!,
              unit: '%',
              placeholder: '0',
              iconGradient: AppColors.greenIconGradient,
              accentColor: AppColors.green,
              active: ctrl.activeId == 'allowance',
              onTap: () => setState(() => ctrl.setActive('allowance')),
            ),
            const SizedBox(height: 12.0),
            Row(
              children: [
                Expanded(
                  child: ResultBox(
                    label: 'SMV / SAM (min)',
                    value: _smv != null
                        ? '${_smv!.toStringAsFixed(3)} min'
                        : '0.000 min',
                    borderColor:
                        _smv != null ? AppColors.green : AppColors.inputBorder,
                    live: _smv != null,
                    dense: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ResultBox(
                    label: 'Output / Hour',
                    value: _outputPerHour != null
                        ? '${_outputPerHour!.toStringAsFixed(1)} pcs'
                        : '0.0 pcs',
                    borderColor: _outputPerHour != null
                        ? AppColors.green
                        : AppColors.inputBorder,
                    live: _outputPerHour != null,
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

/// ২-অপশনের সেগমেন্টেড টগল (Time Unit বেছে নেওয়ার জন্য) —
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
