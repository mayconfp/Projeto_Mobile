import 'package:flutter/material.dart';
import 'package:project_nassau/controllers/app_controller.dart';
import 'package:project_nassau/views/home_page.dart';
import 'package:project_nassau/views/login_page.dart';
import 'package:project_nassau/views/galeria.dart';
import 'roleta/roleta_page.dart';

class AppWidget extends StatelessWidget{
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppController.instance,
      builder: (context, child){
      return MaterialApp(
      theme: ThemeData(primaryColor: Colors.red,
      brightness: AppController.instance.isDArtTheme ? Brightness.dark : 
      Brightness.light, // aqui dizemos se ele for false ele é light se não ele é dark
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/home': (context) => HomePage(),
        '/roleta': (context) => const RoletaPage(),
        '/galeria': (context) => GaleriaPersistente(),
      },
    );
    });
  }
    
}