import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:property/feature/auth/data/auth_repository.dart';
import 'package:property/feature/dashboard/data/repository/dashboard_repository.dart';
import 'package:property/feature/dashboard/presentation/provider/dashboard_provider.dart';
import 'package:property/feature/dashboard/presentation/screen/dashboard_screen.dart';
import 'package:property/feature/home/widget/home_navbar.dart';
import 'package:property/feature/settings/presentation/provider/settings_provider.dart';
import 'package:property/feature/settings/presentation/screen/settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.dashboardRepository});

  final DashboardRepository? dashboardRepository;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<DashboardProvider>(
          create: (_) =>
              DashboardProvider(dashboardRepository ?? DashboardRepository()),
        ),
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => SettingsProvider(context.read<AuthRepository>()),
        ),
      ],
      child: const _HomeShell(),
    );
  }
}

class _HomeShell extends StatefulWidget {
  const _HomeShell();

  @override
  State<_HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<_HomeShell> {
  int _currentIndex = 0;

  static const List<Widget> _pages = [DashboardScreen(), SettingsScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: HomeNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
