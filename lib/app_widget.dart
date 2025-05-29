import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:together/controllers/app_controller.dart';
import 'package:together/views/home_page.dart';
import 'package:together/views/login_page.dart';
import 'package:together/views/galeria.dart';
import 'roleta/roleta_page.dart';
import 'views/cadastro_page.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token') != null;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppController.instance,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: Colors.red,
            brightness: AppController.instance.isDArtTheme
                ? Brightness.dark
                : Brightness.light,
          ),
          home: FutureBuilder<bool>(
            future: isLoggedIn(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.data == true) {
                return const HomePage(); // Usuário logado
              } else {
                return LoginPage(); // Usuário não logado
              }
            },
          ),
          routes: {
            '/login': (context) => LoginPage(),
            '/home': (context) => const HomePage(),
            '/roleta': (context) => const RoletaPage(),
            '/galeria': (context) => GaleriaPersistente(),
            '/cadastro': (context) => CadastroPage(),
          },
        );
      },
    );
  }
}
