import 'package:flutter/material.dart';
import '../data/chemical_data.dart';
import '../theme/app_colors.dart';
import '../widgets/library_scaffold.dart';
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
          // 🏷️ কোনো ছবি/থাম্বনেইল কন্টেইনার নেই — শুধু আইকন-অ্যাভাটার
          // সহ নাম ও ক্যাটাগরির তথ্যভিত্তিক হেডার
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: c.categoryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: c.categoryColor.withOpacity(0.18)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                      color: c.categoryColor, shape: BoxShape.circle),
                  child: Icon(c.categoryIcon, color: Colors.white, size: 25),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isEnglish ? c.nameEn : c.nameBn,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkGreen,
                            height: 1.2),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: c.categoryColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _isEnglish ? c.categoryEn : c.categoryBn,
                          style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: c.categoryColor),
                        ),
                      ),
                    ],
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
