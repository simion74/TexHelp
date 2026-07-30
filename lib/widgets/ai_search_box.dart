import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'ai_icon.dart';

/// 🤖 "AI Support" লেবেল (বাম পাশে) + সার্চ বক্স (ডান পাশে) — Machine
/// Library, Fabric Fault, Fabric Type — তিনটা ফিচারেই এই একই কম্পোনেন্ট
/// ব্যবহার হয়। টাইপ করে সাবমিট (কীবোর্ড এন্টার) করলে বা ডানপাশের বাটনে
/// চাপ দিলে [onSearch] কল হবে।
class AiSearchBox extends StatefulWidget {
  final String hintText;
  final ValueChanged<String> onSearch;
  final Color accentColor;
  final bool isLoading;

  const AiSearchBox({
    super.key,
    required this.hintText,
    required this.onSearch,
    this.accentColor = AppColors.green,
    this.isLoading = false,
  });

  @override
  State<AiSearchBox> createState() => _AiSearchBoxState();
}

class _AiSearchBoxState extends State<AiSearchBox> {
  final TextEditingController _controller = TextEditingController();

  void _submit() {
    final q = _controller.text.trim();
    if (q.isEmpty) return;
    FocusScope.of(context).unfocus();
    widget.onSearch(q);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 🏷️ বাম পাশে "AI Support" লেবেল
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          decoration: BoxDecoration(
            color: widget.accentColor.withOpacity(0.10),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: widget.accentColor.withOpacity(0.35)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AiIcon(size: 20),
              const SizedBox(height: 2),
              Text(
                'AI Support',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    height: 1.05,
                    color: widget.accentColor),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // 🔎 ডান পাশে সার্চ বক্স
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2)),
              ],
            ),
            child: TextField(
              controller: _controller,
              onSubmitted: (_) => _submit(),
              style: const TextStyle(fontSize: 12.5),
              decoration: InputDecoration(
                isDense: true,
                hintText: widget.hintText,
                hintStyle: const TextStyle(fontSize: 11, color: Colors.black38),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                suffixIcon: widget.isLoading
                    ? Padding(
                        padding: const EdgeInsets.all(12),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: widget.accentColor),
                        ),
                      )
                    : IconButton(
                        icon: Icon(Icons.search_rounded,
                            color: widget.accentColor, size: 20),
                        onPressed: _submit,
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
