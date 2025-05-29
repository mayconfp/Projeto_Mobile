import 'package:flutter/material.dart';
import 'package:together/controllers/app_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Together"),
        actions: [
          const CustomSwitch(),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: Stack(
        children: [
          SizedBox(
            child: Image.asset(
              'assets/imagens/tela.jpeg',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton.extended(
            heroTag: 'galeria',
            icon: const Icon(Icons.photo_library, color: Colors.white, size: 35),
            label: const Text(
              'Galeria',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            backgroundColor: const Color(0xFF6A1B9A),
            onPressed: () {
              Navigator.pushNamed(context, '/galeria');
            },
          ),
          FloatingActionButton.extended(
            heroTag: 'roleta',
            icon: const Icon(Icons.casino, color: Colors.white, size: 35),
            label: const Text(
              'Roleta',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            backgroundColor: const Color(0xFF6A1B9A),
            onPressed: () {
              Navigator.pushNamed(context, '/roleta');
            },
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token'); // Remove token

    // Navega para login substituindo a rota atual
    Navigator.of(context).pushReplacementNamed('/login');
  }
}

class CustomSwitch extends StatelessWidget {
  const CustomSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppController.instance,
      builder: (context, child) {
        return Switch(
          value: AppController.instance.isDArtTheme,
          onChanged: (value) {
            AppController.instance.changeTheme();
          },
        );
      },
    );
  }
}
