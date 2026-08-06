import 'package:flutter/material.dart';
import '../data/chemical_data.dart';
import '../theme/app_colors.dart';
import '../widgets/library_scaffold.dart';
import '../widgets/library_thumbnail.dart';
import '../widgets/library_wave_header.dart';

class ChemicalDetailScreen extends StatefulWidget {
  final ChemicalItem chemical;
  final bool initialIsEnglish;

  const ChemicalDetailScreen({
    super.key,
    required this.chemical,
    this.initialIsEnglish = true,
  });

  @override
  State<ChemicalDetailScreen> createState() => _ChemicalDetailScreenState();
}

class _ChemicalDetailScreenState extends State<ChemicalDetailScreen> {
  late bool _isEnglish;

  @override
  void initState() {
    super.initState();
    _isEnglish = widget.initialIsEnglish;
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.chemical;

    return LibraryScaffold(
      header: LibraryWaveHeader(
        title: _isEnglish ? c.nameEn : c.nameBn,
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
              imagePath: null,
              icon: c.categoryIcon,
              color: c.categoryColor,
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
                    label: _isEnglish ? 'Chemical Name' : 'কেমিক্যালের নাম',
                    labelColor: AppColors.green,
                    value: _isEnglish ? c.nameEn : c.nameBn,
                  ),
                ),
                const SizedBox(
                    height: 46,
                    child: VerticalDivider(width: 24, thickness: 1)),
                Expanded(
                  child: _LabeledValue(
                    icon: c.categoryIcon,
                    iconColor: c.categoryColor,
                    label: _isEnglish ? 'Category' : 'ক্যাটাগরি',
                    labelColor: c.categoryColor,
                    value: _isEnglish ? c.categoryEn : c.categoryBn,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          _ColorInfoCard(
            bgColor: const Color(0xFFEFF6FF),
            icon: Icons.settings_rounded,
            iconColor: AppColors.teal,
            titleColor: AppColors.teal,
            title: _isEnglish ? 'Used In Process' : 'যে প্রসেসে ব্যবহৃত হয়',
            child: Text(
              _isEnglish ? c.usedInProcessEn : c.usedInProcessBn,
              style: const TextStyle(fontSize: 12.5, height: 1.45),
            ),
          ),
          const SizedBox(height: 12),

          _ColorInfoCard(
            bgColor: const Color(0xFFF1F8E9),
            icon: Icons.help_outline_rounded,
            iconColor: AppColors.green,
            titleColor: AppColors.green,
            title: _isEnglish ? 'Why Used' : 'কেন ব্যবহার করা হয়',
            child: Text(
              _isEnglish ? c.whyUsedEn : c.whyUsedBn,
              style: const TextStyle(fontSize: 12.5, height: 1.45),
            ),
          ),
          const SizedBox(height: 12),

          _ColorInfoCard(
            bgColor: const Color(0xFFFFF3E0),
            icon: Icons.warning_amber_rounded,
            iconColor: AppColors.orange,
            titleColor: AppColors.orange,
            title: _isEnglish ? 'Hazard Class' : 'বিপদের শ্রেণী',
            child: Text(
              _isEnglish ? c.hazardClassEn : c.hazardClassBn,
              style: const TextStyle(
                  fontSize: 12.5, height: 1.45, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 12),

          _ColorInfoCard(
            bgColor: const Color(0xFFFCE4EC),
            icon: Icons.shield_rounded,
            iconColor: AppColors.pink,
            titleColor: AppColors.pink,
            title: _isEnglish ? 'PPE Required' : 'প্রয়োজনীয় PPE',
            child: Text(
              _isEnglish ? c.ppeEn : c.ppeBn,
              style: const TextStyle(fontSize: 12.5, height: 1.45),
            ),
          ),
          const SizedBox(height: 12),

          _ColorInfoCard(
            bgColor: const Color(0xFFFFEBEE),
            icon: Icons.report_problem_rounded,
            iconColor: Colors.redAccent,
            titleColor: Colors.redAccent,
            title: _isEnglish ? 'Precautions & Safety' : 'সতর্কতা ও সেফটি',
            child: Text(
              _isEnglish ? c.precautionsEn : c.precautionsBn,
              style: const TextStyle(fontSize: 12.5, height: 1.45),
            ),
          ),
          const SizedBox(height: 12),

          _ColorInfoCard(
            bgColor: const Color(0xFFEDE7F6),
            icon: Icons.warehouse_rounded,
            iconColor: AppColors.purple,
            titleColor: AppColors.purple,
            title: _isEnglish ? 'Storage & Handling' : 'সংরক্ষণ ও হ্যান্ডলিং',
            child: Text(
              _isEnglish ? c.storageEn : c.storageBn,
              style: const TextStyle(fontSize: 12.5, height: 1.45),
            ),
          ),
          const SizedBox(height: 16),

          // ⚠️ ডিসক্লেইমার — সবসময় নিচে দেখানো, উপেক্ষা করা যাবে না
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.04),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black12),
            ),
            child: Text(
              _isEnglish ? kChemicalDisclaimerEn : kChemicalDisclaimerBn,
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
              Text(title,
                  style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: titleColor)),
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
