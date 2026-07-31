import 'package:flutter/material.dart';
import '../services/gemini_service.dart';
import '../theme/app_colors.dart';
import '../widgets/ad_banner.dart';
import '../widgets/ai_icon.dart';
import '../widgets/ai_result_card.dart';

/// AI Color Finder — একটাই সিমলেস কার্ড: উপরে তথ্য (টাইট স্পেসিং), তার
/// ঠিক নিচেই লেগে থাকা ফেব্রিক ল্যাব-ডিপ সোয়াচ (বাম/ডান/নিচ — তিন পাশে
/// ছোট ত্রিভুজ জিগজ্যাগ কাটা, উপরে সোজা যাতে কার্ডের সাথে মিশে থাকে),
/// সোয়াচের নিচে বিবরণ ও ফুটার — সব একই সাদা কার্ডের ভেতরে।
///
/// ডাটা প্রতিটা সার্চেই সরাসরি Gemini AI থেকে রিয়েল-টাইমে আসে — তাই এই
/// ফিচার ব্যবহার করতে ইন্টারনেট (মোবাইল ডাটা/Wi-Fi) থাকা আবশ্যক।
///
/// 🔧 স্কোপ: কালার কোড (সংখ্যা-ভিত্তিক) শুধু Pantone TCX-এ সীমাবদ্ধ —
/// ব্র্যান্ডের প্রাইভেট নাম্বার কোড সাপোর্ট করা হয় না। কিন্তু কালারের
/// "নাম" (যেমন TNF Black, Forest Green) যেকোনো টেক্সটাইল ব্র্যান্ডের
/// জন্য গ্রহণযোগ্য।
class AiColorFinderScreen extends StatefulWidget {
  const AiColorFinderScreen({super.key});

  @override
  State<AiColorFinderScreen> createState() => _AiColorFinderScreenState();
}

