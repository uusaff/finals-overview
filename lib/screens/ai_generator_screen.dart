import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme.dart';

class AiGeneratorScreen extends StatefulWidget {
  const AiGeneratorScreen({super.key});

  @override
  State<AiGeneratorScreen> createState() => _AiGeneratorScreenState();
}

class _AiGeneratorScreenState extends State<AiGeneratorScreen> {
  final _controller = TextEditingController();
  bool _isGenerating = false;
  bool _isDone = false;

  void _generate() async {
    if (_controller.text.isEmpty) return;
    
    setState(() {
      _isGenerating = true;
    });
    
    // Mock network delay
    await Future.delayed(const Duration(seconds: 3));
    
    if (mounted) {
      setState(() {
        _isGenerating = false;
        _isDone = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Study Plan'),
      ),
      body: _isDone ? _buildSuccess(colorScheme) : _buildForm(colorScheme),
    );
  }

  Widget _buildForm(ColorScheme colorScheme) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Icon(Icons.auto_awesome_rounded, size: 64, color: NothingTheme.accent)
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scaleXY(begin: 0.9, end: 1.1, duration: 2.seconds)
            .tint(color: Colors.white, duration: 2.seconds),
            
        const SizedBox(height: 24),
        
        Text(
          'Paste your syllabus or lecture notes, and our AI will generate a structured study plan for you.',
          style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 16),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 200.ms),
        
        const SizedBox(height: 32),
        
        TextField(
          controller: _controller,
          maxLines: 8,
          decoration: const InputDecoration(
            hintText: 'e.g. Chapter 1: Introduction to Cell Biology...',
            alignLabelWithHint: true,
          ),
        ).animate().slideY(begin: 0.1, delay: 400.ms).fadeIn(),
        
        const SizedBox(height: 32),
        
        ElevatedButton.icon(
          onPressed: _isGenerating ? null : _generate,
          icon: _isGenerating 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
              : const Icon(Icons.auto_awesome_rounded, color: Colors.black),
          label: Text(_isGenerating ? 'GENERATING...' : 'GENERATE PLAN', style: const TextStyle(color: Colors.black)),
          style: ElevatedButton.styleFrom(
            backgroundColor: NothingTheme.accent,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ).animate().slideY(begin: 0.1, delay: 600.ms).fadeIn(),
      ],
    );
  }

  Widget _buildSuccess(ColorScheme colorScheme) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Icon(Icons.check_circle_rounded, size: 80, color: Colors.green)
            .animate()
            .scale(curve: Curves.easeOutBack, duration: 600.ms),
            
        const SizedBox(height: 24),
        
        Text(
          'Plan Generated!',
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 200.ms),
        
        const SizedBox(height: 32),
        
        // Mock output
        _buildPlanItem('Day 1: Cell Structure Basics', colorScheme),
        _buildPlanItem('Day 2: Mitochondria & Energy', colorScheme),
        _buildPlanItem('Day 3: Practice Quiz', colorScheme),
        
        const SizedBox(height: 32),
        
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.surfaceContainerHighest,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text('SAVE TO DASHBOARD', style: TextStyle(color: colorScheme.onSurface)),
        ).animate().slideY(begin: 0.1, delay: 800.ms).fadeIn(),
      ],
    );
  }

  Widget _buildPlanItem(String title, ColorScheme colorScheme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.adjust_rounded, color: NothingTheme.accent),
        title: Text(title),
      ),
    ).animate().slideX(begin: 0.1, delay: 400.ms).fadeIn();
  }
}
