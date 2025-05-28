import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';

class Game extends StatefulWidget {
  const Game({Key? key}) : super(key: key);

  @override
  GameState createState() => GameState();
}

class GameState extends State<Game> with SingleTickerProviderStateMixin {
  // ✅ Lista de setores baseada na imagem da roleta (10 setores)
  final List<String> activities = [
    'Barzinho',
    'Parque',
    'Parque',
    'Almoço',
    'Netflix',
    'Almoço',
    'Netflix',
    'Passeio',
    'Netflix',
    'Netflix',
  ];

  int randomSectorIndex = -1;
  double doubleSectorRadians = 0;
  bool spinning = false;
  int spins = 0;
  String? selectedActivity;

  late AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    generateSectorRadians();
    controller = AnimationController(
      duration: const Duration(milliseconds: 3600),
      vsync: this,
    );

    final curvedAnimation = CurvedAnimation(
      parent: controller,
      curve: Curves.decelerate,
    );

    animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation)
      ..addListener(() {
        if (controller.isAnimating) {
          setState(() => spinning = true);
        }
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            recordStats();
            spinning = false;
          });
        }
      });
  }

  void generateSectorRadians() {
    doubleSectorRadians = 2 * math.pi / activities.length;
  }

  void recordStats() {
    // Calcula o setor com base na rotação final
    double angle = animation.value % (2 * math.pi);
    double correctedAngle =
        (2 * math.pi - angle + doubleSectorRadians / 2) % (2 * math.pi);

    int index = (correctedAngle ~/ doubleSectorRadians) % activities.length;

    setState(() {
      selectedActivity = activities[index];
      spins++;
    });
  }

  void resetGame() {
    setState(() {
      selectedActivity = null;
      spins = 0;
      randomSectorIndex = -1;
      controller.reset();
      spinning = false;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void spin() {
    if (!spinning) {
      setState(() {
        randomSectorIndex = math.Random().nextInt(activities.length);
        double randomRadian = math.Random().nextDouble() * math.pi * 2;

        // ✅ Gira de 5 a 8 voltas + ângulo do setor
        double totalRotation = randomRadian +
            (2 * math.pi * activities.length) +
            (doubleSectorRadians * randomSectorIndex);

        controller.reset();
        animation = Tween<double>(begin: 0, end: totalRotation).animate(
          CurvedAnimation(parent: controller, curve: Curves.decelerate),
        )
          ..addListener(() => setState(() {}))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              setState(() {
                recordStats();
                spinning = false;
              });
            }
          });

        controller.forward();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.brown, body: body());
  }

  Widget body() {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/imagens/bg.jpeg"),
          fit: BoxFit.cover,
        ),
      ),
      child: gameContent(),
    );
  }

  Widget gameContent() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildGameTitle(),
          const SizedBox(height: 20),
          _buildGameWheel(),
          const SizedBox(height: 20),
          _buildActivityDisplay(),
          const SizedBox(height: 20),
          _buildResetButton(),
        ],
      ),
    );
  }

  Widget _buildGameTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Color(0xFFAB47BC), Color(0xFF8E24AA)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Text(
            "Together",
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameWheel() {
    final beltDiameter = MediaQuery.of(context).size.width * 0.80;
    final wheelDiameter = beltDiameter * 0.82;

    return SizedBox(
      height: beltDiameter,
      width: beltDiameter,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            "assets/imagens/belt.png",
            width: beltDiameter,
            height: beltDiameter,
            fit: BoxFit.contain,
          ),
          Positioned(
            top: 41,
            left: 5,
            right: 0,
            child: Align(
              alignment: Alignment.center,
              child: Transform.rotate(
                angle: animation.value,
                child: ClipOval(
                  child: Image.asset(
                    "assets/imagens/wheel.png",
                    width: wheelDiameter,
                    height: wheelDiameter,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Center(
              child: GestureDetector(
                onTap: spin,
                child: Container(
                  width: beltDiameter * 0.28,
                  height: beltDiameter * 0.28,
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityDisplay() {
    return selectedActivity != null
        ? Column(
            children: [
              const Text(
                'Atividade sorteada:',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              const SizedBox(height: 8),
              Text(
                selectedActivity!,
                style: const TextStyle(
                  color: Colors.yellowAccent,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/galeria');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 223, 208, 215),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                icon: const Icon(Icons.photo_library),
                label: const Text(
                  'Registrar momento',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          )
        : const SizedBox.shrink();
  }

  Widget _buildResetButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 209, 89, 125),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: resetGame,
      child: const Text(
        "Resetar Roleta",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }
}
