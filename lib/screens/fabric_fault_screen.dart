import 'package:flutter/material.dart';
import '../data/department.dart';
import '../data/fabric_fault_data.dart';
import '../services/gemini_service.dart';
import '../theme/app_colors.dart';
import '../widgets/ai_icon.dart';
import '../widgets/ai_result_card.dart';
import '../widgets/department_filter_chips.dart';
import '../widgets/library_scaffold.dart';
import '../widgets/library_thumbnail.dart';
import '../widgets/library_wave_header.dart';
import 'fabric_fault_detail_screen.dart';

class FabricFaultScreen extends StatefulWidget {
  const FabricFaultScreen({super.key});

  @override
  State<FabricFaultScreen> createState() => _FabricFaultScreenState();
}

class _FabricFaultScreenState extends State<FabricFaultScreen> {
  bool _isEnglish = true;
  String? _selectedDept; // null = All
  String _query = '';
  bool _solvableOnly = false;

  // 🤖 AI Support — বিল্ড-ইন লিস্টে না থাকা ফল্টও Gemini AI থেকে এনে দেখাবে
  bool _aiLoading = false;
  String? _aiError;
  Map<String, dynamic>? _aiFault;

  // 🔧 গ্রিড কনফিগারেশন
  static const int _crossAxisCount = 4;
  static const double _gridSpacing = 10;
  static const double _cardAspectRatio = 0.86;

  Future<void> _searchFaultWithAi(String query) async {
    if (query.trim().isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _aiLoading = true;
      _aiError = null;
      _aiFault = null;
    });

    final languageInstruction = _isEnglish
        ? 'Respond entirely in simple, clear English.'
        : 'মূল বাক্য গঠন স্বাভাবিক, সহজ বাংলায় লিখুন। তবে টেক্সটাইল/গার্মেন্টস '
            'ইন্ডাস্ট্রির প্রচলিত টেকনিক্যাল শব্দ (যেমন GSM, Shrinkage, Barré, '
            'Pilling, Dyeing, Finishing, ইত্যাদি প্রফেশনাল টার্ম) ইংরেজিতেই '
            'রাখুন — জোর করে এগুলোর বাংলা অনুবাদ করবেন না, কারণ ইন্ডাস্ট্রিতে '
            'এই শব্দগুলো ইংরেজিতেই ব্যবহৃত হয়।';

    final prompt = '''
You are a Textile & Garments Quality Control (QC) expert. Provide details
about the fabric/garments fault: "$query".

$languageInstruction

Respond ONLY with a JSON object in exactly this structure, no markdown, no extra text:
{
  "fault_name": "Name of the fault",
  "process_stage": "Stage where it occurs (e.g. Knitting, Weaving, Dyeing, Printing, Finishing, Garments)",
  "description": "One or two sentences explaining what this fault is",
  "root_causes": ["Cause 1", "Cause 2", "Cause 3"],
  "remedies": ["Solution 1", "Solution 2", "Solution 3"]
}
All text values inside the JSON (fault_name, process_stage, description,
root_causes, remedies) must follow the language instruction above.
If the fault name is unclear, make the best reasonable guess based on the
closest matching real textile fault.
''';

