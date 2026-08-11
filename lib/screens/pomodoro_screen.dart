import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import '../theme.dart';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  static const int workDuration = 25 * 60; // 25 mins in seconds
  int _timeLeft = workDuration;
  bool _isRunning = false;
  Timer? _timer;

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_timeLeft > 0) {
          setState(() => _timeLeft--);
        } else {
          timer.cancel();
          _isRunning = false;
        }
      });
    }
    setState(() => _isRunning = !_isRunning);
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _timeLeft = workDuration;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final minutes = (_timeLeft / 60).floor().toString().padLeft(2, '0');
    final seconds = (_timeLeft % 60).toString().padLeft(2, '0');
    final progress = 1 - (_timeLeft / workDuration);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Timer'),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 280,
                  height: 280,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8,
                    backgroundColor: colorScheme.onSurface.withValues(alpha: 0.05),
                    color: NothingTheme.accent,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Text(
                  '$minutes:$seconds',
                  style: NothingTheme.metricsStyle(isDark).copyWith(
                    fontSize: 72, 
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ).animate().scale(curve: Curves.easeOutBack, duration: 600.ms),
            
            const SizedBox(height: 64),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _resetTimer,
                  icon: const Icon(Icons.refresh_rounded),
                  iconSize: 32,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ).animate().slideY(begin: 0.5, delay: 100.ms).fade(),
                
                const SizedBox(width: 32),
                
                FloatingActionButton.large(
                  onPressed: _toggleTimer,
                  backgroundColor: _isRunning ? colorScheme.surface : NothingTheme.accent,
                  foregroundColor: _isRunning ? colorScheme.onSurface : Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                    side: BorderSide(
                      color: _isRunning ? colorScheme.onSurface.withValues(alpha: 0.2) : Colors.transparent,
                    ),
                  ),
                  child: Icon(_isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded),
                ).animate().scale(delay: 200.ms, curve: Curves.easeOutBack),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
