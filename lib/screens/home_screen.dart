import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart'; // theme ফোল্ডারটি বাইরে থাকায় ../ ব্যবহার করা হয়েছে

//  screens/ ফোল্ডারের ভেতরের ফাইলগুলো সরাসরি ইমপোর্ট করা হলো
import 'four_point_screen.dart';
import 'calculator_screen.dart';
import 'roll_length_screen.dart';
import 'roll_dia_width_screen.dart';
import 'fabric_gsm_screen.dart';
import 'fabric_weight_screen.dart';
import 'shrinkage_screen.dart';
import 'stripe_converter_screen.dart';
import 'yarn_requirement_screen.dart';
import 'yarn_count_converter_screen.dart';
import 'fabric_consumption_screen.dart';
import 'body_to_rib_screen.dart';
import 'gsm_without_cutter_screen.dart';
import 'gsm_by_yarn_count_screen.dart';
import 'yarn_to_fabric_screen.dart';
import 'ai_color_finder_screen.dart';
import 'machine_library_screen.dart';
import 'fabric_fault_screen.dart';
import 'fabric_type_screen.dart';
import 'process_loss_screen.dart';
import 'average_gsm_calculate_screen.dart';
import 'ai_settings_screen.dart';
import 'twist_calculator_screen.dart';
import 'hank_count_calculator_screen.dart';
import 'draft_calculator_screen.dart';
import 'csp_calculator_screen.dart';
import 'blend_ratio_calculator_screen.dart';
import 'chemical_addon_calculator_screen.dart';
import 'chemical_dosing_calculator_screen.dart';
import 'cm_costing_calculator_screen.dart';
import 'dhu_calculator_screen.dart';
import 'dye_recipe_calculator_screen.dart';
import 'fabric_crimp_calculator_screen.dart';
import 'gsm_change_calculator_screen.dart';
import 'hourly_target_calculator_screen.dart';
import 'knitting_production_calculator_screen.dart';
import 'line_efficiency_calculator_screen.dart';
import 'liquor_ratio_calculator_screen.dart';
import 'loom_production_calculator_screen.dart';
import 'percent_calculator_screen.dart';
import 'rft_calculator_screen.dart';
import 'seam_efficiency_calculator_screen.dart';
import 'stitch_density_calculator_screen.dart';
import 'tightness_factor_calculator_screen.dart';
import 'warp_yarn_requirement_calculator_screen.dart';
import 'wet_pickup_calculator_screen.dart';
import 'aql_sampling_calculator_screen.dart';
import 'costing_sheet_screen.dart';
import 'cutting_sheet_screen.dart';
import 'marker_consumption_calculator_screen.dart';
import 'marker_efficiency_calculator_screen.dart';
import 'order_sheet_screen.dart';
import '../widgets/ai_home_banner.dart';
import '../widgets/ai_icon.dart';
import '../services/gemini_service.dart';

class _CalcItem {
  final String title;
  // 🔧 ছবি আইকনের পাথ (homeicon ফোল্ডার থেকে) — এটি থাকলে ছবি দেখানো হবে
  final String? imagePath;
  // 🔧 ছবি না থাকলে (যেমন Exit) fallback হিসেবে এই আইকন/রঙ ব্যবহার হবে
  final IconData? icon;
  final Color? color;
  final Widget Function()? builder;
  // 🔧 শুধু Exit বাটনের জন্য — builder null থাকলেও এটি সত্য হলে exit ডায়ালগ দেখাবে,
  // মিথ্যা হলে "Coming Soon" দেখাবে (নতুন ফিচার যেগুলোর স্ক্রিন এখনো তৈরি হয়নি)
  final bool isExit;
  // 🏷️ ঐচ্ছিক ছোট বিভাগের নাম (Spinning/Knitting/Dyeing ইত্যাদি) — দিলে
  // কার্ডের নিচে অতি ছোট ফন্টে দেখাবে, না দিলে কিছু দেখাবে না
  final String? department;

  const _CalcItem({
    required this.title,
    this.imagePath,
    this.icon,
    this.color,
    this.builder,
    this.isExit = false,
    this.department,
  });
}

