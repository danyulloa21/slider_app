import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:slider_app/routes/app_pages.dart';

class AppLayout extends StatelessWidget {
  final String title;
  final Widget body;

  /// Muestra ícono de back en el AppBar
  final bool showBack;

  /// Muestra el Drawer lateral
  final bool showDrawer;

  /// Acciones adicionales en el AppBar
  final List<Widget>? actions;

  /// FloatingActionButton opcional
  final Widget? floatingActionButton;

  /// Permitir scroll (por defecto true)
  final bool scrollable;

  /// Color de fondo opcional
  final Color? backgroundColor;

  const AppLayout({
    super.key,
    required this.title,
    required this.body,
    this.showBack = false,
    this.showDrawer = true,
    this.actions,
    this.floatingActionButton,
    this.scrollable = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold(
      backgroundColor:
          backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(title),
        leading: showBack
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  /* if (Get.key.currentState?.canPop() ?? false) {
                    print('---yendo aytas');
                  } */
                  Get.back();
                },
              )
            : (showDrawer
                  ? Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                    )
                  : null),
        actions: actions,
      ),
      drawer: showDrawer ? _buildDrawer(context) : null,
      body: scrollable
          ? SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: body,
              ),
            )
          : SafeArea(
              child: Padding(padding: const EdgeInsets.all(16), child: body),
            ),
      floatingActionButton: floatingActionButton,
    );

    return scaffold;
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const Divider(),
            _buildNavItem(
              icon: Icons.settings,
              label: 'Configuración',
              route: AppRoutes.config,
            ),
            _buildNavItem(
              icon: Icons.sports_motorsports,
              label: 'Juego',
              route: AppRoutes.game,
            ),
            _buildNavItem(
              icon: Icons.leaderboard,
              label: 'Scoreboard',
              route: AppRoutes.scoreboard,
            ),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                'Slider Game - Proyecto DM',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return const UserAccountsDrawerHeader(
      accountName: Text('Jugador'),
      accountEmail: Text(''),
      currentAccountPicture: CircleAvatar(child: Icon(Icons.person)),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required String route,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () {
        // cerramos drawer y navegamos
        Get.back();
        if (Get.currentRoute != route) {
          Get.offAllNamed(route);
        }
      },
    );
  }
}
