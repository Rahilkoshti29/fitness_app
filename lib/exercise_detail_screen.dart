import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fitness_app/app_theme.dart';
import 'package:fitness_app/shared_widgets.dart';

// A catalog of exercise types with details
const _exerciseCatalog = [
  _ExerciseInfo(
    name: 'Running',
    icon: Icons.directions_run_rounded,
    color: AppColors.neon,
    calsPer30: 300,
    category: 'Cardio',
    description:
    'One of the most effective full-body cardio exercises. Burns high calories and improves cardiovascular health, endurance, and mental wellbeing.',
    muscles: ['Quads', 'Hamstrings', 'Calves', 'Glutes', 'Core'],
    tips: [
      'Land mid-foot, not heel first',
      'Keep a slight forward lean',
      'Swing arms naturally',
      'Breathe rhythmically',
    ],
  ),
  _ExerciseInfo(
    name: 'Cycling',
    icon: Icons.directions_bike_rounded,
    color: AppColors.accent,
    calsPer30: 260,
    category: 'Cardio',
    description:
    'Low-impact cardio that builds leg strength and stamina. Great for joint health while torching serious calories.',
    muscles: ['Quads', 'Hamstrings', 'Glutes', 'Calves'],
    tips: [
      'Adjust seat height for full leg extension',
      'Keep cadence 80–100 RPM',
      'Engage your core',
      'Stay hydrated',
    ],
  ),
  _ExerciseInfo(
    name: 'HIIT',
    icon: Icons.bolt_rounded,
    color: AppColors.warn,
    calsPer30: 400,
    category: 'High Intensity',
    description:
    'High-Intensity Interval Training alternates bursts of maximum effort with short recovery. Maximizes calorie burn in minimal time.',
    muscles: ['Full Body', 'Core', 'Legs', 'Arms'],
    tips: [
      'Push 90%+ effort during work intervals',
      'Recover fully between rounds',
      'Warm up thoroughly',
      'Limit to 3–4 sessions per week',
    ],
  ),
  _ExerciseInfo(
    name: 'Yoga',
    icon: Icons.self_improvement_rounded,
    color: AppColors.purple,
    calsPer30: 120,
    category: 'Flexibility',
    description:
    'Combines poses, breathing, and mindfulness to improve flexibility, balance, and mental clarity. Perfect for recovery days.',
    muscles: ['Core', 'Back', 'Hips', 'Shoulders', 'Full Body'],
    tips: [
      'Focus on breath in every pose',
      'Never force a stretch',
      'Use props as needed',
      'Practice consistently for best results',
    ],
  ),
  _ExerciseInfo(
    name: 'Swimming',
    icon: Icons.pool_rounded,
    color: AppColors.accent,
    calsPer30: 280,
    category: 'Cardio',
    description:
    'Full-body, zero-impact workout that builds strength and cardiovascular endurance while being gentle on joints.',
    muscles: ['Shoulders', 'Back', 'Core', 'Legs', 'Arms'],
    tips: [
      'Focus on technique before speed',
      'Rotate hips for freestyle efficiency',
      'Breathe every 2–3 strokes',
      'Kick from the hips',
    ],
  ),
  _ExerciseInfo(
    name: 'Weightlifting',
    icon: Icons.fitness_center_rounded,
    color: AppColors.warn,
    calsPer30: 200,
    category: 'Strength',
    description:
    'Builds lean muscle mass, boosts metabolism, and increases bone density. Essential for long-term fat loss and functional strength.',
    muscles: ['Varies by exercise', 'Core (stabilizer)'],
    tips: [
      'Prioritize form over heavy weight',
      'Progressive overload is key',
      'Rest 48h between same muscle groups',
      'Compound lifts give best results',
    ],
  ),
];

