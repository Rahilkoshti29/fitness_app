import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fitness_app/app_theme.dart';
import 'package:fitness_app/models.dart';
import 'package:fitness_app/db_helper.dart';
import 'package:fitness_app/shared_widgets.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  List<NutritionLog> _todayLogs = [];
  int _waterMl = 0;
  int _calorieGoal = 2000;

  String get _today {
    final d = DateTime.now();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  int get _totalCal => _todayLogs.fold(0, (s, l) => s + l.calories);
  double get _totalProtein => _todayLogs.fold(0.0, (s, l) => s + l.protein);
  double get _totalCarbs => _todayLogs.fold(0.0, (s, l) => s + l.carbs);
  double get _totalFat => _todayLogs.fold(0.0, (s, l) => s + l.fat);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final logs = await DBHelper.instance.getNutritionByDate(_today);
    final prefs = await SharedPreferences.getInstance();
    final profileStr = prefs.getString('profile');
    final water = prefs.getInt('water_${_today}') ?? 0;
    if (mounted) {
      setState(() {
        _todayLogs = logs;
        _waterMl = water;
        if (profileStr != null) {
          final p = UserProfile.fromMap(jsonDecode(profileStr));
          _calorieGoal = p.calorieGoal;
        }
      });
    }
  }

  Future<void> _addWater(int ml) async {
    final newVal = _waterMl + ml;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('water_${_today}', newVal);
    setState(() => _waterMl = newVal);
  }

  Future<void> _resetWater() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('water_${_today}', 0);
    setState(() => _waterMl = 0);
  }

  Future<void> _deleteEntry(int id) async {
    await DBHelper.instance.deleteNutrition(id);
    _load();
  }

  void _showAddMeal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _AddMealSheet(onSaved: _load),
    );
  }

  List<PieChartSectionData> _macroSections() {
    final total = _totalProtein + _totalCarbs + _totalFat;
    if (total == 0) {
      return [PieChartSectionData(value: 1, color: AppColors.cardBorder, showTitle: false, radius: 14)];
    }
    return [
      PieChartSectionData(value: _totalProtein, color: AppColors.neon, showTitle: false, radius: 14),
      PieChartSectionData(value: _totalCarbs, color: AppColors.accent, showTitle: false, radius: 14),
      PieChartSectionData(value: _totalFat, color: AppColors.warn, showTitle: false, radius: 14),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final calPct = (_totalCal / _calorieGoal).clamp(0.0, 1.0);
    final waterPct = (_waterMl / 2500).clamp(0.0, 1.0);
    final glasses = (_waterMl / 250).floor();

    return Scaffold(
      backgroundColor: AppColors.bg,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddMeal,
        backgroundColor: AppColors.warn,
        icon: const Icon(Icons.restaurant_menu_rounded, color: AppColors.bg),
        label: Text('ADD MEAL',
            style: GoogleFonts.orbitron(
                fontSize: 11, color: AppColors.bg, letterSpacing: 1)),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.warn,
          backgroundColor: AppColors.card,
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            children: [
              const NeonLabel('Daily Fuel', color: AppColors.warn),
              const SizedBox(height: 4),
              Text('NUTRITION',
                  style: GoogleFonts.orbitron(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: 2)),
              const SizedBox(height: 20),

              // Calorie overview
              GlowCard(
                glowColor: AppColors.warn,
                child: Row(children: [
                  SizedBox(
                    width: 90,
                    height: 90,
                    child: Stack(alignment: Alignment.center, children: [
                      PieChart(PieChartData(
                        startDegreeOffset: -90,
                        sectionsSpace: 0,
                        centerSpaceRadius: 28,
                        sections: _macroSections(),
                      )),
                      Text('${(calPct * 100).round()}%',
                          style: GoogleFonts.orbitron(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.warn)),
                    ]),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const NeonLabel('Calories Today', color: AppColors.warn),
                          const SizedBox(height: 6),
                          StatChip(
                              value: '$_totalCal',
                              unit: '/ $_calorieGoal kcal',
                              color: AppColors.warn),
                          const SizedBox(height: 10),
                          NeonProgressBar(value: calPct, color: AppColors.warn),
                        ]),
                  ),
                ]),
              ),
              const SizedBox(height: 12),

              // Macros row
              Row(children: [
                _macroCard('Protein', '${_totalProtein.round()}g', AppColors.neon),
                const SizedBox(width: 10),
                _macroCard('Carbs', '${_totalCarbs.round()}g', AppColors.accent),
                const SizedBox(width: 10),
                _macroCard('Fat', '${_totalFat.round()}g', AppColors.warn),
              ]),
              const SizedBox(height: 12),

              // Water tracker
              GlowCard(
                glowColor: AppColors.accent,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const NeonLabel('Water Intake', color: AppColors.accent),
                                  const SizedBox(height: 6),
                                  StatChip(
                                      value:
                                      '${(_waterMl / 1000).toStringAsFixed(1)}',
                                      unit: '/ 2.5L',
                                      color: AppColors.accent),
                                ]),
                            Column(children: [
                              GestureDetector(
                                onTap: () => _addWater(250),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.accent,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                          color:
                                          AppColors.accent.withOpacity(0.3),
                                          blurRadius: 10)
                                    ],
                                  ),
                                  child: Text('+250ml',
                                      style: GoogleFonts.orbitron(
                                          fontSize: 11,
                                          color: AppColors.bg,
                                          fontWeight: FontWeight.w700)),
                                ),
                              ),
                              const SizedBox(height: 6),
                              GestureDetector(
                                onTap: _resetWater,
                                child: Text('Reset',
                                    style: GoogleFonts.rajdhani(
                                        fontSize: 12,
                                        color: AppColors.textMuted)),
                              ),
                            ]),
                          ]),
                      const SizedBox(height: 12),
                      NeonProgressBar(value: waterPct, color: AppColors.accent),
                      const SizedBox(height: 12),
                      // Glass indicators
                      Wrap(
                        spacing: 6,
                        children: List.generate(10, (i) {
                          final filled = i < glasses;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 22,
                            height: 30,
                            decoration: BoxDecoration(
                              color: filled
                                  ? AppColors.accent
                                  : AppColors.cardBorder,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: filled
                                  ? [BoxShadow(
                                  color: AppColors.accent.withOpacity(0.4),
                                  blurRadius: 6)]
                                  : [],
                            ),
                            child: Icon(Icons.water_drop_rounded,
                                size: 14,
                                color: filled
                                    ? AppColors.bg
                                    : AppColors.textMuted),
                          );
                        }),
                      ),
                    ]),
              ),
              const SizedBox(height: 16),

              // Meal log
              const NeonLabel("Today's Meals", color: AppColors.warn),
              const SizedBox(height: 10),
              if (_todayLogs.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('No meals logged today.',
                        style: GoogleFonts.rajdhani(
                            color: AppColors.textMuted, fontSize: 15)),
                  ),
                )
              else
                ..._todayLogs.map((e) => _MealTile(log: e, onDelete: _deleteEntry)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _macroCard(String label, String value, Color color) {
    return Expanded(
      child: GlowCard(
        glowColor: color,
        padding: const EdgeInsets.all(14),
        child: Column(children: [
          Text(value,
              style: GoogleFonts.orbitron(
                  fontSize: 16, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 4),
          Text(label,
              style: GoogleFonts.rajdhani(
                  fontSize: 11,
                  color: AppColors.textMuted,
                  textBaseline: TextBaseline.alphabetic)),
        ]),
      ),
    );
  }
}

class _MealTile extends StatelessWidget {
  final NutritionLog log;
  final void Function(int) onDelete;

  const _MealTile({required this.log, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlowCard(
        glowColor: AppColors.warn,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(children: [
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    TagBadge(label: log.meal, color: AppColors.warn),
                  ]),
                  const SizedBox(height: 6),
                  Text(log.food,
                      style: GoogleFonts.orbitron(
                          fontSize: 12,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.5)),
                  const SizedBox(height: 4),
                  Text(
                      'P:${log.protein.round()}g · C:${log.carbs.round()}g · F:${log.fat.round()}g',
                      style: GoogleFonts.rajdhani(
                          fontSize: 12, color: AppColors.textMuted)),
                ]),
          ),
          Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${log.calories}',
                    style: GoogleFonts.orbitron(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.warn)),
                Text('kcal',
                    style: GoogleFonts.rajdhani(
                        fontSize: 11, color: AppColors.textMuted)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => onDelete(log.id!),
                  child: const Icon(Icons.delete_outline_rounded,
                      size: 18, color: AppColors.textMuted),
                ),
              ]),
        ]),
      ),
    );
  }
}

