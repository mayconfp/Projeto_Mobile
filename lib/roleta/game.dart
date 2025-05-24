import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class GameRoleta extends StatefulWidget {
  const GameRoleta({super.key});

  @override
  State<GameRoleta> createState() => _GameRoletaState();
}

class _GameRoletaState extends State<GameRoleta>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _angle = 0.0;
  bool _girando = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Inicializa _animation para evitar erro de uso antes da rotação
    _animation = AlwaysStoppedAnimation(_angle);
  }

  void girar() {
    if (_girando) return;

    setState(() => _girando = true);

    final random = Random().nextDouble() * 6 * pi;
    _animation =
        Tween<double>(begin: _angle, end: _angle + random).animate(
            CurvedAnimation(parent: _controller, curve: Curves.decelerate),
          )
          ..addListener(() => setState(() {}))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              setState(() => _girando = false);
              Navigator.pushNamed(context, '/galeria');
            }
          });

    _controller.reset();
    _controller.forward();
    _angle += random;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fundo
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/imagens/bg.jpeg'),
              fit: BoxFit.cover,
            ),
          ),
        ),

        // Botão Voltar
        Positioned(
          top: 40,
          left: 10,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Voltar',
          ),
        ),

        // Roleta + Botões
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.rotate(
                angle: _animation.value,
                child: Image.asset(
                  'assets/imagens/roleta_base.png', // imagem SEM fundo embutido
                  width: 330,
                  height: 330,
                ),
              ),

              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _girando ? null : girar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text("PLAY", style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: _girando ? null : () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text("STOP", style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
