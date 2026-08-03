import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// সব ক্যালকুলেটরে একই কাস্টম কিপ্যাড ব্যবহার হয়, তাই একবার বানিয়ে
/// সব স্ক্রিনে রিইউজ করা হচ্ছে। আগের HTML ভার্সনের তুলনায় বাটন সাইজ
/// বড় ও টাচ-ফ্রেন্ডলি করা হয়েছে (মোবাইলে দ্রুত ব্যবহারের জন্য)।
class NumericKeypad extends StatelessWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final VoidCallback onClear;
  final VoidCallback onUp;
  final VoidCallback onDown;
  final double height;

  const NumericKeypad({
    super.key,
    required this.onDigit,
    required this.onBackspace,
    required this.onClear,
    required this.onUp,
    required this.onDown,
    this.height = 216,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.45),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Expanded(
            child: _row([
              _numKey('7'),
              _numKey('8'),
              _numKey('9'),
              _actionKey(
                icon: Icons.backspace_rounded,
                bg: AppColors.darkGreen,
                fg: Colors.white,
                onTap: onBackspace,
              ),
            ]),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _row([
              _numKey('4'),
              _numKey('5'),
              _numKey('6'),
              _actionKey(
                label: 'C',
                bg: AppColors.dotKeyBg,
                fg: AppColors.darkGreen,
                bold: true,
                onTap: onClear,
              ),
            ]),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _row([
              _numKey('1'),
              _numKey('2'),
              _numKey('3'),
              _actionKey(
                icon: Icons.keyboard_arrow_up_rounded,
                bg: Colors.white,
                fg: const Color(0xFF65B741),
                border: true,
                onTap: onUp,
              ),
            ]),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Row(
              children: [
                Expanded(flex: 2, child: _numKey('0')),
                const SizedBox(width: 8),
                Expanded(
                  child: _actionKey(
                    label: '.',
                    bg: AppColors.dotKeyBg,
                    fg: AppColors.darkGreen,
                    bold: true,
                    onTap: () => onDigit('.'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _actionKey(
                    icon: Icons.keyboard_arrow_down_rounded,
                    bg: Colors.white,
                    fg: const Color(0xFF65B741),
                    border: true,
                    onTap: onDown,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(List<Widget> children) {
    final spaced = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) spaced.add(const SizedBox(width: 8));
      spaced.add(Expanded(child: children[i]));
    }
    return Row(children: spaced);
  }

  Widget _numKey(String val) {
    return _KeyButton(
      onTap: () => onDigit(val),
      bg: Colors.white,
      child: Text(
        val,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.darkGreen,
        ),
      ),
    );
  }

  Widget _actionKey({
    String? label,
    IconData? icon,
    required Color bg,
    required Color fg,
    bool bold = false,
    bool border = false,
    required VoidCallback onTap,
  }) {
    return _KeyButton(
      onTap: onTap,
      bg: bg,
      border: border,
      child: icon != null
          ? Icon(icon, color: fg, size: 24)
          : Text(
              label ?? '',
              style: TextStyle(
                fontSize: 22,
                fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                color: fg,
              ),
            ),
    );
  }
}

class _KeyButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color bg;
  final Widget child;
  final bool border;

  const _KeyButton({
    required this.onTap,
    required this.bg,
    required this.child,
    this.border = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(12),
      elevation: 1.5,
      shadowColor: Colors.black26,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          onTap();
        },
        child: Container(
          decoration: border
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.inputBorder),
                )
              : null,
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }
}