class _AddMealSheet extends StatefulWidget {
  final VoidCallback onSaved;
  const _AddMealSheet({required this.onSaved});

  @override
  State<_AddMealSheet> createState() => _AddMealSheetState();
}

class _AddMealSheetState extends State<_AddMealSheet> {
  String _meal = 'Breakfast';
  final _foodCtrl = TextEditingController();
  final _calCtrl = TextEditingController();
  final _proteinCtrl = TextEditingController();
  final _carbsCtrl = TextEditingController();
  final _fatCtrl = TextEditingController();
  String _error = '';

  String get _today {
    final d = DateTime.now();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  Future<void> _save() async {
    if (_foodCtrl.text.isEmpty || _calCtrl.text.isEmpty) {
      setState(() => _error = 'Food name and calories are required.');
      return;
    }
    final log = NutritionLog(
      date: _today,
      meal: _meal,
      food: _foodCtrl.text.trim(),
      calories: int.tryParse(_calCtrl.text) ?? 0,
      protein: double.tryParse(_proteinCtrl.text) ?? 0,
      carbs: double.tryParse(_carbsCtrl.text) ?? 0,
      fat: double.tryParse(_fatCtrl.text) ?? 0,
    );
    await DBHelper.instance.insertNutrition(log);
    widget.onSaved();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
                color: AppColors.cardBorder,
                borderRadius: BorderRadius.circular(99))),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('LOG MEAL',
              style: GoogleFonts.orbitron(
                  fontSize: 15,
                  color: AppColors.warn,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w700)),
          IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close_rounded, color: AppColors.textMuted)),
        ]),
        const SizedBox(height: 14),
        LabeledDropdown(
            label: 'Meal Type',
            value: _meal,
            items: const ['Breakfast', 'Lunch', 'Dinner', 'Snack'],
            onChanged: (v) => setState(() => _meal = v!)),
        const SizedBox(height: 14),
        LabeledInput(
            label: 'Food Name *',
            controller: _foodCtrl,
            hint: 'e.g. Grilled Chicken'),
        const SizedBox(height: 14),
        LabeledInput(
            label: 'Calories *',
            controller: _calCtrl,
            keyboardType: TextInputType.number,
            suffix: 'kcal'),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
              child: LabeledInput(
                  label: 'Protein',
                  controller: _proteinCtrl,
                  keyboardType: TextInputType.number,
                  suffix: 'g')),
          const SizedBox(width: 10),
          Expanded(
              child: LabeledInput(
                  label: 'Carbs',
                  controller: _carbsCtrl,
                  keyboardType: TextInputType.number,
                  suffix: 'g')),
          const SizedBox(width: 10),
          Expanded(
              child: LabeledInput(
                  label: 'Fat',
                  controller: _fatCtrl,
                  keyboardType: TextInputType.number,
                  suffix: 'g')),
        ]),
        if (_error.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(_error,
              style: GoogleFonts.rajdhani(color: AppColors.warn, fontSize: 13)),
        ],
        const SizedBox(height: 20),
        NeonButton(
            label: 'SAVE MEAL',
            onTap: _save,
            color: AppColors.warn,
            width: double.infinity),
      ]),
    );
  }
}