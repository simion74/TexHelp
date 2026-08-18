import 'package:flutter/material.dart';
import '../data/fabric_type_data.dart';
import '../services/gemini_service.dart';
import '../theme/app_colors.dart';
import '../widgets/ai_icon.dart';
import '../widgets/ai_result_card.dart';
import '../widgets/library_scaffold.dart';
import '../widgets/library_thumbnail.dart';
import '../widgets/library_wave_header.dart';
import 'fabric_type_detail_screen.dart';

/// Fabric Type লিস্ট স্ক্রিন — Machine Library-এর মতোই ডিজাইন, তবে এখানে
/// কোনো ডিপার্টমেন্ট ফিল্টার নেই (ইচ্ছাকৃতভাবে বাদ দেওয়া হয়েছে)।
class FabricTypeScreen extends StatefulWidget {
  const FabricTypeScreen({super.key});

  @override
  State<FabricTypeScreen> createState() => _FabricTypeScreenState();
}

class _FabricTypeScreenState extends State<FabricTypeScreen> {
  bool _isEnglish = true;
  String _query = '';

  // 🤖 AI Support — বিল্ড-ইন তালিকায় না থাকা ফেব্রিক টাইপও Gemini AI থেকে
  // এনে দেখাবে
  bool _aiLoading = false;
  String? _aiError;
  Map<String, dynamic>? _aiFabric;

  // 🔧 গ্রিড কনফিগারেশন — এখানেই কার্ডের সাইজ/সংখ্যা নিয়ন্ত্রণ করুন
  static const int _crossAxisCount = 4;
  static const double _gridSpacing = 10;
  static const double _cardAspectRatio = 0.86;

  // 🔎 টাইপ করার সাথে সাথেই বিল্ড-ইন তালিকা ফিল্টার হবে (অফলাইনেও কাজ করে)
  List<FabricTypeItem> get _filtered {
    if (_query.isEmpty) return kFabricTypes;
    final q = _query.toLowerCase();
    return kFabricTypes
        .where((f) =>
            f.nameEn.toLowerCase().contains(q) || f.nameBn.contains(_query))
        .toList();
  }

