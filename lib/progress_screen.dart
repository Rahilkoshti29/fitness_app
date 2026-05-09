import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fitness_app/app_theme.dart';
import 'package:fitness_app/models.dart';
import 'package:fitness_app/db_helper.dart';
import 'package:fitness_app/shared_widgets.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen>
    with SingleTickerProviderStateMixin {
  List<WorkoutLog> _logs = [];
  String _range = '7d';
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final n = _range == '7d' ? 7 : _range == '14d' ? 14 : 30;
    final logs = await DBHelper.instance.getWorkoutsLastNDays(n);
    if (mounted) setState(() => _logs = logs);
  }

  String _dateStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  int get _days => _range == '7d' ? 7 : _range == '14d' ? 14 : 30;

  List<_DayData> get _chartData {
    final List<_DayData> data = [];
    for (int i = _days - 1; i >= 0; i--) {
      final d = DateTime.now().subtract(Duration(days: i));
      final iso = _dateStr(d);
      final dayLogs = _logs.where((l) => l.date == iso).toList();
      data.add(_DayData(
        label: _days <= 7
            ? ['S', 'M', 'T', 'W', 'T', 'F', 'S'][d.weekday % 7]
            : '${d.day}',
        calories: dayLogs.fold(0, (s, l) => s + l.calories).toDouble(),
        steps: dayLogs.fold(0, (s, l) => s + l.steps).toDouble(),
        minutes: dayLogs.fold(0, (s, l) => s + l.duration).toDouble(),
        hasData: dayLogs.isNotEmpty,
      ));
    }
    return data;
  }

  int get _totalCal => _logs.fold(0, (s, l) => s + l.calories);
  int get _totalSteps => _logs.fold(0, (s, l) => s + l.steps);
  int get _totalMin => _logs.fold(0, (s, l) => s + l.duration);
  int get _activeDays {
    final set = _logs.map((l) => l.date).toSet();
    return set.length;
  }

  Map<String, int> get _workoutFreq {
    final Map<String, int> freq = {};
    for (final l in _logs) {
      freq[l.type] = (freq[l.type] ?? 0) + 1;
    }
    return Map.fromEntries(freq.entries.toList()..sort((a, b) => b.value.compareTo(a.value)));
  }

  @override
  Widget build(BuildContext context) {
    final data = _chartData;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (_, __) => [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const NeonLabel('Analytics', color: AppColors.purple),
                  const SizedBox(height: 4),
                  Text('PROGRESS',
                      style: GoogleFonts.orbitron(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: 2)),
                  const SizedBox(height: 20),

                  // Range selector
                  Row(children: ['7d', '14d', '30d'].map((r) {
                    final active = _range == r;
                    return GestureDetector(
                      onTap: () { setState(() => _range = r); _load(); },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                        decoration: BoxDecoration(
                          color: active ? AppColors.purple : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: active ? AppColors.purple : AppColors.cardBorder),
                        ),
                        child: Text(r.toUpperCase(),
                            style: GoogleFonts.orbitron(
                                fontSize: 10,
                                letterSpacing: 1,
                                fontWeight: FontWeight.w700,
                                color: active ? AppColors.bg : AppColors.textMuted)),
                      ),
                    );
                  }).toList()),
                  const SizedBox(height: 20),

                  // Summary stats grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 2.0,
                    children: [
                      _summaryCard('Calories Burned', '$_totalCal kcal', AppColors.warn, Icons.local_fire_department_rounded),
                      _summaryCard('Total Steps', '${(_totalSteps / 1000).toStringAsFixed(1)}k', AppColors.neon, Icons.directions_walk_rounded),
                      _summaryCard('Active Time', '$_totalMin min', AppColors.accent, Icons.timer_rounded),
                      _summaryCard('Active Days', '$_activeDays / $_days', AppColors.purple, Icons.calendar_today_rounded),
                    ],
                  ),
                  const SizedBox(height: 20),
                ]),
              ),
            ),
          ],
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            children: [
              // Calorie bar chart
              GlowCard(
                glowColor: AppColors.warn,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const NeonLabel('Daily Calories', color: AppColors.warn),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 160,
                    child: BarChart(BarChartData(
                      gridData: FlGridData(
                        show: true,
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: AppColors.cardBorder,
                          strokeWidth: 1,
                        ),
                        drawVerticalLine: false,
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, _) {
                              final i = v.toInt();
                              if (i >= 0 && i < data.length) {
                                return Text(data[i].label,
                                    style: GoogleFonts.rajdhani(
                                        fontSize: 10, color: AppColors.textMuted));
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                      ),
                      barGroups: data.asMap().entries.map((e) => BarChartGroupData(
                        x: e.key,
                        barRods: [BarChartRodData(
                          toY: e.value.calories,
                          color: e.value.hasData ? AppColors.warn : AppColors.cardBorder,
                          width: _days <= 7 ? 18 : 8,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        )],
                      )).toList(),
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          tooltipRoundedRadius: 8,
                          getTooltipItem: (g, gi, r, ri) => BarTooltipItem(
                            '${r.toY.round()} kcal',
                            GoogleFonts.orbitron(fontSize: 10, color: AppColors.warn),
                          ),
                        ),
                      ),
                    )),
                  ),
                ]),
              ),
              const SizedBox(height: 14),

              // Steps line chart
              GlowCard(
                glowColor: AppColors.neon,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const NeonLabel('Daily Steps', color: AppColors.neon),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 140,
                    child: LineChart(LineChartData(
                      gridData: FlGridData(
                        show: true,
                        getDrawingHorizontalLine: (_) =>
                            FlLine(color: AppColors.cardBorder, strokeWidth: 1),
                        drawVerticalLine: false,
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, _) {
                              final i = v.toInt();
                              if (i >= 0 && i < data.length && i % (data.length > 10 ? 5 : 1) == 0) {
                                return Text(data[i].label,
                                    style: GoogleFonts.rajdhani(fontSize: 10, color: AppColors.textMuted));
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: data.asMap().entries.map((e) =>
                              FlSpot(e.key.toDouble(), e.value.steps)).toList(),
                          isCurved: true,
                          color: AppColors.neon,
                          barWidth: 2.5,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (s, _, __, ___) => FlDotCirclePainter(
                              radius: 3,
                              color: AppColors.neon,
                              strokeWidth: 0,
                            ),
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppColors.neon.withOpacity(0.08),
                          ),
                        ),
                      ],
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          tooltipRoundedRadius: 8,
                          getTooltipItems: (spots) => spots.map((s) => LineTooltipItem(
                            '${s.y.round()} steps',
                            GoogleFonts.orbitron(fontSize: 10, color: AppColors.neon),
                          )).toList(),
                        ),
                      ),
                    )),
                  ),
                ]),
              ),
              const SizedBox(height: 14),

              // Active minutes line chart
              GlowCard(
                glowColor: AppColors.accent,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const NeonLabel('Active Minutes', color: AppColors.accent),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 120,
                    child: LineChart(LineChartData(
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      titlesData: const FlTitlesData(
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: data.asMap().entries.map((e) =>
                              FlSpot(e.key.toDouble(), e.value.minutes)).toList(),
                          isCurved: true,
                          color: AppColors.accent,
                          barWidth: 2,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.accent.withOpacity(0.25),
                                AppColors.accent.withOpacity(0),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )),
                  ),
                ]),
              ),
              const SizedBox(height: 14),

              // Workout frequency
              if (_workoutFreq.isNotEmpty)
                GlowCard(
                  glowColor: AppColors.purple,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const NeonLabel('Favourite Workouts', color: AppColors.purple),
                    const SizedBox(height: 14),
                    ..._workoutFreq.entries.take(5).map((e) {
                      final maxVal = _workoutFreq.values.first.toDouble();
                      final pct = e.value / maxVal;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text(e.key, style: GoogleFonts.rajdhani(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                            Text('${e.value}×', style: GoogleFonts.orbitron(fontSize: 12, color: AppColors.purple)),
                          ]),
                          const SizedBox(height: 6),
                          NeonProgressBar(value: pct, color: AppColors.purple, height: 5),
                        ]),
                      );
                    }),
                  ]),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryCard(String label, String value, Color color, IconData icon) {
    return GlowCard(
      glowColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: GoogleFonts.rajdhani(fontSize: 10, color: AppColors.textMuted, letterSpacing: 0.5)),
          Text(value, style: GoogleFonts.orbitron(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
        ])),
      ]),
    );
  }
}

class _DayData {
  final String label;
  final double calories, steps, minutes;
  final bool hasData;
  const _DayData({
    required this.label,
    required this.calories,
    required this.steps,
    required this.minutes,
    required this.hasData,
  });
}