import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fitness_app/app_theme.dart';

// ── GLOW CARD ─────────────────────────────────────────────────────────────────
class GlowCard extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final EdgeInsets? padding;
  final VoidCallback? onTap;

  const GlowCard({
    super.key,
    required this.child,
    this.glowColor = AppColors.neon,
    this.padding,
    this.onTap,
  });

  @override
  State<GlowCard> createState() => _GlowCardState();
}

class _GlowCardState extends State<GlowCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: widget.padding ?? const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hovered
                ? widget.glowColor.withOpacity(0.5)
                : AppColors.cardBorder,
          ),
          boxShadow: _hovered
              ? [
            BoxShadow(
              color: widget.glowColor.withOpacity(0.12),
              blurRadius: 20,
              spreadRadius: 2,
            )
          ]
              : [],
        ),
        child: widget.child,
      ),
    );
  }
}

// ── NEON LABEL ────────────────────────────────────────────────────────────────
class NeonLabel extends StatelessWidget {
  final String text;
  final Color color;

  const NeonLabel(this.text, {super.key, this.color = AppColors.neon});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.orbitron(
        fontSize: 10,
        letterSpacing: 2,
        color: color.withOpacity(0.85),
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

// ── STAT CHIP ─────────────────────────────────────────────────────────────────
class StatChip extends StatelessWidget {
  final String value;
  final String unit;
  final Color color;

  const StatChip(
      {super.key, required this.value, required this.unit, required this.color});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(children: [
        TextSpan(
          text: value,
          style: GoogleFonts.orbitron(
              fontSize: 28, fontWeight: FontWeight.w700, color: color),
        ),
        TextSpan(
          text: ' $unit',
          style: GoogleFonts.rajdhani(
              fontSize: 13, color: AppColors.textMuted, fontWeight: FontWeight.w600),
        ),
      ]),
    );
  }
}

// ── TAG BADGE ─────────────────────────────────────────────────────────────────
class TagBadge extends StatelessWidget {
  final String label;
  final Color color;

  const TagBadge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(
        label,
        style: GoogleFonts.rajdhani(
            fontSize: 12, color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

// ── NEON PROGRESS BAR ─────────────────────────────────────────────────────────
class NeonProgressBar extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final Color color;
  final double height;

  const NeonProgressBar({
    super.key,
    required this.value,
    this.color = AppColors.neon,
    this.height = 6,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, constraints) {
      final w = constraints.maxWidth;
      final filled = (value.clamp(0.0, 1.0) * w);
      return Container(
        height: height,
        width: w,
        decoration: BoxDecoration(
          color: AppColors.cardBorder,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              width: filled,
              height: height,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(99),
                boxShadow: [
                  BoxShadow(color: color.withOpacity(0.5), blurRadius: 6)
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ── NEON BUTTON ───────────────────────────────────────────────────────────────
class NeonButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color color;
  final bool outline;
  final double? width;

  const NeonButton({
    super.key,
    required this.label,
    required this.onTap,
    this.color = AppColors.neon,
    this.outline = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
        decoration: BoxDecoration(
          color: outline ? Colors.transparent : color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color),
          boxShadow: outline
              ? []
              : [BoxShadow(color: color.withOpacity(0.3), blurRadius: 14)],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.orbitron(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: outline ? color : AppColors.bg,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

// ── LABELED INPUT ─────────────────────────────────────────────────────────────
class LabeledInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String? hint;
  final String? suffix;

  const LabeledInput({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.hint,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: GoogleFonts.rajdhani(
                fontSize: 11,
                color: AppColors.textMuted,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.rajdhani(
              fontSize: 15,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
            GoogleFonts.rajdhani(color: AppColors.textMuted, fontSize: 14),
            suffixText: suffix,
            suffixStyle:
            GoogleFonts.rajdhani(color: AppColors.textMuted, fontSize: 13),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
              const BorderSide(color: AppColors.neon, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

// ── DROPDOWN INPUT ────────────────────────────────────────────────────────────
class LabeledDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const LabeledDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: GoogleFonts.rajdhani(
                fontSize: 11,
                color: AppColors.textMuted,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: AppColors.card,
              style: GoogleFonts.rajdhani(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600),
              items: items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}