class ExerciseDetailScreen extends StatelessWidget {
  const ExerciseDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const NeonLabel('Exercise Library', color: AppColors.purple),
              const SizedBox(height: 4),
              Text('EXERCISES',
                  style: GoogleFonts.orbitron(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: 2)),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: _exerciseCatalog.length,
                  itemBuilder: (ctx, i) => _ExerciseTile(info: _exerciseCatalog[i]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExerciseTile extends StatelessWidget {
  final _ExerciseInfo info;
  const _ExerciseTile({required this.info});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlowCard(
        glowColor: info.color,
        onTap: () => _showDetail(context, info),
        child: Row(children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: info.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: info.color.withOpacity(0.3)),
            ),
            child: Icon(info.icon, color: info.color, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(info.name,
                      style: GoogleFonts.orbitron(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: 1)),
                  const SizedBox(height: 4),
                  Row(children: [
                    TagBadge(label: info.category, color: info.color),
                    const SizedBox(width: 8),
                    Text('~${info.calsPer30} kcal/30min',
                        style: GoogleFonts.rajdhani(
                            fontSize: 12, color: AppColors.textMuted)),
                  ]),
                ]),
          ),
          Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ]),
      ),
    );
  }

  void _showDetail(BuildContext context, _ExerciseInfo info) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        builder: (_, ctrl) => SingleChildScrollView(
          controller: ctrl,
          padding: const EdgeInsets.all(24),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                    child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                            color: AppColors.cardBorder,
                            borderRadius: BorderRadius.circular(99)))),
                const SizedBox(height: 20),
                Row(children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                        color: info.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: info.color.withOpacity(0.4))),
                    child: Icon(info.icon, color: info.color, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(info.name.toUpperCase(),
                        style: GoogleFonts.orbitron(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: 1.5)),
                    const SizedBox(height: 4),
                    TagBadge(label: info.category, color: info.color),
                  ]),
                ]),
                const SizedBox(height: 20),
                GlowCard(
                  glowColor: info.color,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _miniStat('${info.calsPer30}', 'kcal/30min', info.color),
                        _miniStat('${(info.calsPer30 * 2)}', 'kcal/hr', info.color),
                      ]),
                ),
                const SizedBox(height: 20),
                NeonLabel('About', color: info.color),
                const SizedBox(height: 8),
                Text(info.description,
                    style: GoogleFonts.rajdhani(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                        height: 1.6)),
                const SizedBox(height: 20),
                NeonLabel('Muscles Worked', color: info.color),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: info.muscles
                      .map((m) => TagBadge(label: m, color: info.color))
                      .toList(),
                ),
                const SizedBox(height: 20),
                NeonLabel('Pro Tips', color: info.color),
                const SizedBox(height: 10),
                ...info.tips.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          margin: const EdgeInsets.only(right: 10, top: 1),
                          decoration: BoxDecoration(
                              color: info.color.withOpacity(0.15),
                              shape: BoxShape.circle),
                          child: Center(
                            child: Text('${e.key + 1}',
                                style: GoogleFonts.orbitron(
                                    fontSize: 9,
                                    color: info.color,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ),
                        Expanded(
                          child: Text(e.value,
                              style: GoogleFonts.rajdhani(
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                  height: 1.5)),
                        ),
                      ]),
                )),
                const SizedBox(height: 20),
              ]),
        ),
      ),
    );
  }

  Widget _miniStat(String val, String lbl, Color color) {
    return Column(children: [
      Text(val,
          style: GoogleFonts.orbitron(
              fontSize: 20, fontWeight: FontWeight.w700, color: color)),
      Text(lbl,
          style:
          GoogleFonts.rajdhani(fontSize: 12, color: AppColors.textMuted)),
    ]);
  }
}

class _ExerciseInfo {
  final String name, category, description;
  final IconData icon;
  final Color color;
  final int calsPer30;
  final List<String> muscles, tips;

  const _ExerciseInfo({
    required this.name,
    required this.icon,
    required this.color,
    required this.calsPer30,
    required this.category,
    required this.description,
    required this.muscles,
    required this.tips,
  });
}