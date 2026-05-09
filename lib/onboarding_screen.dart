import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitness_app/app_theme.dart';
import 'package:fitness_app/models.dart';
import 'package:fitness_app/shared_widgets.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageCtrl = PageController();
  int _page = 0;

  // Profile form controllers
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _goalCtrl = TextEditingController(text: '2000');
  String _errorMsg = '';

  late AnimationController _glowCtrl;
  late Animation<double> _glowAnim;

  final _slides = [
    _Slide(
      title: 'FORGE YOUR\nBEST SELF',
      subtitle:
      'Track every rep, every step, every calorie.\nYour transformation starts now.',
      color: AppColors.neon,
      icon: Icons.bolt_rounded,
    ),
    _Slide(
      title: 'TRACK\nEVERYTHING',
      subtitle:
      'Log workouts, monitor nutrition, and watch your progress build day by day.',
      color: AppColors.accent,
      icon: Icons.monitor_heart_rounded,
    ),
    _Slide(
      title: 'ANALYZE &\nIMPROVE',
      subtitle:
      'Deep insights and charts reveal patterns that turn effort into results.',
      color: AppColors.purple,
      icon: Icons.insights_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.3, end: 0.7).animate(
        CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_page < 2) {
      _pageCtrl.nextPage(
          duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
    } else {
      _pageCtrl.nextPage(
          duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
    }
  }

  Future<void> _saveProfile() async {
    if (_nameCtrl.text.isEmpty ||
        _ageCtrl.text.isEmpty ||
        _weightCtrl.text.isEmpty ||
        _heightCtrl.text.isEmpty) {
      setState(() => _errorMsg = 'Please fill all required fields.');
      return;
    }
    final profile = UserProfile(
      name: _nameCtrl.text.trim(),
      age: int.tryParse(_ageCtrl.text) ?? 25,
      weight: double.tryParse(_weightCtrl.text) ?? 70.0,
      height: double.tryParse(_heightCtrl.text) ?? 175.0,
      calorieGoal: int.tryParse(_goalCtrl.text) ?? 2000,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile', jsonEncode(profile.toMap()));
    await prefs.setBool('onboarded', true);
    if (mounted) {
      Navigator.of(context)
          .pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: PageView(
        controller: _pageCtrl,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (i) => setState(() => _page = i),
        children: [
          ..._slides.map(_buildSlide),
          _buildProfileSetup(),
        ],
      ),
    );
  }

  Widget _buildSlide(_Slide slide) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            const Spacer(),
            // Grid background glow
            AnimatedBuilder(
              animation: _glowAnim,
              builder: (ctx, _) => Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: slide.color.withOpacity(_glowAnim.value * 0.08),
                  boxShadow: [
                    BoxShadow(
                      color: slide.color.withOpacity(_glowAnim.value * 0.25),
                      blurRadius: 80,
                      spreadRadius: 20,
                    )
                  ],
                ),
                child: Icon(slide.icon,
                    size: 80,
                    color: slide.color.withOpacity(0.9 + _glowAnim.value * 0.1)),
              ),
            ),
            const SizedBox(height: 48),
            Text(
              slide.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.orbitron(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                height: 1.1,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              slide.subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.rajdhani(
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
            const Spacer(),
            // Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                final active = i == _page;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active ? slide.color : AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(99),
                    boxShadow: active
                        ? [BoxShadow(color: slide.color.withOpacity(0.5), blurRadius: 8)]
                        : [],
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),
            NeonButton(
              label: _page < 2 ? 'CONTINUE' : 'GET STARTED',
              onTap: _nextPage,
              color: slide.color,
              width: double.infinity,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSetup() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            const NeonLabel('Setup Profile'),
            const SizedBox(height: 6),
            Text('WHO ARE YOU?',
                style: GoogleFonts.orbitron(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: 2)),
            const SizedBox(height: 28),
            GlowCard(
              child: Column(
                children: [
                  LabeledInput(
                      label: 'Your Name *',
                      controller: _nameCtrl,
                      hint: 'Enter your name'),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(
                        child: LabeledInput(
                            label: 'Age *',
                            controller: _ageCtrl,
                            keyboardType: TextInputType.number,
                            hint: '25',
                            suffix: 'yrs')),
                    const SizedBox(width: 12),
                    Expanded(
                        child: LabeledInput(
                            label: 'Weight *',
                            controller: _weightCtrl,
                            keyboardType: TextInputType.number,
                            hint: '70',
                            suffix: 'kg')),
                  ]),
                  const SizedBox(height: 16),
                  LabeledInput(
                      label: 'Height *',
                      controller: _heightCtrl,
                      keyboardType: TextInputType.number,
                      hint: '175',
                      suffix: 'cm'),
                  const SizedBox(height: 16),
                  LabeledInput(
                      label: 'Daily Calorie Goal',
                      controller: _goalCtrl,
                      keyboardType: TextInputType.number,
                      suffix: 'kcal'),
                  if (_errorMsg.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(_errorMsg,
                        style: GoogleFonts.rajdhani(
                            color: AppColors.warn, fontSize: 13)),
                  ],
                  const SizedBox(height: 20),
                  NeonButton(
                      label: 'LAUNCH APP →',
                      onTap: _saveProfile,
                      width: double.infinity),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Slide {
  final String title, subtitle;
  final Color color;
  final IconData icon;
  const _Slide(
      {required this.title,
        required this.subtitle,
        required this.color,
        required this.icon});
}