  Future<void> _searchFabricTypeWithAi(String query) async {
    setState(() {
      _aiLoading = true;
      _aiError = null;
      _aiFabric = null;
    });

    final languageInstruction = _isEnglish
        ? 'Respond entirely in simple, clear English.'
        : 'মূল বাক্য গঠন স্বাভাবিক, সহজ বাংলায় লিখুন। তবে টেক্সটাইল/গার্মেন্টস '
            'ইন্ডাস্ট্রির প্রচলিত টেকনিক্যাল শব্দ (ফেব্রিকের নাম, প্রযুক্তিগত '
            'টার্ম) ইংরেজিতেই রাখুন — জোর করে এগুলোর বাংলা অনুবাদ করবেন না, '
            'কারণ ইন্ডাস্ট্রিতে এই শব্দগুলো ইংরেজিতেই ব্যবহৃত হয়।';

    final prompt = '''
You are a Textile Fabric expert. Provide details about the fabric type: "$query".

$languageInstruction

Respond ONLY with a JSON object in exactly this structure, no markdown, no extra text:
{
  "fabric_name": "Name of the fabric",
  "category": "Category (e.g. Knitted Fabric, Woven Fabric, Composite Fabric, Non-Woven, Openwork Fabric)",
  "description": "One or two sentences describing this fabric",
  "properties": ["Property 1", "Property 2", "Property 3"],
  "common_uses": ["Use 1", "Use 2", "Use 3"]
}
All text values inside the JSON (fabric_name, category, description,
properties, common_uses) must follow the language instruction above.
If the fabric name is unclear, make the best reasonable guess based on the
closest matching real textile fabric.
''';

    try {
      final data = await GeminiService.generateJson(prompt);
      // 🛡️ ইউজার রেসপন্স আসার আগেই স্ক্রিন থেকে বেরিয়ে গেলে (widget dispose
      // হয়ে গেলে) setState() কল করলে ক্র্যাশ হয় — তাই আগে mounted চেক।
      if (!mounted) return;
      setState(() {
        _aiFabric = data;
        _aiLoading = false;
      });
    } on AiException catch (e) {
      if (!mounted) return;
      setState(() {
        _aiError = e.message;
        _aiLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _aiError = 'তথ্য খুঁজে পাওয়া যায়নি। আবার চেষ্টা করুন।';
        _aiLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return LibraryScaffold(
      header: LibraryWaveHeader(
        title: 'Fabric Type',
        subtitle: 'Textile Fabric Reference',
        isBack: false,
        onLeadingTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
        isEnglish: _isEnglish,
        onLanguageChanged: (v) => setState(() => _isEnglish = v),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
        children: [
          // 🔎 বাম পাশে "AI Support" লেবেল + ডান পাশে সার্চ বক্স। এখানে টাইপ
          // করলে নিচের বিল্ড-ইন গ্রিড সাথে সাথে ফিল্টার হয় (অফলাইনেও কাজ
          // করে), আর Enter/AI আইকনে চাপলে Gemini AI থেকেও ডিটেইলস আনা হয়।
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.purple.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.purple.withOpacity(0.35)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AiIcon(size: 16),
                    const SizedBox(height: 2),
                    const Text(
                      'AI Support',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          height: 1.05,
                          color: AppColors.purple),
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
                    onSubmitted: _searchFabricTypeWithAi,
                    style: const TextStyle(fontSize: 12.5),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Ask AI: e.g. Interlock, Denim, Georgette...',
                      hintStyle: const TextStyle(
                          fontSize: 11, color: Colors.black38),
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
                                    strokeWidth: 2, color: AppColors.purple),
                              ),
                            )
                          : IconButton(
                              tooltip: 'Ask AI',
                              icon: const AiIcon(size: 18),
                              onPressed: () => _searchFabricTypeWithAi(_query),
                            ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 4),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_aiLoading || _aiError != null || _aiFabric != null) ...[
            const SizedBox(height: 12),
            if (_aiLoading || _aiError != null)
              AiStatusPanel(
                  isLoading: _aiLoading,
                  errorMessage: _aiError,
                  accentColor: AppColors.purple)
            else if (_aiFabric != null)
              AiInfoCard(
                title: (_aiFabric!['fabric_name'] as String?) ?? 'Fabric Info',
                tag: _aiFabric!['category'] as String?,
                accentColor: AppColors.purple,
                description: _aiFabric!['description'] as String?,
                sections: [
                  AiInfoSection(
                    heading: _isEnglish ? 'Properties' : 'বৈশিষ্ট্য',
                    icon: Icons.checklist_rounded,
                    items: ((_aiFabric!['properties'] as List?)
                            ?.map((e) => e.toString())
                            .toList()) ??
                        const [],
                  ),
                  AiInfoSection(
                    heading: _isEnglish ? 'Common Uses' : 'ব্যবহারসমূহ',
                    icon: Icons.shopping_bag_rounded,
                    iconColor: AppColors.orange,
                    items: ((_aiFabric!['common_uses'] as List?)
                            ?.map((e) => e.toString())
                            .toList()) ??
                        const [],
                  ),
                ],
              ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'All Fabric Types',
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
                      text: '${filtered.length} Types',
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
              final fab = filtered[i];
              return _FabricTypeCard(
                fabric: fab,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => FabricTypeDetailScreen(
                        fabric: fab,
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

// 🔧 ক্যাটাগরি অনুযায়ী রঙ — ছবি লোড না হলে (placeholder আইকন) ও নিচের
// ছোট ট্যাগ আইকনে এই রঙ ব্যবহৃত হয়
Color _categoryColor(String categoryEn) {
  switch (categoryEn) {
    case 'Knitted Fabric':
      return AppColors.teal;
    case 'Woven Fabric':
      return AppColors.purple;
    case 'Composite Fabric':
      return AppColors.orange;
    case 'Openwork Fabric':
      return AppColors.pink;
    default:
      return AppColors.green;
  }
}

class _FabricTypeCard extends StatelessWidget {
  final FabricTypeItem fabric;
  final VoidCallback onTap;

  const _FabricTypeCard({required this.fabric, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(fabric.categoryEn);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(7),
      elevation: 1.5,
      shadowColor: Colors.black26,
      child: InkWell(
        borderRadius: BorderRadius.circular(7),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🖼️ থাম্বনেইল — সবসময় ১৬:৯ অনুপাতে, ডিটেইল স্ক্রিনের সাথে একই ছবি
              AspectRatio(
                aspectRatio: 16 / 9,
                child: LibraryThumbnail(
                  imagePath: fabric.image,
                  icon: fabric.icon,
                  color: color,
                  borderRadius: 3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                fabric.nameEn,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkGreen,
                    height: 1.15),
              ),
              const SizedBox(height: 4),
              Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: const Icon(Icons.texture_rounded,
                    color: Colors.white, size: 9),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
