import 'package:flutter/material.dart';
import '../data/department.dart';
import '../data/fabric_fault_data.dart';
import '../theme/app_colors.dart';
import '../widgets/library_scaffold.dart';
import '../widgets/library_thumbnail.dart';
import '../widgets/library_wave_header.dart';

class FabricFaultDetailScreen extends StatefulWidget {
  final FaultItem fault;
  final bool initialIsEnglish;

  const FabricFaultDetailScreen({
    super.key,
    required this.fault,
    this.initialIsEnglish = true,
  });

  @override
  State<FabricFaultDetailScreen> createState() =>
      _FabricFaultDetailScreenState();
}

class _FabricFaultDetailScreenState extends State<FabricFaultDetailScreen> {
  late bool _isEnglish;
  bool _bookmarked = false;
  final PageController _pageController = PageController();
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _isEnglish = widget.initialIsEnglish;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.fault;
    final depts = f.departmentIds
        .map((id) => findDepartment(id))
        .whereType<Department>()
        .toList();
    final primaryColor = depts.isNotEmpty ? depts.first.color : AppColors.green;
    final images = f.images.isNotEmpty ? f.images : <String?>[null];

    return LibraryScaffold(
      header: LibraryWaveHeader(
        title: f.nameEn,
        isBack: true,
        titleGreen: false,
        onLeadingTap: () => Navigator.of(context).pop(),
        isEnglish: _isEnglish,
        onLanguageChanged: (v) => setState(() => _isEnglish = v),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
        children: [
          // 🖼️ ছবির ক্যারোসেল — সবসময় ১৬:৯ অনুপাতে
          AspectRatio(
            aspectRatio: 16 / 9,
            child: PageView.builder(
              controller: _pageController,
              itemCount: images.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: LibraryThumbnail(
                  imagePath: images[i],
                  icon: f.icon,
                  color: primaryColor,
                  borderRadius: 16,
                ),
              ),
            ),
          ),
          if (images.length > 1) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _page ? 18 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: i == _page ? AppColors.green : Colors.black26,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ],
          const SizedBox(height: 14),

          // 🏷️ Fault Name / Department / Status কার্ড
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                          color: AppColors.green, shape: BoxShape.circle),
                      child: const Icon(Icons.opacity_rounded,
                          color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Fault Name:',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.green),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            f.nameEn,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1A1A1A)),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          setState(() => _bookmarked = !_bookmarked),
                      icon: Icon(
                        _bookmarked
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        color: AppColors.green,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: const BoxDecoration(
                                color: AppColors.purpleLight,
                                shape: BoxShape.circle),
                            child: const Icon(Icons.factory_rounded,
                                color: AppColors.purple, size: 15),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Department:',
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.purple),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  depts.map((d) => d.nameEn).join(', '),
                                  style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Status:',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.green),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                f.solvable
                                    ? Icons.check_circle_rounded
                                    : Icons.cancel_rounded,
                                color: f.solvable
                                    ? AppColors.green
                                    : AppColors.gradeCRed,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                f.solvable ? 'Solvable' : 'Unsolvable',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: f.solvable
                                      ? AppColors.green
                                      : AppColors.gradeCRed,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 📄 Description
          _ColorCard(
            bgColor: const Color(0xFFEFF6FF),
            icon: Icons.description_rounded,
            iconColor: AppColors.teal,
            titleColor: AppColors.teal,
            title: 'Description:',
            child: Text(
              _isEnglish ? f.descriptionEn : f.descriptionBn,
              style: const TextStyle(fontSize: 12.5, height: 1.45),
            ),
          ),
          const SizedBox(height: 12),

          // ⚠️ Causes
          _ColorCard(
            bgColor: const Color(0xFFFFF3E0),
            icon: Icons.warning_rounded,
            iconColor: AppColors.orange,
            titleColor: AppColors.orange,
            title: 'Causes:',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < f.causes.length; i++) ...[
                  _CauseRow(
                    cause: f.causes[i],
                    isEnglish: _isEnglish,
                  ),
                  if (i != f.causes.length - 1) const Divider(height: 16),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 🔧 Solutions
          _ColorCard(
            bgColor: const Color(0xFFF1F8E9),
            icon: Icons.build_rounded,
            iconColor: AppColors.green,
            titleColor: AppColors.green,
            title: 'Solutions:',
            child: Column(
              children: [
                for (final s in (_isEnglish ? f.solutionsEn : f.solutionsBn))
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            color: AppColors.green, size: 17),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(s,
                              style: const TextStyle(
                                  fontSize: 11.5, height: 1.35)),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _ColorCard extends StatelessWidget {
  final Color bgColor;
  final IconData icon;
  final Color iconColor;
  final Color titleColor;
  final String title;
  final Widget child;

  const _ColorCard({
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
              Container(
                width: 30,
                height: 30,
                decoration:
                    BoxDecoration(color: iconColor, shape: BoxShape.circle),
                child: Icon(icon, color: Colors.white, size: 15),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: titleColor),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _CauseRow extends StatelessWidget {
  final FaultCause cause;
  final bool isEnglish;

  const _CauseRow({required this.cause, required this.isEnglish});

  @override
  Widget build(BuildContext context) {
    final dept = findDepartment(cause.departmentId);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 3),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
              color: dept?.color ?? AppColors.orange, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                  fontSize: 11.5, height: 1.4, color: Color(0xFF1A1A1A)),
              children: [
                TextSpan(
                  text: '${dept?.nameEn ?? ''}: ',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                TextSpan(text: isEnglish ? cause.textEn : cause.textBn),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
