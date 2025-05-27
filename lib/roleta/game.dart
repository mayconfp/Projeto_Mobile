import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';

class Game extends StatefulWidget {
  const Game({Key? key}) : super(key: key);

  @override
  GameState createState() => GameState();
}

class GameState extends State<Game> with SingleTickerProviderStateMixin {
  List<double> sectors = [100, 20, 0.15, 50, 20, 100, 50, 20];
  int randomSectorIndex = -1;
  double doubleSectorRadians = 0;
  bool spinning = false;
  double earnedValue = 0;
  int totalEarnings = 0;
  int spins = 0;

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
    animation =
        Tween<double>(begin: 0, end: 1).animate(curvedAnimation)
          ..addListener(() {
            if (controller.isAnimating) {
              setState(() {
                spinning = true;
              });
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
    doubleSectorRadians = 2 * math.pi / sectors.length;
  }

  void recordStats() {
    earnedValue = sectors[randomSectorIndex];
    totalEarnings = totalEarnings + earnedValue.toInt();
    spins = spins + 1;
  }

  void resetGame() {
    setState(() {
      earnedValue = 0;
      totalEarnings = 0;
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
        randomSectorIndex = math.Random().nextInt(sectors.length);
        double randomRadian = math.Random().nextDouble() * math.pi * 2;
        controller.reset();
        animation =
            Tween<double>(
                begin: 0,
                end:
                    randomRadian +
                    (2 * math.pi * sectors.length) +
                    (doubleSectorRadians * randomSectorIndex),
              ).animate(
                CurvedAnimation(parent: controller, curve: Curves.decelerate),
              )
              ..addListener(() {
                setState(() {});
              })
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
      // ou Padding / Align conforme o comportamento desejado
      child: Column(
        mainAxisSize:
            MainAxisSize.min, // importante para evitar estouro de layout
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildGameTitle(),
          const SizedBox(height: 20),
          _buildGameWheel(),
          const SizedBox(height: 10),
          _buildGameActions(),
          const SizedBox(height: 20),
          _buildResetButton(),
          const SizedBox(height: 30),
          _buildGameStats(),
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
          // Belt fixo (fundo)
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

          // Botão invisível no centro para girar
          Positioned.fill(
            child: Center(
              child: GestureDetector(
                onTap: spin,
                child: Container(
                  width: beltDiameter * 0.28,
                  height: beltDiameter * 0.28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
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

  Widget _buildGameActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          children: [
            const Text(
              "Earned",
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            Text(
              "\$${earnedValue.toStringAsFixed(earnedValue == 0.15 ? 2 : 0)}",
              style: const TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Column(
          children: [
            const Text(
              "Gire",
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            Text(
              spins.toString(),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResetButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: CupertinoColors.systemYellow,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: resetGame,
      child: const Text(
        "Reset Spin",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildGameStats() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTitleColumn(
            title: "Earned",
            value:
                "\$${earnedValue.toStringAsFixed(earnedValue == 0.15 ? 2 : 0)}",
          ),
          _buildTitleColumn(
            title: "Earnings",
            value: "\$${totalEarnings.toStringAsFixed(0)}",
          ),
          _buildTitleColumn(title: "Spins", value: spins.toString()),
        ],
      ),
    );
  }

  Widget _buildTitleColumn({required String title, required String value}) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }
}
