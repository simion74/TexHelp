import 'package:flutter/material.dart';

// screens/ ফোল্ডারের ভেতরের সব স্ক্রিন ইমপোর্ট — home_screen.dart থেকে সরিয়ে
// এখানে আনা হয়েছে যাতে Favorites সিলেকশন স্ক্রিনও একই লিস্ট ব্যবহার করতে পারে।
import '../screens/four_point_screen.dart';
import '../screens/calculator_screen.dart';
import '../screens/roll_length_screen.dart';
import '../screens/roll_dia_width_screen.dart';
import '../screens/fabric_gsm_screen.dart';
import '../screens/fabric_weight_screen.dart';
import '../screens/shrinkage_screen.dart';
import '../screens/twisting_measurement_screen.dart';
import '../screens/stripe_converter_screen.dart';
import '../screens/yarn_requirement_screen.dart';
import '../screens/yarn_count_converter_screen.dart';
import '../screens/fabric_consumption_screen.dart';
import '../screens/body_to_rib_screen.dart';
import '../screens/gsm_without_cutter_screen.dart';
import '../screens/gsm_by_yarn_count_screen.dart';
import '../screens/yarn_to_fabric_screen.dart';
import '../screens/machine_library_screen.dart';
import '../screens/fabric_fault_screen.dart';
import '../screens/fabric_type_screen.dart';
import '../screens/chemical_screen.dart';
import '../screens/lab_test_screen.dart';
import '../screens/process_loss_screen.dart';
import '../screens/average_gsm_calculate_screen.dart';
import '../screens/twist_calculator_screen.dart';
import '../screens/hank_count_calculator_screen.dart';
import '../screens/draft_calculator_screen.dart';
import '../screens/csp_calculator_screen.dart';
import '../screens/blend_ratio_calculator_screen.dart';
import '../screens/chemical_addon_calculator_screen.dart';
import '../screens/chemical_dosing_calculator_screen.dart';
import '../screens/cm_costing_calculator_screen.dart';
import '../screens/dhu_calculator_screen.dart';
import '../screens/dye_recipe_calculator_screen.dart';
import '../screens/fabric_crimp_calculator_screen.dart';
import '../screens/gsm_change_calculator_screen.dart';
import '../screens/hourly_target_calculator_screen.dart';
import '../screens/knitting_production_calculator_screen.dart';
import '../screens/line_efficiency_calculator_screen.dart';
import '../screens/liquor_ratio_calculator_screen.dart';
import '../screens/loom_production_calculator_screen.dart';
import '../screens/percent_calculator_screen.dart';
import '../screens/rft_calculator_screen.dart';
import '../screens/seam_efficiency_calculator_screen.dart';
import '../screens/stitch_density_calculator_screen.dart';
import '../screens/tightness_factor_calculator_screen.dart';
import '../screens/warp_yarn_requirement_calculator_screen.dart';
import '../screens/wet_pickup_calculator_screen.dart';
import '../screens/aql_sampling_calculator_screen.dart';
import '../screens/costing_sheet_screen.dart';
import '../screens/cutting_sheet_screen.dart';
import '../screens/marker_consumption_calculator_screen.dart';
import '../screens/marker_efficiency_calculator_screen.dart';
import '../screens/length_unit_converter_screen.dart';
import '../screens/small_measurement_converter_screen.dart';

// 🆕 আজকে যোগ হওয়া ৭টা নতুন ক্যালকুলেটর
import '../screens/yarn_weight_screen.dart';
import '../screens/yarn_consumption_screen.dart';
import '../screens/moisture_percent_screen.dart';
import '../screens/cutting_wastage_screen.dart';
import '../screens/sam_smv_screen.dart';
import '../screens/carton_cbm_screen.dart';
import '../screens/profit_markup_screen.dart';

/// হোম গ্রিড ও Favorites সিলেকশন স্ক্রিন — দুই জায়গাতেই ব্যবহৃত একটাই
/// আইটেম মডেল। আগে এটি home_screen.dart-এ প্রাইভেট (_CalcItem) ছিল,
/// এখন পাবলিক করে এখানে সরানো হয়েছে।
class CalcItem {
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

  const CalcItem({
    required this.title,
    this.imagePath,
    this.icon,
    this.color,
    this.builder,
    this.isExit = false,
    this.department,
  });
}

// 🔧 homeicon ফোল্ডারের পাথ
const String kIconBasePath = 'assets/homeicon/';

