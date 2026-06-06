import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dashboard/dashboard_screen.dart';
import 'clients/clients_screen.dart';
import 'invoices/invoices_screen.dart';
import 'reports/reports_screen.dart';
import 'settings/settings_screen.dart';
import 'proposals/proposal_generation_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  static const _storage = FlutterSecureStorage();
  static const String _selectedTabKey = 'selected_tab';

  final List<Widget> _screens = const [
    DashboardScreen(),
    ClientsScreen(),
    InvoicesScreen(),
    ReportsScreen(),
    ProposalGenerationScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadSelectedTab();
  }

  Future<void> _loadSelectedTab() async {
    final savedIndex = await _storage.read(key: _selectedTabKey);
    if (savedIndex != null) {
      setState(() {
        _currentIndex = int.parse(savedIndex);
        _pageController.jumpToPage(_currentIndex);
      });
    }
  }

  Future<void> _saveSelectedTab(int index) async {
    await _storage.write(key: _selectedTabKey, value: index.toString());
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    _saveSelectedTab(index);
  }

  void _onTabTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Clients',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Invoices',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            activeIcon: Icon(Icons.analytics),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            activeIcon: Icon(Icons.description),
            label: 'Proposals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
