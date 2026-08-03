import 'package:flutter/material.dart';
import '../data/fabric_type_data.dart';
import '../services/gemini_service.dart';
import '../theme/app_colors.dart';
import '../widgets/ai_result_card.dart';
import '../widgets/ai_search_box.dart';
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

  // 🤖 AI Support — বিল্ড-ইন তালিকায় না থাকা ফেব্রিক টাইপও Gemini AI থেকে
  // এনে দেখাবে
  bool _aiLoading = false;
  String? _aiError;
  Map<String, dynamic>? _aiFabric;

  // 🔧 গ্রিড কনফিগারেশন — এখানেই কার্ডের সাইজ/সংখ্যা নিয়ন্ত্রণ করুন
  static const int _crossAxisCount = 4;
  static const double _gridSpacing = 10;
  static const double _cardAspectRatio = 0.86;

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
      setState(() {
        _aiFabric = data;
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

  @override
  Widget build(BuildContext context) {
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
          // 🤖 AI Support সার্চ বক্স — বিল্ড-ইন তালিকায় না থাকা ফেব্রিক
          // টাইপও Gemini AI থেকে খুঁজে দেখাবে
          AiSearchBox(
            hintText: 'Ask AI: e.g. Interlock, Denim, Georgette...',
            accentColor: AppColors.purple,
            isLoading: _aiLoading,
            onSearch: _searchFabricTypeWithAi,
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
                      text: '${kFabricTypes.length} Types',
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
            itemCount: kFabricTypes.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _crossAxisCount,
              crossAxisSpacing: _gridSpacing,
              mainAxisSpacing: _gridSpacing,
              childAspectRatio: _cardAspectRatio,
            ),
            itemBuilder: (context, i) {
              final fab = kFabricTypes[i];
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
