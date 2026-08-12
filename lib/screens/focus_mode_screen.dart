import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import 'dart:ui';
import 'package:intl/intl.dart';

class FocusModeScreen extends StatefulWidget {
  const FocusModeScreen({super.key});

  @override
  State<FocusModeScreen> createState() => _FocusModeScreenState();
}

class _FocusModeScreenState extends State<FocusModeScreen> {
  Timer? _timer;
  int _secondsRemaining = 25 * 60; // 25 mins
  bool _isRunning = false;
  late String _currentTime;
  late Timer _clockTimer;

  @override
  void initState() {
    super.initState();
    // Keep screen awake!
    WakelockPlus.enable();
    
    _updateClock();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) => _updateClock());
  }

  void _updateClock() {
    setState(() {
      _currentTime = DateFormat('HH:mm').format(DateTime.now());
    });
  }

  @override
  void dispose() {
    // Let screen turn off again
    WakelockPlus.disable();
    _timer?.cancel();
    _clockTimer.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    setState(() {
      _isRunning = !_isRunning;
      if (_isRunning) {
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            if (_secondsRemaining > 0) {
              _secondsRemaining--;
            } else {
              _isRunning = false;
              timer.cancel();
            }
          });
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  void _resetTimer() {
    setState(() {
      _isRunning = false;
      _timer?.cancel();
      _secondsRemaining = 25 * 60;
    });
  }

  String get _timerString {
    int m = _secondsRemaining ~/ 60;
    int s = _secondsRemaining % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // Pure black background for AOD / OLED
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleTimer,
        onLongPress: _resetTimer,
        child: Container(
          color: Colors.transparent, // catch taps
          width: double.infinity,
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Current Time
              Text(
                _currentTime,
                style: const TextStyle(
                  color: Colors.white24,
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 8,
                ),
              ).animate().fadeIn(duration: 1.seconds),
              
              const SizedBox(height: 64),
              
              // Pomodoro Timer
              Text(
                _timerString,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 96,
                  fontWeight: FontWeight.w100,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ).animate(target: _isRunning ? 1 : 0)
               .tint(color: Colors.redAccent, duration: 300.ms),
               
              const SizedBox(height: 16),
              
              Text(
                _isRunning ? 'FOCUSING' : 'TAP TO START',
                style: TextStyle(
                  color: _isRunning ? Colors.redAccent : Colors.white54,
                  fontSize: 16,
                  letterSpacing: 4,
                ),
              ),
              if (!_isRunning && _secondsRemaining < 25 * 60)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    'LONG PRESS TO RESET',
                    style: TextStyle(color: Colors.white30, fontSize: 12, letterSpacing: 2),
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context),
        backgroundColor: Colors.white10,
        elevation: 0,
        child: const Icon(Icons.close_rounded, color: Colors.white54),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
    );
  }
}