class _AiColorFinderScreenState extends State<AiColorFinderScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _isLoading = false;
  Map<String, dynamic>? _colorData;
  String? _errorMessage;

  // 🔧 এই স্ক্রিনের নিজস্ব প্যাডিং — শুধু এখানেই কন্ট্রোল হবে
  static const double _paddingLeft = 14;
  static const double _paddingRight = 14;
  static const double _paddingBottom = 0;
  static const double _paddingTopWithStatusBar = 2;
  static const double _paddingTopWithoutStatusBar = 10;
  static const double _headerTitleTopOffset = 25;
  static const double _searchBoxTopSpacing = 25;
  static const double _resultTopSpacing = 15;

  // 🔧 ফেব্রিক সোয়াচের কনফিগারেশন — এখানেই ছোট-বড় করুন
  static const double _swatchAspectRatio = 0.95; // সোয়াচ অংশের অনুপাত
  static const double _zigzagToothWidth = 7; // 🔧 ছোট = আরও সূক্ষ্ম জিগজ্যাগ
  static const double _zigzagToothHeight = 6;

  Color _hexToColor(String hexString) {
    final buffer = StringBuffer();
    var hex = hexString.replaceFirst('#', '').trim();
    if (hex.length != 6) hex = '4CAF50'; // ফলব্যাক (অ্যাপ থিম গ্রিন)
    buffer.write('ff');
    buffer.write(hex);
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  Future<void> _searchColor(String query) async {
    if (query.trim().isEmpty) return;
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _colorData = null;
    });

    final prompt = '''
You are a strict textile color expert. The user query can be either:
1. A COLOR CODE (numeric/alphanumeric, e.g. "18-1550", "18-1550 TCX") —
   ONLY answer this using the official Pantone TCX (Fashion, Home + Interiors)
   database. Do NOT attempt to answer buyer-private numeric codes (e.g. a
   random internal H&M/Zara/Nike numeric reference) since that data is not
   publicly known to you.
2. A COLOR NAME (words, e.g. "Forest Green", "TNF Black", "Wine Red",
   "Nike Black") — these are usually publicly published brand/marketing
   color names, so answer using your best knowledge of that named color
   for any textile/apparel brand.

User query: "$query"

Respond ONLY with a single, strictly valid JSON object — no markdown, no
extra text, no comments, no trailing commas. The "found" field must be the
literal unquoted boolean true or false (never the word "or", never a string).

If you ARE highly confident about the color, use this exact structure:
{
  "found": true,
  "color_name": "Official or best matching color name",
  "code": "Standard closest Pantone TCX code if applicable, otherwise empty string",
  "hex": "#HEXCODE",
  "rgb": "RGB(r, g, b)",
  "description": "One short sentence about this color's usage in textile, in simple English"
}

If you are NOT highly confident (e.g. it looks like a private buyer code you
cannot verify), use this exact structure instead:
{
  "found": false,
  "color_name": "",
  "code": "",
  "hex": "#CCCCCC",
  "rgb": "RGB(204, 204, 204)",
  "description": "Briefly explain in simple English why this specific code/name could not be confidently identified"
}
''';

    try {
      final data = await GeminiService.generateJson(prompt);
      setState(() {
        _colorData = data;
        _isLoading = false;
      });
    } on AiException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _errorMessage = 'কালারটি পাওয়া যায়নি। আবার চেষ্টা করুন।';
        _isLoading = false;
      });
    }
  }

  void _clear() {
    setState(() {
      _colorData = null;
      _errorMessage = null;
      _controller.clear();
    });
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/bg_frame.webp'),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                _paddingLeft,
                statusBarHeight > 0
                    ? _paddingTopWithStatusBar
                    : _paddingTopWithoutStatusBar,
                _paddingRight,
                _paddingBottom,
              ),
              child: Column(
                children: [
                  _header(context),
                  SizedBox(height: _searchBoxTopSpacing),
                  _searchBox(),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Column(
                        children: [
                          SizedBox(height: _resultTopSpacing),
                          if (_isLoading)
                            const AiStatusPanel(
                                isLoading: true, errorMessage: null)
                          else if (_errorMessage != null)
                            AiStatusPanel(
                                isLoading: false, errorMessage: _errorMessage)
                          else if (_colorData != null)
                            _resultPreview(_colorData!)
                          else
                            _placeholder(),
                          const SizedBox(height: 14),
                          _disclaimer(),
                          const SizedBox(height: 6),
                        ],
                      ),
                    ),
                  ),
                  const ClipRRect(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(10)),
                    child: AdBannerWidget(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: Colors.white,
          shape: const CircleBorder(),
          elevation: 3,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
            child: const Padding(
              padding: EdgeInsets.all(9),
              child: Icon(Icons.home_rounded,
                  color: AppColors.darkGreen, size: 18),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: _headerTitleTopOffset),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10)),
                  child: AiIcon(
                    size: 34,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 8),
                const Flexible(
                  child: Text(
                    'AI COLOR\nFINDER',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkGreen,
                        height: 1.1),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 36),
      ],
    );
  }

  Widget _searchBox() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.teal.withOpacity(0.4), width: 1.5),
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        onSubmitted: _searchColor,
        style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.darkGreen),
        decoration: InputDecoration(
          hintText: 'কালারের নাম বা TCX কোড লিখুন (যেমন: TNF Black, 18-1550 TCX)',
          hintStyle: const TextStyle(
              fontSize: 11.5,
              color: Colors.black38,
              fontWeight: FontWeight.w500),
          prefixIcon:
              const Icon(Icons.search_rounded, color: AppColors.teal, size: 20),
          suffixIcon: _controller.text.isEmpty
              ? IconButton(
                  icon: const AiIcon(size: 18),
                  onPressed: () => _searchColor(_controller.text),
                )
              : IconButton(
                  icon: const Icon(Icons.close_rounded,
                      size: 18, color: Colors.black45),
                  onPressed: _clear,
                ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(Icons.palette_outlined, size: 46, color: Colors.black26),
          SizedBox(height: 10),
          Text(
            'কালারের নাম বা Pantone TCX কোড লিখে সার্চ করুন\nSearch by color name or Pantone TCX code',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black45, fontSize: 12.5, height: 1.4),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AiIcon(size: 13),
              SizedBox(width: 4),
              Text('Powered by Gemini AI',
                  style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // 🧵 ফলাফল: একটাই সিমলেস কার্ড — উপরে তথ্য, নিচে লেগে থাকা ফেব্রিক সোয়াচ
  // ---------------------------------------------------------------------

  Widget _resultPreview(Map<String, dynamic> data) {
    final found = data['found'] as bool? ?? true;

    if (!found) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Column(
          children: [
            const Icon(Icons.search_off_rounded,
                size: 46, color: Colors.black26),
            const SizedBox(height: 10),
            Text(
              (data['description'] as String?)?.isNotEmpty == true
                  ? data['description'] as String
                  : 'এই কোড/নামটি নির্দিষ্টভাবে শনাক্ত করা যায়নি। বানান আবার '
                      'চেক করুন অথবা সরাসরি Pantone TCX কোড ব্যবহার করে দেখুন।',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.black54, fontSize: 12.5, height: 1.4),
            ),
          ],
        ),
      );
    }

    final hexCode = (data['hex'] as String?) ?? '#4CAF50';
    final colorName = (data['color_name'] as String?) ?? 'Unknown Color';
    final code = (data['code'] as String?) ?? '—';
    final rgb = (data['rgb'] as String?) ?? '—';
    final description = (data['description'] as String?) ?? '';
    final swatch = _hexToColor(hexCode);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🏷️ উপরের তথ্য অংশ — টাইট লাইন স্পেসিং
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(colorName,
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkGreen)),
                const SizedBox(height: 4),
                _detailRow('Color Name', colorName),
                _detailRow('Code / Ref', code),
                _detailRow('Hex', hexCode),
                _detailRow('RGB', rgb),
              ],
            ),
          ),
          // 🧵 ফেব্রিক ল্যাব-ডিপ সোয়াচ — উপরে সোজা (কার্ডের সাথে মিশে থাকার
          // জন্য), বাম/ডান/নিচ — তিন পাশে ছোট ত্রিভুজ জিগজ্যাগ কাটা
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: AspectRatio(
              aspectRatio: _swatchAspectRatio,
              child: ClipPath(
                clipper: const _ZigzagSidesBottomClipper(
                  toothWidth: _zigzagToothWidth,
                  toothHeight: _zigzagToothHeight,
                ),
                child: ColoredBox(
                  color: swatch,
                  child: CustomPaint(
                    painter: const _FabricTexturePainter(),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ),
          ),
          // 📝 সোয়াচের নিচে বিবরণ ও ফুটার — একই কার্ডের ভেতরে
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (description.isNotEmpty)
                  Text(description,
                      style: const TextStyle(
                          fontSize: 12.5, color: Colors.black87, height: 1.4)),
                const SizedBox(height: 10),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AiIcon(size: 13),
                    SizedBox(width: 4),
                    Text('Powered by Gemini AI',
                        style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _disclaimer() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 6),
      child: Text(
        'Disclaimer: This feature uses Google Gemini AI to provide a textile color reference and search aid. Results are AI-generated and may occasionally be inaccurate. Pantone® and TCX are trademarks of Pantone LLC. TexHelp is an independent utility application and is not affiliated with, authorized by, sponsored by, or endorsed by Pantone LLC or Google. Color appearance may vary depending on device display and should not be used as a production color standard.',
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: 8,
            color: Colors.black38,
            height: 1.35,
            fontWeight: FontWeight.w400),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text('$label:',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkGreen)),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// 🧵 জিগজ্যাগ ক্লিপার — বাম/ডান/নিচ তিন পাশে ছোট ত্রিভুজ কাটা, উপরে সোজা
// (যাতে সোয়াচটা উপরের তথ্য অংশের সাথে সিমলেসভাবে মিশে থাকে)
// ---------------------------------------------------------------------
class _ZigzagSidesBottomClipper extends CustomClipper<Path> {
  final double toothWidth;
  final double toothHeight;

  const _ZigzagSidesBottomClipper({
    required this.toothWidth,
    required this.toothHeight,
  });

  @override
  Path getClip(Size size) {
    final path = Path()..moveTo(0, 0);
    // উপরের প্রান্ত — সম্পূর্ণ সোজা
    path.lineTo(size.width, 0);

    // ডানপাশের জিগজ্যাগ (উপর থেকে নিচে)
    double y = 0;
    bool out = true;
    while (y < size.height) {
      final nextY = (y + toothHeight).clamp(0.0, size.height);
      final x = out ? size.width - toothWidth : size.width;
      path.lineTo(x, (y + nextY) / 2);
      path.lineTo(size.width, nextY);
      y = nextY;
      out = !out;
    }

    // নিচের জিগজ্যাগ (ডান থেকে বামে)
    double x = size.width;
    out = true;
    while (x > 0) {
      final nextX = (x - toothWidth).clamp(0.0, size.width);
      final yPos = out ? size.height - toothHeight : size.height;
      path.lineTo((x + nextX) / 2, yPos);
      path.lineTo(nextX, size.height);
      x = nextX;
      out = !out;
    }

    // বামপাশের জিগজ্যাগ (নিচ থেকে উপরে)
    y = size.height;
    out = true;
    while (y > 0) {
      final nextY = (y - toothHeight).clamp(0.0, size.height);
      final xPos = out ? toothWidth : 0.0;
      path.lineTo(xPos, (y + nextY) / 2);
      path.lineTo(0, nextY);
      y = nextY;
      out = !out;
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// ---------------------------------------------------------------------
// 🧵 অতি হালকা বুনন-টেক্সচার — প্রায় ফ্ল্যাট, শুধু সামান্য কাপড়ের অনুভূতি
// ---------------------------------------------------------------------
class _FabricTexturePainter extends CustomPainter {
  const _FabricTexturePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paintLight = Paint()
      ..color = Colors.white.withOpacity(0.035)
      ..strokeWidth = 1;
    final paintDark = Paint()
      ..color = Colors.black.withOpacity(0.035)
      ..strokeWidth = 1;

    const gap = 5.0;
    for (double x = -size.height; x < size.width; x += gap) {
      canvas.drawLine(
          Offset(x, 0), Offset(x + size.height, size.height), paintLight);
    }
    for (double x = 0; x < size.width + size.height; x += gap) {
      canvas.drawLine(
          Offset(x, 0), Offset(x - size.height, size.height), paintDark);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
