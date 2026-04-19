import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'dashboard_viewmodel.dart';
import 'hometab.dart';
import 'routine.dart';
import 'journal.dart';
import 'profile.dart';
import 'bottomnav.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardViewModel(),
      child: const _DashboardShell(),
    );
  }
}

class _DashboardShell extends StatelessWidget {
  const _DashboardShell();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();

    final pages = [
      HomeTab(vm: vm),
      RoutineTab(vm: vm),
      const SizedBox.shrink(), // index 2 = SOS (dialog, no page)
      JournalTab(vm: vm),
      ProfileTab(vm: vm),
    ];

    return Scaffold(
      backgroundColor: C.brownBg,
      body: pages[vm.selectedIndex],
      bottomNavigationBar: BottomNav(vm: vm),
    );
  }
}