import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitness_app/app_theme.dart';
import 'package:fitness_app/models.dart';
import 'package:fitness_app/db_helper.dart';
import 'package:fitness_app/shared_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  UserProfile? _profile;
  List<WorkoutLog> _logs = [];
  bool _editing = false;
  late TabController _tabCtrl;

  // Edit controllers
  late TextEditingController _nameCtrl, _ageCtrl, _weightCtrl, _heightCtrl, _goalCtrl;

  // BMI calculator
  final _bmiWeightCtrl = TextEditingController();
  final _bmiHeightCtrl = TextEditingController();
  double? _bmiResult;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _nameCtrl = TextEditingController();
    _ageCtrl = TextEditingController();
    _weightCtrl = TextEditingController();
    _heightCtrl = TextEditingController();
    _goalCtrl = TextEditingController();
    _load();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _nameCtrl.dispose(); _ageCtrl.dispose();
    _weightCtrl.dispose(); _heightCtrl.dispose(); _goalCtrl.dispose();
    _bmiWeightCtrl.dispose(); _bmiHeightCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final profileStr = prefs.getString('profile');
    final logs = await DBHelper.instance.getAllWorkouts();
    if (mounted && profileStr != null) {
      final p = UserProfile.fromMap(jsonDecode(profileStr));
      setState(() {
        _profile = p;
        _logs = logs;
        _nameCtrl.text = p.name;
        _ageCtrl.text = '${p.age}';
        _weightCtrl.text = '${p.weight}';
        _heightCtrl.text = '${p.height}';
        _goalCtrl.text = '${p.calorieGoal}';
        _bmiWeightCtrl.text = '${p.weight}';
        _bmiHeightCtrl.text = '${p.height}';
      });
    }
  }

  Future<void> _saveProfile() async {
    final p = UserProfile(
      name: _nameCtrl.text.trim(),
      age: int.tryParse(_ageCtrl.text) ?? 25,
      weight: double.tryParse(_weightCtrl.text) ?? 70,
      height: double.tryParse(_heightCtrl.text) ?? 175,
      calorieGoal: int.tryParse(_goalCtrl.text) ?? 2000,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile', jsonEncode(p.toMap()));
    setState(() { _profile = p; _editing = false; });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Profile saved!', style: GoogleFonts.rajdhani(fontSize: 14)),
        backgroundColor: AppColors.neon.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }

  void _calcBMI() {
    final w = double.tryParse(_bmiWeightCtrl.text);
    final h = double.tryParse(_bmiHeightCtrl.text);
    if (w == null || h == null || h == 0) return;
    final hm = h / 100;
    setState(() => _bmiResult = double.parse((w / (hm * hm)).toStringAsFixed(1)));
  }

  String _bmiCategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  Color _bmiColor(double bmi) {
    if (bmi < 18.5) return AppColors.accent;
    if (bmi < 25) return AppColors.neon;
    if (bmi < 30) return AppColors.warn;
    return AppColors.red;
  }

  int get _streak {
    int s = 0;
    for (int i = 0; i < 30; i++) {
      final d = DateTime.now().subtract(Duration(days: i));
      final iso = '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
      if (_logs.any((l) => l.date == iso)) s++;
      else break;
    }
    return s;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const NeonLabel('Your Account'),
                  const SizedBox(height: 4),
                  Text('PROFILE', style: GoogleFonts.orbitron(
                      fontSize: 20, fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary, letterSpacing: 2)),
                ]),
                GestureDetector(
                  onTap: () => _editing ? _saveProfile() : setState(() => _editing = true),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _editing ? AppColors.neon : AppColors.neonDim,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.neon.withOpacity(0.4)),
                    ),
                    child: Text(_editing ? 'SAVE' : 'EDIT',
                        style: GoogleFonts.orbitron(
                            fontSize: 11,
                            color: _editing ? AppColors.bg : AppColors.neon,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Tab bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: TabBar(
                controller: _tabCtrl,
                indicator: BoxDecoration(
                  color: AppColors.neon.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.neon.withOpacity(0.4)),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: AppColors.neon,
                unselectedLabelColor: AppColors.textMuted,
                dividerColor: Colors.transparent,
                labelStyle: GoogleFonts.orbitron(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1),
                tabs: const [Tab(text: 'PROFILE'), Tab(text: 'BMI CALC')],
              ),
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _buildProfileTab(),
                _buildBMITab(),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildProfileTab() {
    final p = _profile;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      children: [
        // Avatar + stats
        GlowCard(
          child: Column(children: [
            // Avatar
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.neonDim,
                border: Border.all(color: AppColors.neon, width: 2),
                boxShadow: [BoxShadow(color: AppColors.neon.withOpacity(0.25), blurRadius: 20)],
              ),
              child: Icon(Icons.person_rounded, size: 40, color: AppColors.neon),
            ),
            const SizedBox(height: 12),
            Text(
              (p?.name ?? 'Athlete').toUpperCase(),
              style: GoogleFonts.orbitron(fontSize: 18, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary, letterSpacing: 2),
            ),
            const SizedBox(height: 4),
            Text(
              '${p?.age ?? 0} yrs  ·  ${p?.weight ?? 0} kg  ·  ${p?.height ?? 0} cm',
              style: GoogleFonts.rajdhani(fontSize: 13, color: AppColors.textMuted),
            ),
            const SizedBox(height: 20),
            Container(height: 1, color: AppColors.cardBorder),
            const SizedBox(height: 16),
            // Achievement row
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _achieveTile('$_streak', 'Day Streak', AppColors.neon, Icons.local_fire_department_rounded),
              _achieveTile('${_logs.length}', 'Workouts', AppColors.accent, Icons.fitness_center_rounded),
              _achieveTile('${(_logs.fold(0, (s, l) => s + l.calories) / 1000).toStringAsFixed(1)}k', 'kcal Total', AppColors.warn, Icons.bolt_rounded),
            ]),
          ]),
        ),
        const SizedBox(height: 14),

        // Body stats
        GlowCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const NeonLabel('Body Stats'),
            const SizedBox(height: 14),
            if (_editing) ...[
              LabeledInput(label: 'Name', controller: _nameCtrl),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: LabeledInput(label: 'Age', controller: _ageCtrl, keyboardType: TextInputType.number, suffix: 'yrs')),
                const SizedBox(width: 12),
                Expanded(child: LabeledInput(label: 'Weight', controller: _weightCtrl, keyboardType: TextInputType.number, suffix: 'kg')),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: LabeledInput(label: 'Height', controller: _heightCtrl, keyboardType: TextInputType.number, suffix: 'cm')),
                const SizedBox(width: 12),
                Expanded(child: LabeledInput(label: 'Cal Goal', controller: _goalCtrl, keyboardType: TextInputType.number, suffix: 'kcal')),
              ]),
            ] else
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.5,
                children: [
                  _statBox('Weight', '${p?.weight ?? 0} kg'),
                  _statBox('Height', '${p?.height ?? 0} cm'),
                  _statBox('Age', '${p?.age ?? 0} yrs'),
                  _statBox('Cal Goal', '${p?.calorieGoal ?? 0} kcal'),
                ],
              ),
          ]),
        ),
        const SizedBox(height: 14),

        // Weekly breakdown
        GlowCard(
          glowColor: AppColors.accent,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const NeonLabel('This Week', color: AppColors.accent),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: _weekStat('Workouts', '${_logs.where((l) => _isThisWeek(l.date)).length}', AppColors.accent)),
              Expanded(child: _weekStat('Calories', '${_logs.where((l) => _isThisWeek(l.date)).fold(0, (s, l) => s + l.calories)}', AppColors.warn)),
              Expanded(child: _weekStat('Minutes', '${_logs.where((l) => _isThisWeek(l.date)).fold(0, (s, l) => s + l.duration)}', AppColors.neon)),
            ]),
          ]),
        ),
      ],
    );
  }

  bool _isThisWeek(String dateStr) {
    final d = DateTime.tryParse(dateStr);
    if (d == null) return false;
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return d.isAfter(weekStart.subtract(const Duration(days: 1)));
  }

  Widget _buildBMITab() {
    final bmiPct = _bmiResult != null
        ? ((_bmiResult! - 10) / 30).clamp(0.0, 1.0)
        : 0.0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      children: [
        GlowCard(
          glowColor: AppColors.purple,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const NeonLabel('BMI Calculator', color: AppColors.purple),
            const SizedBox(height: 4),
            Text('Body Mass Index', style: GoogleFonts.rajdhani(fontSize: 13, color: AppColors.textMuted)),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: LabeledInput(label: 'Weight', controller: _bmiWeightCtrl, keyboardType: TextInputType.number, suffix: 'kg')),
              const SizedBox(width: 12),
              Expanded(child: LabeledInput(label: 'Height', controller: _bmiHeightCtrl, keyboardType: TextInputType.number, suffix: 'cm')),
            ]),
            const SizedBox(height: 20),
            NeonButton(label: 'CALCULATE BMI', onTap: _calcBMI, color: AppColors.purple, width: double.infinity),
          ]),
        ),

        if (_bmiResult != null) ...[
          const SizedBox(height: 14),
          GlowCard(
            glowColor: _bmiColor(_bmiResult!),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('YOUR BMI', style: GoogleFonts.rajdhani(fontSize: 11, color: AppColors.textMuted, letterSpacing: 1)),
                  Text('$_bmiResult',
                      style: GoogleFonts.orbitron(fontSize: 42, fontWeight: FontWeight.w700,
                          color: _bmiColor(_bmiResult!), height: 1)),
                ]),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: _bmiColor(_bmiResult!).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _bmiColor(_bmiResult!).withOpacity(0.4)),
                  ),
                  child: Text(_bmiCategory(_bmiResult!),
                      style: GoogleFonts.orbitron(fontSize: 12, color: _bmiColor(_bmiResult!),
                          fontWeight: FontWeight.w700)),
                ),
              ]),
              const SizedBox(height: 20),

              // BMI scale bar
              Stack(children: [
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(99),
                    gradient: const LinearGradient(colors: [
                      Color(0xFF3498DB), Color(0xFF2ECC71),
                      Color(0xFFFFD700), Color(0xFFFF6B35), Color(0xFFE74C3C),
                    ]),
                  ),
                ),
                Positioned(
                  left: (bmiPct * (MediaQuery.of(context).size.width - 80)).clamp(0, MediaQuery.of(context).size.width - 80),
                  child: Container(
                    width: 4, height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [const BoxShadow(color: Colors.black54, blurRadius: 4)],
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('10', style: GoogleFonts.rajdhani(fontSize: 10, color: AppColors.textMuted)),
                Text('18.5', style: GoogleFonts.rajdhani(fontSize: 10, color: AppColors.textMuted)),
                Text('25', style: GoogleFonts.rajdhani(fontSize: 10, color: AppColors.textMuted)),
                Text('30', style: GoogleFonts.rajdhani(fontSize: 10, color: AppColors.textMuted)),
                Text('40', style: GoogleFonts.rajdhani(fontSize: 10, color: AppColors.textMuted)),
              ]),
              const SizedBox(height: 20),

              // Category breakdown
              ...[
                _bmiRow('Underweight', '< 18.5', AppColors.accent, _bmiResult! < 18.5),
                _bmiRow('Normal', '18.5 – 24.9', AppColors.neon, _bmiResult! >= 18.5 && _bmiResult! < 25),
                _bmiRow('Overweight', '25 – 29.9', AppColors.warn, _bmiResult! >= 25 && _bmiResult! < 30),
                _bmiRow('Obese', '≥ 30', AppColors.red, _bmiResult! >= 30),
              ],
            ]),
          ),
        ],

        const SizedBox(height: 14),
        GlowCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const NeonLabel('What is BMI?'),
            const SizedBox(height: 10),
            Text(
              'Body Mass Index (BMI) is a measurement of body fat based on height and weight. It\'s a screening tool, not a diagnostic measure. Always consult a healthcare provider for a full health assessment.',
              style: GoogleFonts.rajdhani(fontSize: 14, color: AppColors.textSecondary, height: 1.6),
            ),
          ]),
        ),
      ],
    );
  }

  Widget _achieveTile(String val, String label, Color color, IconData icon) {
    return Column(children: [
      Icon(icon, color: color, size: 20),
      const SizedBox(height: 4),
      Text(val, style: GoogleFonts.orbitron(fontSize: 16, fontWeight: FontWeight.w700, color: color)),
      Text(label, style: GoogleFonts.rajdhani(fontSize: 11, color: AppColors.textMuted)),
    ]);
  }

  Widget _statBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface, borderRadius: BorderRadius.circular(10),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: GoogleFonts.rajdhani(fontSize: 11, color: AppColors.textMuted, letterSpacing: 0.5)),
        Text(value, style: GoogleFonts.orbitron(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _weekStat(String label, String val, Color color) {
    return Column(children: [
      Text(val, style: GoogleFonts.orbitron(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
      Text(label, style: GoogleFonts.rajdhani(fontSize: 11, color: AppColors.textMuted)),
    ]);
  }

  Widget _bmiRow(String label, String range, Color color, bool active) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Container(
          width: 10, height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle,
              boxShadow: active ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 6)] : []),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(label,
            style: GoogleFonts.rajdhani(fontSize: 14,
                color: active ? AppColors.textPrimary : AppColors.textMuted,
                fontWeight: active ? FontWeight.w700 : FontWeight.w400))),
        Text(range, style: GoogleFonts.orbitron(fontSize: 10, color: active ? color : AppColors.textMuted)),
        if (active) ...[
          const SizedBox(width: 8),
          Icon(Icons.check_circle_rounded, size: 14, color: color),
        ],
      ]),
    );
  }
}