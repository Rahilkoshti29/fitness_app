import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fitness_app/app_theme.dart';
import 'package:fitness_app/models.dart';
import 'package:fitness_app/db_helper.dart';
import 'package:fitness_app/shared_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  UserProfile? _profile;
  List<WorkoutLog> _todayLogs = [];
  List<WorkoutLog> _weekLogs = [];

  int get _todayCalories => _todayLogs.fold(0, (s, l) => s + l.calories);
  int get _todaySteps => _todayLogs.fold(0, (s, l) => s + l.steps);
  int get _todayMinutes => _todayLogs.fold(0, (s, l) => s + l.duration);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final profileStr = prefs.getString('profile');
    final today = _dateStr(DateTime.now());

    final todayLogs = await DBHelper.instance.getWorkoutsByDate(today);
    final weekLogs = await DBHelper.instance.getWorkoutsLastNDays(7);

    if (mounted) {
      setState(() {
        if (profileStr != null) {
          _profile = UserProfile.fromMap(jsonDecode(profileStr));
        }
        _todayLogs = todayLogs;
        _weekLogs = weekLogs;
      });
    }
  }

  String _dateStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  List<BarChartGroupData> _buildBarGroups() {
    final days = List.generate(7, (i) {
      final d = DateTime.now().subtract(Duration(days: 6 - i));
      final dateStr = _dateStr(d);
      final cal = _weekLogs
          .where((l) => l.date == dateStr)
          .fold(0, (s, l) => s + l.calories);
      return cal.toDouble();
    });
    return days.asMap().entries.map((e) {
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: e.value,
            color: AppColors.neon,
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          )
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final goal = _profile?.calorieGoal ?? 2000;
    final calPct = (_todayCalories / goal).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: RefreshIndicator(
        color: AppColors.neon,
        backgroundColor: AppColors.card,
        onRefresh: _load,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Header ───────────────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_greeting(),
                                  style: GoogleFonts.rajdhani(
                                      fontSize: 14,
                                      color: AppColors.textMuted)),
                              Text(
                                (_profile?.name ?? 'Athlete').toUpperCase(),
                                style: GoogleFonts.orbitron(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.neonDim,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: AppColors.neon.withOpacity(0.3)),
                            ),
                            child: Text(
                              _formatDate(DateTime.now()),
                              style: GoogleFonts.orbitron(
                                  fontSize: 10,
                                  color: AppColors.neon,
                                  letterSpacing: 1),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // ── Calorie Ring Card ─────────────────────────────────
                      GlowCard(
                        child: Row(children: [
                          SizedBox(
                            width: 90,
                            height: 90,
                            child: Stack(alignment: Alignment.center, children: [
                              PieChart(PieChartData(
                                startDegreeOffset: -90,
                                sectionsSpace: 0,
                                centerSpaceRadius: 30,
                                sections: [
                                  PieChartSectionData(
                                    value: calPct * 100,
                                    color: AppColors.neon,
                                    radius: 14,
                                    showTitle: false,
                                  ),
                                  PieChartSectionData(
                                    value: (1 - calPct) * 100,
                                    color: AppColors.cardBorder,
                                    radius: 14,
                                    showTitle: false,
                                  ),
                                ],
                              )),
                              Text(
                                '${(calPct * 100).round()}%',
                                style: GoogleFonts.orbitron(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.neon),
                              ),
                            ]),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const NeonLabel("Today's Burn"),
                                const SizedBox(height: 6),
                                StatChip(
                                  value: _todayCalories.toString(),
                                  unit: 'kcal',
                                  color: AppColors.neon,
                                ),
                                const SizedBox(height: 10),
                                NeonProgressBar(value: calPct),
                                const SizedBox(height: 6),
                                Text(
                                  '$_todayCalories / $goal kcal goal',
                                  style: GoogleFonts.rajdhani(
                                      fontSize: 12,
                                      color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                        ]),
                      ),
                      const SizedBox(height: 14),

                      // ── 3 Stat Tiles ──────────────────────────────────────
                      Row(children: [
                        Expanded(
                            child: _statTile(
                                label: 'Steps',
                                value: _todaySteps >= 1000
                                    ? '${(_todaySteps / 1000).toStringAsFixed(1)}k'
                                    : '$_todaySteps',
                                icon: Icons.directions_walk_rounded,
                                color: AppColors.accent)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _statTile(
                                label: 'Minutes',
                                value: '$_todayMinutes',
                                icon: Icons.timer_rounded,
                                color: AppColors.purple)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _statTile(
                                label: 'Workouts',
                                value: '${_todayLogs.length}',
                                icon: Icons.fitness_center_rounded,
                                color: AppColors.warn)),
                      ]),
                      const SizedBox(height: 14),

                      // ── Weekly Bar Chart ──────────────────────────────────
                      GlowCard(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  const NeonLabel('Weekly Calories'),
                                  TagBadge(label: '7 DAYS', color: AppColors.neon),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 140,
                                child: BarChart(BarChartData(
                                  gridData: FlGridData(show: false),
                                  borderData: FlBorderData(show: false),
                                  titlesData: FlTitlesData(
                                    leftTitles: const AxisTitles(
                                        sideTitles:
                                        SideTitles(showTitles: false)),
                                    rightTitles: const AxisTitles(
                                        sideTitles:
                                        SideTitles(showTitles: false)),
                                    topTitles: const AxisTitles(
                                        sideTitles:
                                        SideTitles(showTitles: false)),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (v, _) {
                                          final days = [
                                            'S','M','T','W','T','F','S'
                                          ];
                                          final idx =
                                              DateTime.now().subtract(Duration(
                                                  days: 6 - v.toInt()))
                                                  .weekday %
                                                  7;
                                          return Text(days[idx],
                                              style: GoogleFonts.rajdhani(
                                                  fontSize: 11,
                                                  color: AppColors.textMuted));
                                        },
                                      ),
                                    ),
                                  ),
                                  barGroups: _buildBarGroups(),
                                  barTouchData: BarTouchData(
                                    touchTooltipData: BarTouchTooltipData(
                                      tooltipRoundedRadius: 8,
                                      getTooltipItem: (g, gi, r, ri) =>
                                          BarTooltipItem(
                                            '${r.toY.round()} kcal',
                                            GoogleFonts.orbitron(
                                                fontSize: 11,
                                                color: AppColors.neon),
                                          ),
                                    ),
                                  ),
                                )),
                              ),
                            ]),
                      ),
                      const SizedBox(height: 14),

                      // ── Recent Activity ───────────────────────────────────
                      const NeonLabel('Recent Activity'),
                      const SizedBox(height: 10),
                      if (_todayLogs.isEmpty && _weekLogs.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text('No workouts yet. Start logging!',
                                style: GoogleFonts.rajdhani(
                                    color: AppColors.textMuted, fontSize: 15)),
                          ),
                        )
                      else
                        ...(_todayLogs.isNotEmpty ? _todayLogs : _weekLogs)
                            .take(3)
                            .map(_buildWorkoutTile),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statTile({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return GlowCard(
      glowColor: color,
      padding: const EdgeInsets.all(14),
      child: Column(children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(value,
            style: GoogleFonts.orbitron(
                fontSize: 18, fontWeight: FontWeight.w700, color: color)),
        Text(label,
            style: GoogleFonts.rajdhani(
                fontSize: 11,
                color: AppColors.textMuted,
                letterSpacing: 0.5)),
      ]),
    );
  }

  Widget _buildWorkoutTile(WorkoutLog log) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlowCard(
        glowColor: AppColors.accent,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(children: [
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(log.type.toUpperCase(),
                      style: GoogleFonts.orbitron(
                          fontSize: 12,
                          color: AppColors.textPrimary,
                          letterSpacing: 1)),
                  const SizedBox(height: 4),
                  Text('${log.duration} min  ·  ${_formatSteps(log.steps)} steps',
                      style: GoogleFonts.rajdhani(
                          fontSize: 12, color: AppColors.textMuted)),
                ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            TagBadge(label: '${log.calories} kcal', color: AppColors.warn),
            const SizedBox(height: 6),
            Text(log.date,
                style: GoogleFonts.rajdhani(
                    fontSize: 11, color: AppColors.textMuted)),
          ]),
        ]),
      ),
    );
  }

  String _formatSteps(int s) => s >= 1000 ? '${(s / 1000).toStringAsFixed(1)}k' : '$s';

  String _formatDate(DateTime d) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${months[d.month - 1]} ${d.day}';
  }
}