/// সম্পূর্ণ ফিচার লিস্ট — ডিফল্ট হোম গ্রিডের ক্রম অনুযায়ী। Favorites
/// সিলেকশন স্ক্রিন এই একই লিস্ট থেকে টাইটেল দিয়ে আইটেম খুঁজে বের করে।
/// ⚠️ প্রতিটি title অবশ্যই ইউনিক হতে হবে — Favorites সিস্টেম title-কেই
/// stable id হিসেবে ব্যবহার করে।
final List<CalcItem> calcMenuItems = [
  // ========================= কুইক ক্যালকুলেটর =========================
  CalcItem(
    title: 'Calculator',
    imagePath: '${kIconBasePath}Calculator.webp',
    builder: () => const CalculatorScreen(),
  ),
  CalcItem(
    title: 'Percent Calculator',
    imagePath: '${kIconBasePath}percent_calculator.webp',
    builder: () => const PercentCalculatorScreen(),
  ),
  CalcItem(
    title: 'Meter/Yard/Feet',
    imagePath: '${kIconBasePath}LengthUnitConverter.webp',
    builder: () => const LengthUnitConverterScreen(),
  ),
  CalcItem(
    title: 'MM/CM/Inch',
    imagePath: '${kIconBasePath}SmallMeasurement.webp',
    builder: () => const SmallMeasurementConverterScreen(),
  ),
  CalcItem(
    title: 'Roll Length',
    imagePath: '${kIconBasePath}Roll_Length.webp',
    builder: () => const RollLengthScreen(),
  ),
  CalcItem(
    title: 'Roll Dia/Width',
    imagePath: '${kIconBasePath}Roll_DIA_Width_Calculator.webp',
    builder: () => const RollDiaWidthScreen(),
  ),
  CalcItem(
    title: 'Fabric GSM',
    imagePath: '${kIconBasePath}Fabric_GSM.webp',
    builder: () => const FabricGsmScreen(),
  ),
  CalcItem(
    title: 'Fabric Weight (Kg)',
    imagePath: '${kIconBasePath}Fabric weight (kg).webp',
    builder: () => const FabricWeightScreen(),
  ),
  CalcItem(
    title: 'Body to Rib Fabric Ratio',
    imagePath: '${kIconBasePath}Rib_to_body_fabric_ratio.webp',
    builder: () => const BodyToRibScreen(),
  ),

  // ============================ লাইব্রেরি ============================
  CalcItem(
    title: 'Machine Library',
    imagePath: '${kIconBasePath}Machine_Library.webp',
    builder: () => const MachineLibraryScreen(),
  ),
  CalcItem(
    title: 'Chemical Library',
    imagePath: '${kIconBasePath}Chemicali.webp',
    builder: () => const ChemicalScreen(),
  ),
  CalcItem(
    title: 'Lab Test',
    imagePath: '${kIconBasePath}Lab_test.webp',
    builder: () => const LabTestScreen(),
  ),
  CalcItem(
    title: 'Fabric Fault',
    imagePath: '${kIconBasePath}Fabric_Fault.webp',
    builder: () => const FabricFaultScreen(),
  ),
  CalcItem(
    title: 'Fabric Type',
    imagePath: '${kIconBasePath}Fabric_Type.webp',
    builder: () => const FabricTypeScreen(),
  ),

  // ========================= Quality / Test =========================
  CalcItem(
    title: '4 Point Inspection',
    imagePath: '${kIconBasePath}4_point_inspection.webp',
    builder: () => const FourPointScreen(),
  ),
  CalcItem(
    title: 'Stripe Size Converter',
    imagePath: '${kIconBasePath}Stripe_Size converter.webp',
    builder: () => const StripeConverterScreen(),
  ),
  CalcItem(
    title: 'Shrinkage Measurement',
    imagePath: '${kIconBasePath}Shrinkage_measurement.webp',
    builder: () => const ShrinkageScreen(),
  ),
  CalcItem(
    title: 'Twisting Measurement',
    imagePath: '${kIconBasePath}twisting_measurement.webp',
    builder: () => const TwistingMeasurementScreen(),
  ),
  CalcItem(
    title: 'Seam Efficiency',
    imagePath: '${kIconBasePath}seam_efficiency_calculator.webp',
    builder: () => const SeamEfficiencyCalculatorScreen(),
  ),
  CalcItem(
    title: 'DHU Calculator',
    imagePath: '${kIconBasePath}dhu_calculator.webp',
    builder: () => const DhuCalculatorScreen(),
  ),
  CalcItem(
    title: 'RFT Calculator',
    imagePath: '${kIconBasePath}rft_calculator.webp',
    builder: () => const RftCalculatorScreen(),
  ),
  CalcItem(
    title: 'AQL Sampling',
    imagePath: '${kIconBasePath}aql_sampling.webp',
    builder: () => const AqlSamplingCalculatorScreen(),
  ),
  // 🆕 Moisture % (Lab) — Wet/Dry Weight থেকে MC%, MR% ও Conditioned Weight
  CalcItem(
    title: 'Moisture %',
    imagePath: '${kIconBasePath}moisture%.webp',
    builder: () => const MoisturePercentScreen(),
  ),

  // =========================== General Tools ===========================
  CalcItem(
    title: 'Yarn Requirement',
    imagePath: '${kIconBasePath}Yarn_Requirement.webp',
    builder: () => const YarnRequirementScreen(),
  ),
  CalcItem(
    title: 'Yarn Count Converter',
    imagePath: '${kIconBasePath}Yarn_count_converter.webp',
    builder: () => const YarnCountConverterScreen(),
  ),
  CalcItem(
    title: 'Fabric Consumption',
    imagePath: '${kIconBasePath}Fabric_consumption.webp',
    builder: () => const FabricConsumptionScreen(),
  ),
  CalcItem(
    title: 'GSM (Without GSM Cutter)',
    imagePath: '${kIconBasePath}GSM _without_gsm_cutter.webp',
    builder: () => const GsmWithoutCutterScreen(),
  ),
  CalcItem(
    title: 'GSM (By Yarn Count)',
    imagePath: '${kIconBasePath}GSM_By_yarn_count.webp',
    builder: () => const GsmByYarnCountScreen(),
  ),
  CalcItem(
    title: 'Average GSM',
    imagePath: '${kIconBasePath}average_gsm_calculate.webp',
    builder: () => const AverageGsmCalculateScreen(),
  ),
  CalcItem(
    title: 'Yarn to Knit Fabric',
    imagePath: '${kIconBasePath}Yarn_to_knit_fabric.webp',
    builder: () => const YarnToFabricScreen(),
  ),
  CalcItem(
    title: 'Process Loss',
    imagePath: '${kIconBasePath}Process_loss.webp',
    builder: () => const ProcessLossScreen(),
  ),

  // ============================= Spinning =============================
  CalcItem(
    title: 'Twist Calculator',
    imagePath: '${kIconBasePath}twist_calculator.webp',
    builder: () => const TwistCalculatorScreen(),
  ),
  CalcItem(
    title: 'Hank Count Calculator',
    imagePath: '${kIconBasePath}hank_count_calculator.webp',
    builder: () => const HankCountCalculatorScreen(),
  ),
  CalcItem(
    title: 'Draft Calculator',
    imagePath: '${kIconBasePath}draft_calculator.webp',
    builder: () => const DraftCalculatorScreen(),
  ),
  CalcItem(
    title: 'CSP Calculator',
    imagePath: '${kIconBasePath}csp_calculator.webp',
    builder: () => const CspCalculatorScreen(),
  ),
  CalcItem(
    title: 'Blend Ratio',
    imagePath: '${kIconBasePath}blend_ratio_calculator.webp',
    builder: () => const BlendRatioCalculatorScreen(),
  ),
  // 🆕 Yarn Weight (Spinning) — Count(Ne/Nm/Tex/Denier) + Length → Weight
  CalcItem(
    title: 'Yarn Weight',
    imagePath: '${kIconBasePath}yarn_weight.webp',
    builder: () => const YarnWeightScreen(),
  ),

  // ============================= Knitting =============================
  CalcItem(
    title: 'Stitch Density',
    imagePath: '${kIconBasePath}stitch_density_calculator.webp',
    builder: () => const StitchDensityCalculatorScreen(),
  ),
  CalcItem(
    title: 'Tightness Factor',
    imagePath: '${kIconBasePath}tightness_factor_calculator.webp',
    builder: () => const TightnessFactorCalculatorScreen(),
  ),
  CalcItem(
    title: 'Knitting Production',
    imagePath: '${kIconBasePath}knitting_production_calculator.webp',
    builder: () => const KnittingProductionCalculatorScreen(),
  ),
  // 🆕 Yarn Consumption (Knitting) — GSM + Width + Length + Wastage% → Total Yarn (kg)
  CalcItem(
    title: 'Yarn Consumption',
    imagePath: '${kIconBasePath}yarn_consumption.webp',
    builder: () => const YarnConsumptionScreen(),
  ),

  // ============================= Weaving =============================
  CalcItem(
    title: 'Fabric Crimp',
    imagePath: '${kIconBasePath}fabric_crimp_calculator.webp',
    builder: () => const FabricCrimpCalculatorScreen(),
  ),
  CalcItem(
    title: 'Warp Yarn Requirement',
    imagePath: '${kIconBasePath}warp_yarn_requirement_calculator.webp',
    builder: () => const WarpYarnRequirementCalculatorScreen(),
  ),
  CalcItem(
    title: 'Loom Production',
    imagePath: '${kIconBasePath}loom_production_calculator.webp',
    builder: () => const LoomProductionCalculatorScreen(),
  ),

  // ============================= Dyeing =============================
  CalcItem(
    title: 'Liquor Ratio',
    imagePath: '${kIconBasePath}liquor_ratio_calculator.webp',
    builder: () => const LiquorRatioCalculatorScreen(),
  ),
  CalcItem(
    title: 'Dye Recipe',
    imagePath: '${kIconBasePath}dye_recipe_calculator.webp',
    builder: () => const DyeRecipeCalculatorScreen(),
  ),
  CalcItem(
    title: 'Chemical Dosing',
    imagePath: '${kIconBasePath}chemical_dosing_calculator.webp',
    builder: () => const ChemicalDosingCalculatorScreen(),
  ),

  // ============================= Finishing =============================
  CalcItem(
    title: 'Wet Pickup',
    imagePath: '${kIconBasePath}wet_pickup_calculator.webp',
    builder: () => const WetPickupCalculatorScreen(),
  ),
  CalcItem(
    title: 'Chemical Add-on',
    imagePath: '${kIconBasePath}chemical_addon_calculator.webp',
    builder: () => const ChemicalAddOnCalculatorScreen(),
  ),
  CalcItem(
    title: 'GSM Change',
    imagePath: '${kIconBasePath}gsm_change_calculator.webp',
    builder: () => const GsmChangeCalculatorScreen(),
  ),

  // ============================= Cutting =============================
  // 🆕 Cutting Wastage — Fabric Issued vs Consumed → Wastage Qty & %
  CalcItem(
    title: 'Cutting Wastage',
    imagePath: '${kIconBasePath}cutting_wastage.webp',
    builder: () => const CuttingWastageScreen(),
  ),

  // ============================= Sewing =============================
  // 🆕 SAM / SMV — Observed Time + Rating + Allowance → SMV & Output/Hour
  CalcItem(
    title: 'SAM / SMV',
    imagePath: '${kIconBasePath}sam_smv.webp',
    builder: () => const SamSmvScreen(),
  ),

  // ======================= Garments / Merchandising =======================
  CalcItem(
    title: 'Hourly Target',
    imagePath: '${kIconBasePath}hourly_target_calculator.webp',
    builder: () => const HourlyTargetCalculatorScreen(),
  ),
  CalcItem(
    title: 'Line Efficiency',
    imagePath: '${kIconBasePath}line_efficiency_calculator.webp',
    builder: () => const LineEfficiencyCalculatorScreen(),
  ),
  CalcItem(
    title: 'CM Costing',
    imagePath: '${kIconBasePath}cm_costing_calculator.webp',
    builder: () => const CmCostingCalculatorScreen(),
  ),
  CalcItem(
    title: 'Marker Efficiency',
    imagePath: '${kIconBasePath}marker_efficiency.webp',
    builder: () => const MarkerEfficiencyCalculatorScreen(),
  ),
  CalcItem(
    title: 'Marker Consumption',
    imagePath: '${kIconBasePath}marker_consumption.webp',
    builder: () => const MarkerConsumptionCalculatorScreen(),
  ),

  // ============================= Costing =============================
  // 🆕 Profit / Markup — Cost & Selling Price → Profit, Margin% & Markup%
  CalcItem(
    title: 'Profit / Markup',
    imagePath: '${kIconBasePath}profit_markup.webp',
    builder: () => const ProfitMarkupScreen(),
  ),

  // ============================ Export Sheets ============================
  CalcItem(
    title: 'Costing Sheet',
    imagePath: '${kIconBasePath}costing_sheet.webp',
    builder: () => const CostingSheetScreen(),
  ),
  CalcItem(
    title: 'Cutting Sheet',
    imagePath: '${kIconBasePath}cutting_sheet.webp',
    builder: () => const CuttingSheetScreen(),
  ),

  // ============================= Packing =============================
  // 🆕 Carton / CBM — L×W×H + Cartons → CBM per Carton & Total CBM
  CalcItem(
    title: 'Carton / CBM',
    imagePath: '${kIconBasePath}carton_cbm.webp',
    builder: () => const CartonCbmScreen(),
  ),

  const CalcItem(
    title: 'Exit',
    icon: Icons.exit_to_app_rounded,
    color: Color(0xFFC62828),
    isExit: true,
  ),
];
