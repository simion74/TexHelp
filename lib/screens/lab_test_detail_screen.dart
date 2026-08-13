import 'package:flutter/material.dart';
import '../data/lab_test_data.dart';
import '../theme/app_colors.dart';
import '../widgets/library_scaffold.dart';
import '../widgets/library_thumbnail.dart';
import '../widgets/library_wave_header.dart';

class LabTestDetailScreen extends StatefulWidget {
  final LabTestItem test;
  final bool initialIsEnglish;

  const LabTestDetailScreen({
    super.key,
    required this.test,
    this.initialIsEnglish = true,
  });

  @override
  State<LabTestDetailScreen> createState() => _LabTestDetailScreenState();
}

class _LabTestDetailScreenState extends State<LabTestDetailScreen> {
  late bool _isEnglish;

  @override
  void initState() {
    super.initState();
    _isEnglish = widget.initialIsEnglish;
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.test;

    return LibraryScaffold(
      header: LibraryWaveHeader(
        title: t.name,
        isBack: true,
        onLeadingTap: () => Navigator.of(context).pop(),
        isEnglish: _isEnglish,
        onLanguageChanged: (v) => setState(() => _isEnglish = v),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: LibraryThumbnail(
              imagePath: t.image,
              icon: t.categoryIcon,
              color: t.categoryColor,
              borderRadius: 16,
            ),
          ),
          const SizedBox(height: 14),

          // 🏷️ নাম / ক্যাটাগরি কার্ড
          _WhiteInfoCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _LabeledValue(
                    icon: Icons.science_rounded,
                    iconColor: AppColors.green,
                    label: 'Test Name',
                    labelColor: AppColors.green,
                    value: t.name,
                  ),
                ),
                const SizedBox(
                    height: 46,
                    child: VerticalDivider(width: 24, thickness: 1)),
                Expanded(
                  child: _LabeledValue(
                    icon: t.categoryIcon,
                    iconColor: t.categoryColor,
                    label: _isEnglish ? 'Category' : 'ক্যাটাগরি',
                    labelColor: t.categoryColor,
                    value: _isEnglish ? t.categoryEn : t.categoryBn,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          _ColorInfoCard(
            bgColor: const Color(0xFFEFF6FF),
            icon: Icons.menu_book_rounded,
            iconColor: AppColors.teal,
            titleColor: AppColors.teal,
            title: _isEnglish ? 'What Is It' : 'এটা কী',
            child: Text(
              _isEnglish ? t.whatIsItEn : t.whatIsItBn,
              style: const TextStyle(fontSize: 12.5, height: 1.45),
            ),
          ),
          const SizedBox(height: 12),

          _ColorInfoCard(
            bgColor: const Color(0xFFF1F8E9),
            icon: Icons.priority_high_rounded,
            iconColor: AppColors.green,
            titleColor: AppColors.green,
            title: _isEnglish ? 'Why It Is Important' : 'কেন গুরুত্বপূর্ণ',
            child: Text(
              _isEnglish ? t.whyItIsImportantEn : t.whyItIsImportantBn,
              style: const TextStyle(fontSize: 12.5, height: 1.45),
            ),
          ),
          const SizedBox(height: 12),

          _ColorInfoCard(
            bgColor: const Color(0xFFFFF3E0),
            icon: Icons.build_circle_rounded,
            iconColor: AppColors.orange,
            titleColor: AppColors.orange,
            title: _isEnglish ? 'How It Is Done' : 'কীভাবে করা হয়',
            child: Text(
              _isEnglish ? t.howItIsDoneEn : t.howItIsDoneBn,
              style: const TextStyle(fontSize: 12.5, height: 1.45),
            ),
          ),
          const SizedBox(height: 12),

          _ColorInfoCard(
            bgColor: const Color(0xFFEDE7F6),
            icon: Icons.fact_check_rounded,
            iconColor: AppColors.purple,
            titleColor: AppColors.purple,
            title: _isEnglish ? 'Standard Method' : 'স্ট্যান্ডার্ড মেথড',
            child: Text(
              _isEnglish ? t.standardMethodEn : t.standardMethodBn,
              style: const TextStyle(
                  fontSize: 12.5, height: 1.45, fontWeight: FontWeight.w700),
            ),
          ),

          if (t.formulaEn != null && t.formulaEn!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _ColorInfoCard(
              bgColor: const Color(0xFFE0F7FA),
              icon: Icons.functions_rounded,
              iconColor: AppColors.darkTeal,
              titleColor: AppColors.darkTeal,
              title: _isEnglish ? 'Formula' : 'ফরমুলা',
              child: Text(
                _isEnglish ? t.formulaEn! : (t.formulaBn ?? t.formulaEn!),
                style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.45,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
          const SizedBox(height: 12),

          _ColorInfoCard(
            bgColor: const Color(0xFFFCE4EC),
            icon: Icons.rule_rounded,
            iconColor: AppColors.pink,
            titleColor: AppColors.pink,
            title: _isEnglish ? 'Result & Evaluation' : 'রেজাল্ট ও মূল্যায়ন',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_isEnglish ? "Unit" : "একক"}: '
                  '${_isEnglish ? t.resultUnitEn : t.resultUnitBn}',
                  style: const TextStyle(
                      fontSize: 12.5, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  _isEnglish ? t.resultEvaluationEn : t.resultEvaluationBn,
                  style: const TextStyle(fontSize: 12.5, height: 1.45),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          _ColorInfoCard(
            bgColor: const Color(0xFFFFEBEE),
            icon: Icons.report_problem_rounded,
            iconColor: Colors.redAccent,
            titleColor: Colors.redAccent,
            title: _isEnglish ? 'Common Failure Causes' : 'ব্যর্থতার সাধারণ কারণ',
            child: Text(
              _isEnglish ? t.commonFailureCausesEn : t.commonFailureCausesBn,
              style: const TextStyle(fontSize: 12.5, height: 1.45),
            ),
          ),
          const SizedBox(height: 16),

          // ⚠️ ডিসক্লেইমার
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.04),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black12),
            ),
            child: Text(
              _isEnglish ? kLabTestDisclaimerEn : kLabTestDisclaimerBn,
              style: const TextStyle(
                  fontSize: 9.5, color: Colors.black54, height: 1.4),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _WhiteInfoCard extends StatelessWidget {
  final Widget child;
  const _WhiteInfoCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
      ),
      child: child,
    );
  }
}

class _ColorInfoCard extends StatelessWidget {
  final Color bgColor;
  final IconData icon;
  final Color iconColor;
  final Color titleColor;
  final String title;
  final Widget child;

  const _ColorInfoCard({
    required this.bgColor,
    required this.icon,
    required this.iconColor,
    required this.titleColor,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(title,
                    style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: titleColor)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _LabeledValue extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color labelColor;
  final String label;
  final String value;

  const _LabeledValue({
    required this.icon,
    required this.iconColor,
    required this.labelColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: labelColor)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A))),
            ],
          ),
        ),
      ],
    );
  }
}