    try {
      final data = await GeminiService.generateJson(prompt);
      setState(() {
        _aiFault = data;
        _aiLoading = false;
      });
    } on AiException catch (e) {
      setState(() {
        _aiError = e.message;
        _aiLoading = false;
      });
    } catch (_) {
      setState(() {
        _aiError = 'তথ্য খুঁজে পাওয়া যায়নি। আবার চেষ্টা করুন।';
        _aiLoading = false;
      });
    }
  }

  List<FaultItem> get _filtered {
    return kFaults.where((f) {
      final matchesDept =
          _selectedDept == null || f.departmentIds.contains(_selectedDept);
      final matchesQuery = _query.isEmpty ||
          f.nameEn.toLowerCase().contains(_query.toLowerCase()) ||
          f.nameBn.contains(_query);
      final matchesSolvable = !_solvableOnly || f.solvable;
      return matchesDept && matchesQuery && matchesSolvable;
    }).toList();
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) => Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Filter',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkGreen)),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppColors.green,
                  value: _solvableOnly,
                  onChanged: (v) => setSheetState(() => _solvableOnly = v),
                  title: const Text('Show solvable faults only'),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {});
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return LibraryScaffold(
      header: LibraryWaveHeader(
        title: 'Fabric Fault',
        subtitle: 'Fabric Fault Library',
        isBack: false,
        onLeadingTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
        isEnglish: _isEnglish,
        onLanguageChanged: (v) => setState(() => _isEnglish = v),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
        children: [
          // 🤖 বাম পাশে "AI Support" লেবেল + ডান পাশে সার্চ বক্স (+ ফিল্টার বাটন)।
          // এই সার্চ বক্সেই টাইপ করলে নিচের বিল্ড-ইন গ্রিড সাথে সাথে ফিল্টার
          // হয় (অফলাইনেও কাজ করে), আর সার্চ/এন্টার চাপলে Gemini AI থেকেও
          // ডিটেইলস এনে আলাদা কার্ডে দেখানো হয় (বিল্ড-ইন তালিকায় না থাকলেও)।
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.green.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.green.withOpacity(0.35)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AiIcon(size: 16),
                    const SizedBox(height: 2),
                    const Text(
                      'AI\nSupport',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                          height: 1.05,
                          color: AppColors.green),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
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
                    onChanged: (v) => setState(() => _query = v),
                    onSubmitted: _searchFaultWithAi,
                    style: const TextStyle(fontSize: 12.5),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Search fabric fault...',
                      hintStyle: const TextStyle(
                          fontSize: 11.5, color: Colors.black38),
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: Colors.black45, size: 18),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 34,
                        minHeight: 0,
                      ),
                      suffixIcon: _aiLoading
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: AppColors.green),
                              ),
                            )
                          : IconButton(
                              tooltip: 'Ask AI',
                              icon: const AiIcon(size: 18),
                              onPressed: () => _searchFaultWithAi(_query),
                            ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 4),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: AppColors.green,
                shape: const CircleBorder(),
                elevation: 2,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: _openFilterSheet,
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child:
                        Icon(Icons.tune_rounded, color: Colors.white, size: 13),
                  ),
                ),
              ),
            ],
          ),
          if (_aiLoading || _aiError != null || _aiFault != null) ...[
            const SizedBox(height: 12),
            if (_aiLoading || _aiError != null)
              AiStatusPanel(isLoading: _aiLoading, errorMessage: _aiError)
            else if (_aiFault != null)
              AiInfoCard(
                title: (_aiFault!['fault_name'] as String?) ?? 'Fault Info',
                tag: _aiFault!['process_stage'] as String?,
                accentColor: AppColors.darkTealLight,
                description: _aiFault!['description'] as String?,
                sections: [
                  AiInfoSection(
                    heading: _isEnglish ? 'Root Causes' : 'কারণসমূহ',
                    icon: Icons.report_problem_rounded,
                    items: ((_aiFault!['root_causes'] as List?)
                            ?.map((e) => e.toString())
                            .toList()) ??
                        const [],
                  ),
                  AiInfoSection(
                    heading: _isEnglish ? 'Remedies' : 'সমাধান',
                    icon: Icons.build_circle_rounded,
                    iconColor: Colors.green,
                    items: ((_aiFault!['remedies'] as List?)
                            ?.map((e) => e.toString())
                            .toList()) ??
                        const [],
                  ),
                ],
              ),
          ],
          const SizedBox(height: 14),
          const Text(
            'Department Filter',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.black54),
          ),
          const SizedBox(height: 8),
          DepartmentFilterChips(
            selectedId: _selectedDept,
            onSelected: (id) => setState(() => _selectedDept = id),
            onlyDepartmentIds: const [
              'spinning',
              'knitting',
              'dyeing',
              'finishing',
              'garments',
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'All Fabric Faults',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkGreen),
              ),
              Text.rich(
                TextSpan(
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                  children: [
                    const TextSpan(text: 'Total: '),
                    TextSpan(
                      text: '${filtered.length} Faults',
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, color: AppColors.green),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _crossAxisCount,
              crossAxisSpacing: _gridSpacing,
              mainAxisSpacing: _gridSpacing,
              childAspectRatio: _cardAspectRatio,
            ),
            itemBuilder: (context, i) {
              final f = filtered[i];
              return _FaultCard(
                fault: f,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => FabricFaultDetailScreen(
                        fault: f,
                        initialIsEnglish: _isEnglish,
                      ),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _FaultCard extends StatelessWidget {
  final FaultItem fault;
  final VoidCallback onTap;

  const _FaultCard({
    required this.fault,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final depts = fault.departmentIds
        .map((id) => findDepartment(id))
        .whereType<Department>()
        .toList();
    final primaryColor = depts.isNotEmpty ? depts.first.color : AppColors.green;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(6),
      elevation: 1.5,
      shadowColor: Colors.black26,
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🖼️ থাম্বনেইল — সবসময় ১৬:৯ অনুপাতে
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: LibraryThumbnail(
                        imagePath:
                            fault.images.isNotEmpty ? fault.images.first : null,
                        icon: fault.icon,
                        color: primaryColor,
                        borderRadius: 3,
                      ),
                    ),
                    // ❌ Unsolvable ফল্টের জন্য লাল ক্রস ব্যাজ
                    if (!fault.solvable)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close_rounded,
                              color: Colors.white, size: 12),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                fault.nameEn,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                    height: 1.15),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final d in depts.take(3))
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                            color: d.color, shape: BoxShape.circle),
                        child: Icon(d.icon, color: Colors.white, size: 8),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
