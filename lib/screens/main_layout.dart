import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/app_state.dart';
import '../theme.dart';
import 'dashboard_screen.dart';
import 'subjects_list_screen.dart';
import 'calendar_screen.dart';
import 'stats_screen.dart';
import 'settings_screen.dart';
import 'add_exam_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  bool _isFabOpen = false;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const SubjectsListScreen(),
    const CalendarScreen(),
    const StatsScreen(),
    const SettingsScreen(),
  ];

  void _showAddSubjectDialog() {
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    final instructorController = TextEditingController();
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('New Subject', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Subject Name (e.g. Data Structures)'),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: codeController,
                decoration: const InputDecoration(labelText: 'Course Code (e.g. CS-201)'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: instructorController,
                decoration: const InputDecoration(labelText: 'Instructor'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty) {
                    context.read<AppState>().addSubject(
                      nameController.text,
                      codeController.text,
                      instructorController.text,
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('ADD SUBJECT'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFabMenuItem(IconData icon, String label, VoidCallback onTap, ColorScheme colorScheme, {bool isAccent = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.1)),
          ),
          child: Text(label, style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 12),
        FloatingActionButton.small(
          heroTag: label,
          onPressed: onTap,
          backgroundColor: isAccent ? NothingTheme.accent : colorScheme.surface,
          foregroundColor: isAccent ? Colors.white : colorScheme.onSurface,
          elevation: 2,
          child: Icon(icon),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          if (_isFabOpen)
            GestureDetector(
              onTap: () => setState(() => _isFabOpen = false),
              child: Container(
                color: Colors.black.withValues(alpha: 0.5),
              ).animate().fade(duration: 200.ms),
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_isFabOpen) ...[
            _buildFabMenuItem(
              Icons.post_add_rounded, 
              'Add Exam', 
              () {
                setState(() => _isFabOpen = false);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AddExamScreen()));
              }, 
              colorScheme,
              isAccent: true
            ).animate().slideY(begin: 0.5, end: 0, duration: 200.ms).fade(),
            const SizedBox(height: 12),
            _buildFabMenuItem(
              Icons.create_new_folder_rounded, 
              'Add Subject', 
              () {
                setState(() => _isFabOpen = false);
                _showAddSubjectDialog();
              }, 
              colorScheme
            ).animate().slideY(begin: 0.5, end: 0, duration: 200.ms, delay: 50.ms).fade(),
            const SizedBox(height: 16),
          ],
          FloatingActionButton(
            onPressed: () => setState(() => _isFabOpen = !_isFabOpen),
            backgroundColor: _isFabOpen ? colorScheme.surface : NothingTheme.accent,
            foregroundColor: _isFabOpen ? colorScheme.onSurface : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: _isFabOpen ? colorScheme.onSurface.withValues(alpha: 0.1) : Colors.transparent,
              ),
            ),
            child: Icon(_isFabOpen ? Icons.close_rounded : Icons.add_rounded),
          ).animate(target: _isFabOpen ? 1 : 0).rotate(begin: 0, end: 0.125),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
            _isFabOpen = false;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded),
            label: 'Subjects',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart_rounded),
            label: 'Stats',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
