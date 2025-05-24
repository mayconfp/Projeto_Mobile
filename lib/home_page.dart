import 'package:flutter/material.dart';
import 'package:project_nassau/app_controller.dart';

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
        actions: const [
          CustomSwitch(),
        ],
      ),

      body: Stack(
        children: [
          SizedBox(
            child: Image.asset(
              'assets/imagens/tela.jpeg', 
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

        ],
      ),

      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton.extended(
            heroTag: 'galeria',
            icon: const Icon(Icons.photo_library, color: Colors.white,size: 35,),
            label: const Text(
              'Galeria',
            style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            backgroundColor: Color(0xFF6A1B9A),
            onPressed: () {
              Navigator.pushNamed(context, '/galeria');
            },
          ),
          FloatingActionButton.extended(
            heroTag: 'roleta',
            icon: const Icon(Icons.casino,color: Colors.white,size: 35,),
            label: const Text(
              'Roleta',
              style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            backgroundColor: Color(0xFF6A1B9A),
            onPressed: () {
              Navigator.pushNamed(context, '/roleta');
            },
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class CustomSwitch extends  StatelessWidget  {
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