// 🔧 হোম হেডারে AI ব্যানারের অবস্থান — এই স্পেসিং বাড়ালে/কমালে ব্যানারটা
// আরও উপরে বা নিচে সরে যাবে (ঢেউ ডিজাইনের উপরে যেকোনো জায়গায় বসাতে পারবেন)
const double _kAiBannerTopSpacing = 10;

const double _kMenuWidth = 290;
const double _kHomeBgAspect = 853 / 420;
const double _kSideBgAspect = 558 / 1825;
const double _kSideBgWaveFraction = 0.30;

// 🔧 ক্যালকুলেটর কার্ডের গ্রিড কনফিগারেশন
const int _kGridCrossAxisCount =
    3; // এক লাইনে কয়টা কার্ড থাকবে (৪ থেকে ৩ করা হলো)
const double _kGridSpacing = 13; // কার্ডগুলোর মাঝের ফাঁকা জায়গা
const double _kCardAspectRatio = 3 / 2; // কার্ড রেশিও ৩:২ (width:height = 3:2)

// 🔧 homeicon ফোল্ডারের পাথ — pubspec.yaml এ assets: এর নিচে
// "assets/homeicon/" যোগ করতে হবে (নিচে নোট দেখুন)
const String _kIconBasePath = 'assets/homeicon/';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// 🔧 বাম পাশের ছোট edge strip — বন্ধ অবস্থায় এখান থেকে সোয়াইপ করলে মেনু খুলবে
const double _kEdgeSwipeWidth = 24;

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  // 🔧 মেনু 0.0 (সম্পূর্ণ বন্ধ) থেকে 1.0 (সম্পূর্ণ খোলা) — একটাই AnimationController
  // পুরো ড্র্যাগ, ফ্লিং ও ট্যাপ-টু-টগল নিয়ন্ত্রণ করে। এতে মাঝপথে কোনো
  // widget swap হয় না, তাই gesture স্মুথ ও নির্ভরযোগ্য থাকে।
  late final AnimationController _menuController;

  bool get _menuOpen => _menuController.value >= 1.0;

  // 🤖 সাইড মেনুতে "AI Settings" এর নিচে ছোট স্ট্যাটাস দেখানোর জন্য
  bool _isAiKeyActive = false;

  @override
  void initState() {
    super.initState();
    _menuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      value: 0,
    )..addListener(() => setState(() {}));
    _refreshAiStatus();
  }

  Future<void> _refreshAiStatus() async {
    final active = await GeminiService.isActive();
    if (!mounted) return;
    setState(() => _isAiKeyActive = active);
  }

  Future<void> _openAiSettings() async {
    _closeMenu();
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AiSettingsScreen()),
    );
    _refreshAiStatus();
  }

  @override
  void dispose() {
    _menuController.dispose();
    super.dispose();
  }

  static final List<_CalcItem> _items = [
    // ========================= কুইক ক্যালকুলেটর =========================
    _CalcItem(
      title: 'Calculator',
      imagePath: '${_kIconBasePath}Calculator.webp',
      builder: () => const CalculatorScreen(),
    ),
    _CalcItem(
      title: 'Percent Calculator',
      imagePath: '${_kIconBasePath}percent_calculator.webp',
      builder: () => const PercentCalculatorScreen(),
    ),
    _CalcItem(
      title: 'Roll Length',
      imagePath: '${_kIconBasePath}Roll_Length.webp',
      builder: () => const RollLengthScreen(),
    ),
    _CalcItem(
      title: 'Roll Dia/Width',
      imagePath: '${_kIconBasePath}Roll_DIA_Width_Calculator.webp',
      builder: () => const RollDiaWidthScreen(),
    ),
    _CalcItem(
      title: 'Fabric GSM',
      imagePath: '${_kIconBasePath}Fabric_GSM.webp',
      builder: () => const FabricGsmScreen(),
    ),
    _CalcItem(
      title: 'Fabric Weight (Kg)',
      imagePath: '${_kIconBasePath}Fabric weight (kg).webp',
      builder: () => const FabricWeightScreen(),
    ),
    _CalcItem(
      title: 'Body to Rib Fabric Ratio',
      imagePath: '${_kIconBasePath}Rib_to_body_fabric_ratio.webp',
      builder: () => const BodyToRibScreen(),
    ),

    // ============================ লাইব্রেরি ============================
    _CalcItem(
      title: 'Machine Library',
      imagePath: '${_kIconBasePath}Machine_Library.webp',
      builder: () => const MachineLibraryScreen(),
    ),
    _CalcItem(
      title: 'Fabric Fault',
      imagePath: '${_kIconBasePath}Fabric_Fault.webp',
      builder: () => const FabricFaultScreen(),
    ),
    _CalcItem(
      title: 'Fabric Type',
      imagePath: '${_kIconBasePath}Fabric_Type.webp',
      builder: () => const FabricTypeScreen(),
    ),

    // ========================= Quality / Test =========================
    _CalcItem(
      title: '4 Point Inspection',
      imagePath: '${_kIconBasePath}4_point_inspection.webp',
      builder: () => const FourPointScreen(),
    ),
    _CalcItem(
      title: 'Stripe Size Converter',
      imagePath: '${_kIconBasePath}Stripe_Size converter.webp',
      builder: () => const StripeConverterScreen(),
    ),
    _CalcItem(
      title: 'Shrinkage Measurement',
      imagePath: '${_kIconBasePath}Shrinkage_measurement.webp',
      builder: () => const ShrinkageScreen(),
    ),
    _CalcItem(
      title: 'Seam Efficiency',
      imagePath: '${_kIconBasePath}seam_efficiency_calculator.webp',
      builder: () => const SeamEfficiencyCalculatorScreen(),
    ),
    _CalcItem(
      title: 'DHU Calculator',
      imagePath: '${_kIconBasePath}dhu_calculator.webp',
      builder: () => const DhuCalculatorScreen(),
    ),
    _CalcItem(
      title: 'RFT Calculator',
      imagePath: '${_kIconBasePath}rft_calculator.webp',
      builder: () => const RftCalculatorScreen(),
    ),
    _CalcItem(
      title: 'AQL Sampling',
      imagePath: '${_kIconBasePath}aql_sampling.webp',
      builder: () => const AqlSamplingCalculatorScreen(),
    ),

    // =========================== General Tools ===========================
    _CalcItem(
      title: 'Yarn Requirement',
      imagePath: '${_kIconBasePath}Yarn_Requirement.webp',
      builder: () => const YarnRequirementScreen(),
    ),
    _CalcItem(
      title: 'Yarn Count Converter',
      imagePath: '${_kIconBasePath}Yarn_count_converter.webp',
      builder: () => const YarnCountConverterScreen(),
    ),
    _CalcItem(
      title: 'Fabric Consumption',
      imagePath: '${_kIconBasePath}Fabric_consumption.webp',
      builder: () => const FabricConsumptionScreen(),
    ),
    _CalcItem(
      title: 'GSM (Without GSM Cutter)',
      imagePath: '${_kIconBasePath}GSM _without_gsm_cutter.webp',
      builder: () => const GsmWithoutCutterScreen(),
    ),
    _CalcItem(
      title: 'GSM (By Yarn Count)',
      imagePath: '${_kIconBasePath}GSM_By_yarn_count.webp',
      builder: () => const GsmByYarnCountScreen(),
    ),
    _CalcItem(
      title: 'Average GSM',
      imagePath: '${_kIconBasePath}average_gsm_calculate.webp',
      builder: () => const AverageGsmCalculateScreen(),
    ),
    _CalcItem(
      title: 'Yarn to Knit Fabric',
      imagePath: '${_kIconBasePath}Yarn_to_knit_fabric.webp',
      builder: () => const YarnToFabricScreen(),
    ),
    _CalcItem(
      title: 'Process Loss',
      imagePath: '${_kIconBasePath}Process_loss.webp',
      builder: () => const ProcessLossScreen(),
    ),
    _CalcItem(
      title: 'AI Color Finder',
      imagePath: '${_kIconBasePath}TCX_Color_Finder.webp',
      builder: () => const AiColorFinderScreen(),
    ),

    // ============================= Spinning =============================
    _CalcItem(
      title: 'Twist Calculator',
      imagePath: '${_kIconBasePath}twist_calculator.webp',
      builder: () => const TwistCalculatorScreen(),
    ),
    _CalcItem(
      title: 'Hank Count Calculator',
      imagePath: '${_kIconBasePath}hank_count_calculator.webp',
      builder: () => const HankCountCalculatorScreen(),
    ),
    _CalcItem(
      title: 'Draft Calculator',
      imagePath: '${_kIconBasePath}draft_calculator.webp',
      builder: () => const DraftCalculatorScreen(),
    ),
    _CalcItem(
      title: 'CSP Calculator',
      imagePath: '${_kIconBasePath}csp_calculator.webp',
      builder: () => const CspCalculatorScreen(),
    ),
    _CalcItem(
      title: 'Blend Ratio',
      imagePath: '${_kIconBasePath}blend_ratio_calculator.webp',
      builder: () => const BlendRatioCalculatorScreen(),
    ),

    // ============================= Knitting =============================
    _CalcItem(
      title: 'Stitch Density',
      imagePath: '${_kIconBasePath}stitch_density_calculator.webp',
      builder: () => const StitchDensityCalculatorScreen(),
    ),
    _CalcItem(
      title: 'Tightness Factor',
      imagePath: '${_kIconBasePath}tightness_factor_calculator.webp',
      builder: () => const TightnessFactorCalculatorScreen(),
    ),
    _CalcItem(
      title: 'Knitting Production',
      imagePath: '${_kIconBasePath}knitting_production_calculator.webp',
      builder: () => const KnittingProductionCalculatorScreen(),
    ),

    // ============================= Weaving =============================
    _CalcItem(
      title: 'Fabric Crimp',
      imagePath: '${_kIconBasePath}fabric_crimp_calculator.webp',
      builder: () => const FabricCrimpCalculatorScreen(),
    ),
    _CalcItem(
      title: 'Warp Yarn Requirement',
      imagePath: '${_kIconBasePath}warp_yarn_requirement_calculator.webp',
      builder: () => const WarpYarnRequirementCalculatorScreen(),
    ),
    _CalcItem(
      title: 'Loom Production',
      imagePath: '${_kIconBasePath}loom_production_calculator.webp',
      builder: () => const LoomProductionCalculatorScreen(),
    ),

    // ============================= Dyeing =============================
    _CalcItem(
      title: 'Liquor Ratio',
      imagePath: '${_kIconBasePath}liquor_ratio_calculator.webp',
      builder: () => const LiquorRatioCalculatorScreen(),
    ),
    _CalcItem(
      title: 'Dye Recipe',
      imagePath: '${_kIconBasePath}dye_recipe_calculator.webp',
      builder: () => const DyeRecipeCalculatorScreen(),
    ),
    _CalcItem(
      title: 'Chemical Dosing',
      imagePath: '${_kIconBasePath}chemical_dosing_calculator.webp',
      builder: () => const ChemicalDosingCalculatorScreen(),
    ),

    // ============================= Finishing =============================
    _CalcItem(
      title: 'Wet Pickup',
      imagePath: '${_kIconBasePath}wet_pickup_calculator.webp',
      builder: () => const WetPickupCalculatorScreen(),
    ),
    _CalcItem(
      title: 'Chemical Add-on',
      imagePath: '${_kIconBasePath}chemical_addon_calculator.webp',
      builder: () => const ChemicalAddOnCalculatorScreen(),
    ),
    _CalcItem(
      title: 'GSM Change',
      imagePath: '${_kIconBasePath}gsm_change_calculator.webp',
      builder: () => const GsmChangeCalculatorScreen(),
    ),

    // ======================= Garments / Merchandising =======================
    _CalcItem(
      title: 'Hourly Target',
      imagePath: '${_kIconBasePath}hourly_target_calculator.webp',
      builder: () => const HourlyTargetCalculatorScreen(),
    ),
    _CalcItem(
      title: 'Line Efficiency',
      imagePath: '${_kIconBasePath}line_efficiency_calculator.webp',
      builder: () => const LineEfficiencyCalculatorScreen(),
    ),
    _CalcItem(
      title: 'CM Costing',
      imagePath: '${_kIconBasePath}cm_costing_calculator.webp',
      builder: () => const CmCostingCalculatorScreen(),
    ),
    _CalcItem(
      title: 'Marker Efficiency',
      imagePath: '${_kIconBasePath}marker_efficiency.webp',
      builder: () => const MarkerEfficiencyCalculatorScreen(),
    ),
    _CalcItem(
      title: 'Marker Consumption',
      imagePath: '${_kIconBasePath}marker_consumption.webp',
      builder: () => const MarkerConsumptionCalculatorScreen(),
    ),

    // ============================ Export Sheets ============================
    _CalcItem(
      title: 'Costing Sheet',
      imagePath: '${_kIconBasePath}costing_sheet.webp',
      builder: () => const CostingSheetScreen(),
    ),
    _CalcItem(
      title: 'Cutting Sheet',
      imagePath: '${_kIconBasePath}cutting_sheet.webp',
      builder: () => const CuttingSheetScreen(),
    ),
    _CalcItem(
      title: 'Order Sheet',
      imagePath: '${_kIconBasePath}order_sheet.webp',
      builder: () => const OrderSheetScreen(),
    ),

    const _CalcItem(
      title: 'Exit',
      icon: Icons.exit_to_app_rounded,
      color: Color(0xFFC62828),
      isExit: true,
    ),
  ];

  void _openMenu() =>
      _menuController.animateTo(1.0, curve: Curves.easeOutCubic);

  void _closeMenu() =>
      _menuController.animateTo(0.0, curve: Curves.easeOutCubic);

  void _toggleMenu() => _menuOpen ? _closeMenu() : _openMenu();

  // 🔧 ড্র্যাগ চলাকালীন — সরাসরি controller.value বদলায়, কোনো setState/widget
  // swap লাগে না বলেই এক টানেই স্মুথভাবে কাজ করে।
  void _handleMenuDrag(DragUpdateDetails details) {
    final delta = details.delta.dx / _kMenuWidth;
    _menuController.value = (_menuController.value + delta).clamp(0.0, 1.0);
  }

  // 🔧 আঙুল ছাড়ার সময় — জোরে টানলে momentum (fling) দিয়ে বন্ধ/খোলা হবে,
  // আস্তে ছাড়লে অর্ধেকের বেশি/কম অনুযায়ী snap করবে। Android-এর native
  // drawer/photo swipe-এর মতোই স্বাভাবিক ফিল দেয়।
  void _handleMenuDragEnd(DragEndDetails details) {
    final velocity = (details.primaryVelocity ?? 0) / _kMenuWidth;
    if (velocity.abs() > 0.7) {
      _menuController.fling(
        velocity: velocity > 0
            ? velocity.clamp(1.5, 10.0)
            : velocity.clamp(-10.0, -1.5),
      );
    } else if (_menuController.value > 0.5) {
      _openMenu();
    } else {
      _closeMenu();
    }
  }

  void _openCalc(_CalcItem item) {
    if (item.builder == null) {
      if (item.isExit) {
        _confirmExit();
      } else {
        // 🆕 যে ফিচারগুলোর স্ক্রিন এখনো তৈরি হয়নি সেগুলোর জন্য
        _showInfo(item.title, 'This feature is coming soon.');
      }
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => item.builder!()),
    );
  }

  void _confirmExit() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Are you sure you want to exit the app?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              SystemNavigator.pop();
            },
            child: const Text('Exit', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showInfo(String title, String message, {bool scrollable = false}) {
    _closeMenu();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: scrollable
            ? SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(child: Text(message)),
              )
            : Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final headerHeight = (size.width / _kHomeBgAspect) + statusBarHeight;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light
          .copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Positioned.fill(
              child: _buildGrid(topPadding: headerHeight),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: headerHeight,
              child: _buildHeader(statusBarHeight),
            ),
            // 🔧 স্ক্রিম + সোয়াইপ ক্যাচার — এই একই widget সবসময় মাউন্টেড থাকে
            // (বন্ধ অবস্থায় বাম পাশে সরু strip, খোলা/টানার সময় পুরো স্ক্রিন)।
            // আগের কোডে আলাদা আলাদা widget mount/unmount হতো বলে মাঝপথে
            // gesture হারিয়ে যেত — এখন সবসময় একই GestureDetector থাকে বলে
            // এক টানেই স্মুথভাবে কাজ করে।
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              right: _menuController.value > 0 ? 0 : null,
              width: _menuController.value > 0 ? null : _kEdgeSwipeWidth,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _menuController.value > 0 ? _closeMenu : null,
                onHorizontalDragUpdate: _handleMenuDrag,
                onHorizontalDragEnd: _handleMenuDragEnd,
                child: Container(
                  color: Colors.black.withOpacity(0.35 * _menuController.value),
                ),
              ),
            ),
            // 🔧 মেনু প্যানেল — position সরাসরি controller.value থেকে হিসাব
            // হয়, তাই প্রতি ফ্রেমে মসৃণভাবে আপডেট হয়, কোনো fixed-duration
            // animation বা widget swap ছাড়াই।
            Positioned(
              top: 0,
              bottom: 0,
              left: -_kMenuWidth + (_kMenuWidth * _menuController.value),
              width: _kMenuWidth,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragUpdate: _handleMenuDrag,
                onHorizontalDragEnd: _handleMenuDragEnd,
                child: _buildSideMenu(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double statusBarHeight) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/home_bg.webp'),
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(10, statusBarHeight - 0, 16, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  elevation: 3,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _toggleMenu,
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(Icons.menu_rounded,
                          color: AppColors.darkGreen, size: 20),
                    ),
                  ),
                ),
                const Spacer(),
                Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  elevation: 3,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () =>
                        _showInfo('Notification', 'No new notifications yet.'),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(Icons.notifications_none_rounded,
                              color: AppColors.darkGreen, size: 20),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                                color: AppColors.lightGreen,
                                shape: BoxShape.circle),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: Image.asset(
                    'assets/icon/app_icon.png',
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '👋 Welcome',
                        style: TextStyle(
                            fontSize: 10,
                            color: Colors.white70,
                            fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'TexHelp',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.1),
                      ),
                      Text(
                        'Smart Textile Solution',
                        style: TextStyle(
                            fontSize: 9,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // 🤖 "Smart Textile Solution" টেক্সটের ঠিক নিচে, ঢেউ ডিজাইনের উপরে
            // AI Activation ব্যানার/স্ট্যাটাস — Key সেট করা না থাকলে
            // "Activate Smart AI Features" (গ্লাস ইফেক্ট) বাটন, সেট করা
            // থাকলে শুধু ছোট গ্লাস-স্টাইল "AI Active" স্ট্যাটাস দেখাবে।
            // 🔧 উপরে/নিচে সরাতে চাইলে _kAiBannerTopSpacing বদলান।
            const SizedBox(height: _kAiBannerTopSpacing),
            const AiHomeBanner(),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid({required double topPadding}) {
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(14, topPadding + 10, 14, 16),
      itemCount: _items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _kGridCrossAxisCount,
        crossAxisSpacing: _kGridSpacing,
        mainAxisSpacing: _kGridSpacing,
        childAspectRatio: _kCardAspectRatio,
      ),
      itemBuilder: (context, i) =>
          _CalcCard(item: _items[i], onTap: () => _openCalc(_items[i])),
    );
  }

  Widget _buildSideMenu() {
    final size = MediaQuery.of(context).size;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final imgDisplayHeight = _kMenuWidth / _kSideBgAspect;
    final headerHeight =
        (imgDisplayHeight * _kSideBgWaveFraction) + statusBarHeight;

    return Material(
      elevation: 12,
      color: Colors.white,
      child: SizedBox(
        height: size.height,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: headerHeight,
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/side_menu_bg.jpg'),
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(top: statusBarHeight - 2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ClipOval(
                        child: Container(
                          width: 74,
                          height: 74,
                          color: Colors.white,
                          padding: const EdgeInsets.all(5),
                          child: Image.asset(
                            'assets/icon/app_icon_round.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'TexHelp',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 21),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Smart Textile Solution',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                            fontSize: 11.5),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.22),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Version 1.0',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: headerHeight,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),
                    _menuTile(Icons.home_rounded, 'Home', _closeMenu,
                        selected: true),
                    _menuTile(
                      Icons.smart_toy_rounded,
                      'AI Settings',
                      _openAiSettings,
                      leadingWidget: const AiIcon(
                          size: 22,
                          borderRadius: BorderRadius.all(Radius.circular(6))),
                      subtitle: Text(
                        _isAiKeyActive ? '🟢 Active' : '⚪ Not set up',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: _isAiKeyActive ? Colors.green : Colors.black45,
                        ),
                      ),
                    ),
                    _menuTile(
                        Icons.info_outline_rounded,
                        'About',
                        () => _showInfo('About TexHelp', _aboutText,
                            scrollable: true)),
                    _menuTile(Icons.share_rounded, 'Share App',
                        () => _showInfo('Share App', 'Coming soon.')),
                    _menuTile(Icons.star_rounded, 'Rate App',
                        () => _showInfo('Rate App', 'Coming soon.')),
                    _menuTile(Icons.apps_rounded, 'More Apps',
                        () => _showInfo('More Apps', 'Coming soon.')),
                    _menuTile(
                        Icons.privacy_tip_rounded,
                        'Privacy Policy',
                        () => _showInfo('Privacy Policy', _privacyPolicyText,
                            scrollable: true)),
                    const Divider(height: 24, indent: 20, endIndent: 20),
                    _menuTile(Icons.exit_to_app_rounded, 'Exit', () {
                      _closeMenu();
                      _confirmExit();
                    }, color: Colors.red),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const _DotGrid(),
                          const SizedBox(width: 10),
                          Column(
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.verified_rounded,
                                      size: 13, color: AppColors.green),
                                  const SizedBox(width: 4),
                                  const Text('TexHelp v1.0',
                                      style: TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.darkGreen)),
                                ],
                              ),
                              const Text('Made for Textile Industry',
                                  style: TextStyle(
                                      fontSize: 10, color: Colors.black45)),
                            ],
                          ),
                          const SizedBox(width: 10),
                          const _DotGrid(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuTile(IconData icon, String label, VoidCallback onTap,
      {Color? color,
      bool selected = false,
      Widget? subtitle,
      Widget? leadingWidget}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color:
            selected ? AppColors.green.withOpacity(0.10) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
            child: Row(
              children: [
                leadingWidget ??
                    Icon(icon,
                        color: color ??
                            (selected ? AppColors.green : AppColors.darkGreen),
                        size: 21),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                          color: color ??
                              (selected
                                  ? AppColors.green
                                  : AppColors.darkGreen),
                        ),
                      ),
                      if (subtitle != null) subtitle,
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

const String _aboutText = '''
TexHelp – Smart Textile Solution

TexHelp is a modern and lightweight offline utility app designed to simplify daily calculations for textile quality controllers (QC), merchandisers, and textile students.

Get instant and accurate results directly on the production floor or on the go, without needing any internet connection.

Key Features:
- 4 Point Fabric Inspection – Easily calculate fabric quality grades and penalty points on the go.
- Fabric Weight (KG) Calculator – Find the accurate weight of fabric by entering GSM, Width, and Length.
- Fabric Length Calculator – Find the required length of fabric based on weight, GSM, and Width.
- And Many More Calculators – A complete suite of textile calculation tools at your fingertips, operating 100% offline.

Our Mission:
Textile formulas can be complex and time-consuming to calculate manually. TexHelp aims to automate these calculations with a single tap, ensuring precision and saving valuable time during processing.

Version: 1.0.0
Developer: Simion Basky
Support Email: simionbasky@gmail.com
''';

const String _privacyPolicyText = '''
Privacy Policy for TexHelp – Smart Textile Solution
Last updated: July 2026

1. Information We Collect
TexHelp is primarily an offline Textile Calculator app. We do not directly collect, store, or share any personal identifiable information (such as your name, email, phone number, or device location).

2. Third-Party Services and Ads
To keep our app free, we use third-party advertising services (specifically Google AdMob). These third-party vendors may collect and use certain non-personal data, such as your device's unique advertising ID, to show you relevant advertisements.

3. Offline Functionality (Complete Offline Operation)
The core calculation features of TexHelp (including 4 Point Fabric Inspection, Fabric Weight, Fabric Length calculation, and all other available calculators) run completely offline. No internet connection or online server is required for any of these calculations, and your input data remains securely stored on your local device.

4. Security
We value your trust in using our app. Since all calculations and data processing happen locally on your device, your inputs are completely private and secure.

5. Changes to This Privacy Policy
We may update our Privacy Policy from time to time. Thus, you are advised to review this page periodically for any changes. Any updates are effective immediately after being posted.

6. Contact Us
If you have any questions or suggestions about our Privacy Policy, do not hesitate to contact us at: simionbasky@gmail.com
''';

class _DotGrid extends StatelessWidget {
  const _DotGrid();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 1.5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (col) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1.5),
                child: Container(
                  width: 3,
                  height: 3,
                  decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(1)),
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}

class _CalcCard extends StatelessWidget {
  final _CalcItem item;
  final VoidCallback onTap;

  const _CalcCard({required this.item, required this.onTap});

  // 🔧 কার্ডের নিজস্ব সাইজ/স্পেসিং — এখানেই স্বাধীনভাবে ছোট-বড় করুন।
  static const double _borderRadius = 8; // স্কয়ার-ঘেঁষা, কম রাউন্ড কোণা
  static const double _cardBorderWidth = 1; // কার্ডের হালকা বর্ডার
  static const double _paddingHorizontal = 6;
  static const double _paddingVertical = 8;
  static const double _spacingAfterImage = 6; // ছবি ও নামের মাঝের ফাঁকা জায়গা
  static const double _titleFontSize = 10.5; // ছবির মতো ছোট ফন্ট
  static const double _titleLineHeight = 1.15;
  static const double _fallbackIconCircleSize =
      40; // Exit-এর জন্য fallback সার্কেল
  static const double _fallbackIconSize = 20;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_borderRadius),
        border: Border.all(
            color: Colors.black.withOpacity(0.06), width: _cardBorderWidth),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 6,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(_borderRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(_borderRadius),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: _paddingHorizontal, vertical: _paddingVertical),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                // 👇 ইমেজ আইকন (উপরের অংশ জুড়ে) — ব্লকের ভেতরেই থাকবে
                Expanded(
                  child: item.imagePath != null
                      ? Image.asset(
                          item.imagePath!,
                          fit: BoxFit.contain,
                        )
                      : Container(
                          width: _fallbackIconCircleSize,
                          height: _fallbackIconCircleSize,
                          decoration: BoxDecoration(
                            color: item.color ?? AppColors.green,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            item.icon ?? Icons.help_outline_rounded,
                            color: Colors.white,
                            size: _fallbackIconSize,
                          ),
                        ),
                ),
                const SizedBox(height: _spacingAfterImage),
                // 👇 নিচে ছোট করে নাম — ব্লকের ভেতরেই
                Text(
                  item.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: _titleFontSize,
                      color: AppColors.darkGreen,
                      height: _titleLineHeight),
                ),
                // 🏷️ ঐচ্ছিক বিভাগের নাম — অতি ছোট ফন্টে, শুধু থাকলেই দেখাবে
                if (item.department != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    item.department!,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 7.2,
                        color: Colors.black38,
                        height: 1.0),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
