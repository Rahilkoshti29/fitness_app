import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fitness_app/app_theme.dart';
import 'package:fitness_app/models.dart';
import 'package:fitness_app/db_helper.dart';
import 'package:fitness_app/shared_widgets.dart';

const _workoutTypes = [
  'Running', 'Cycling', 'HIIT', 'Yoga', 'Swimming',
  'Walking', 'Weightlifting', 'Pilates', 'Boxing', 'CrossFit',
];

class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  List<WorkoutLog> _logs = [];
  String _filter = 'All';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final logs = await DBHelper.instance.getAllWorkouts();
    if (mounted) setState(() => _logs = logs);
  }

  Future<void> _delete(int id) async {
    await DBHelper.instance.deleteWorkout(id);
    _load();
  }

  void _showLogSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _LogWorkoutSheet(onSaved: _load),
    );
  }

  List<WorkoutLog> get _filtered =>
      _filter == 'All' ? _logs : _logs.where((l) => l.type == _filter).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showLogSheet,
        backgroundColor: AppColors.accent,
        icon: const Icon(Icons.add, color: AppColors.bg),
        label: Text('LOG WORKOUT',
            style: GoogleFonts.orbitron(
                fontSize: 11, color: AppColors.bg, letterSpacing: 1)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const NeonLabel('Training Log', color: AppColors.accent),
              const SizedBox(height: 4),
              Text('WORKOUTS',
                  style: GoogleFonts.orbitron(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: 2)),
              const SizedBox(height: 20),

              // Filter chips
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: ['All', ..._workoutTypes.take(6)].map((t) {
                    final active = _filter == t;
                    return GestureDetector(
                      onTap: () => setState(() => _filter = t),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: active ? AppColors.accent : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: active
                                  ? AppColors.accent
                                  : AppColors.cardBorder),
                        ),
                        child: Text(t,
                            style: GoogleFonts.rajdhani(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: active
                                    ? AppColors.bg
                                    : AppColors.textMuted)),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // Log list
              Expanded(
                child: _filtered.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.fitness_center_rounded,
                          size: 48, color: AppColors.cardBorder),
                      const SizedBox(height: 12),
                      Text('No workouts found',
                          style: GoogleFonts.rajdhani(
                              fontSize: 15, color: AppColors.textMuted)),
                    ],
                  ),
                )
                    : RefreshIndicator(
                  color: AppColors.neon,
                  backgroundColor: AppColors.card,
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 100),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) =>
                        _WorkoutCard(log: _filtered[i], onDelete: _delete),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Workout Card ──────────────────────────────────────────────────────────────
class _WorkoutCard extends StatelessWidget {
  final WorkoutLog log;
  final void Function(int) onDelete;

  const _WorkoutCard({required this.log, required this.onDelete});

  Color get _typeColor {
    const map = {
      'Running': AppColors.neon,
      'Cycling': AppColors.accent,
      'HIIT': AppColors.warn,
      'Yoga': AppColors.purple,
      'Swimming': AppColors.accent,
      'Weightlifting': AppColors.warn,
    };
    return map[log.type] ?? AppColors.neon;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlowCard(
        glowColor: _typeColor,
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            TagBadge(label: log.type, color: _typeColor),
            const SizedBox(width: 8),
            Text(log.date,
                style: GoogleFonts.rajdhani(
                    fontSize: 11, color: AppColors.textMuted)),
            const Spacer(),
            GestureDetector(
              onTap: () => onDelete(log.id!),
              child: const Icon(Icons.delete_outline_rounded,
                  size: 18, color: AppColors.textMuted),
            ),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            _statCol('${log.calories}', 'kcal', AppColors.warn),
            const SizedBox(width: 24),
            _statCol('${log.duration}', 'min', AppColors.accent),
            if (log.steps > 0) ...[
              const SizedBox(width: 24),
              _statCol(
                log.steps >= 1000
                    ? '${(log.steps / 1000).toStringAsFixed(1)}k'
                    : '${log.steps}',
                'steps',
                AppColors.neon,
              ),
            ],
          ]),
          if (log.notes.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(log.notes,
                style: GoogleFonts.rajdhani(
                    fontSize: 13, color: AppColors.textSecondary)),
          ],
        ]),
      ),
    );
  }

  Widget _statCol(String value, String unit, Color color) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value,
          style: GoogleFonts.orbitron(
              fontSize: 18, fontWeight: FontWeight.w700, color: color)),
      Text(unit,
          style: GoogleFonts.rajdhani(fontSize: 11, color: AppColors.textMuted)),
    ]);
  }
}

// ── Log Workout Bottom Sheet ───────────────────────────────────────────────────
class _LogWorkoutSheet extends StatefulWidget {
  final VoidCallback onSaved;
  const _LogWorkoutSheet({required this.onSaved});

  @override
  State<_LogWorkoutSheet> createState() => _LogWorkoutSheetState();
}

class _LogWorkoutSheetState extends State<_LogWorkoutSheet> {
  String _type = 'Running';
  final _durationCtrl = TextEditingController();
  final _caloriesCtrl = TextEditingController();
  final _stepsCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _saving = false;
  String _error = '';

  String _dateStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _save() async {
    if (_durationCtrl.text.isEmpty || _caloriesCtrl.text.isEmpty) {
      setState(() => _error = 'Duration and Calories are required.');
      return;
    }
    setState(() => _saving = true);
    final log = WorkoutLog(
      date: _dateStr(DateTime.now()),
      type: _type,
      duration: int.tryParse(_durationCtrl.text) ?? 0,
      calories: int.tryParse(_caloriesCtrl.text) ?? 0,
      steps: int.tryParse(_stepsCtrl.text) ?? 0,
      notes: _notesCtrl.text.trim(),
    );
    await DBHelper.instance.insertWorkout(log);
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
        // Handle
        Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
                color: AppColors.cardBorder,
                borderRadius: BorderRadius.circular(99))),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('LOG WORKOUT',
              style: GoogleFonts.orbitron(
                  fontSize: 15,
                  color: AppColors.accent,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w700)),
          IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close_rounded, color: AppColors.textMuted)),
        ]),
        const SizedBox(height: 16),
        LabeledDropdown(
            label: 'Exercise Type',
            value: _type,
            items: _workoutTypes,
            onChanged: (v) => setState(() => _type = v!)),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
              child: LabeledInput(
                  label: 'Duration *',
                  controller: _durationCtrl,
                  keyboardType: TextInputType.number,
                  suffix: 'min')),
          const SizedBox(width: 12),
          Expanded(
              child: LabeledInput(
                  label: 'Calories *',
                  controller: _caloriesCtrl,
                  keyboardType: TextInputType.number,
                  suffix: 'kcal')),
        ]),
        const SizedBox(height: 14),
        LabeledInput(
            label: 'Steps',
            controller: _stepsCtrl,
            keyboardType: TextInputType.number,
            hint: 'Optional'),
        const SizedBox(height: 14),
        LabeledInput(
            label: 'Notes',
            controller: _notesCtrl,
            hint: 'How did it go?'),
        if (_error.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(_error,
              style: GoogleFonts.rajdhani(color: AppColors.warn, fontSize: 13)),
        ],
        const SizedBox(height: 20),
        NeonButton(
            label: _saving ? 'SAVING...' : 'SAVE WORKOUT',
            onTap: _saving ? () {} : _save,
            color: AppColors.accent,
            width: double.infinity),
      ]),
    );
  }
}