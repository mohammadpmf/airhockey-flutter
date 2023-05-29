import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
const playerSize = 50.0;
const playerRadius = playerSize/2;
const ballSize = 50.0;
const ballRadius = ballSize/2;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Air Hockey Mohammad Pourmohammadi Fallah',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        dividerColor: Colors.yellowAccent,
        dividerTheme: const DividerThemeData(space: 1),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // player 1 & 2 and ball variables
  PlayerWidget player1 = PlayerWidget(name: "red", color: Colors.red);
  PlayerWidget player2 = PlayerWidget(name: "blue", color: Colors.blue);
  PlayerWidget ball = PlayerWidget(name: "ball", color: Colors.white);

  // ball attributes
  late double xSpeed;
  late double ySpeed;

  // table attributes
  late final double tableHeight;
  late final double tableWidth;

  // Start text attributes
  String textStart = 'Tap to start!';
  final textStartHeight = 120.0;
  final textStartWidth = 480.0;
  double textStartFontSize = 30.0;
  late final double textStartTop;
  late final double textStartLeft;

  // global attributes
  late String turn;
  bool gameIsStarted = false;
  bool gameIsFinished = false;
  bool showStartText = true;
  late double distanceBall2P1;
  late double distanceBall2P2;
  int gameEndsAt = 10;

  double pythagoras(double a, double b){ // Hamoon Fisaghorese :D
    return sqrt(pow(a, 2).toDouble() + pow(b, 2).toDouble());
  }

  void nextRound(String player) {
    player == player1.name ? player1.score++ : player2.score++;
    turn = player == player1.name ? player2.name : player1.name;
    xSpeed = 0;
    ySpeed = 0;
    showStartText = true;
    if (player1.score == gameEndsAt) {
      textStart = "${player1.name} Wins";
      textStartFontSize *= 2;
      turn = player1.name;
      gameIsFinished = true;
    } else if (player2.score == gameEndsAt) {
      textStart = "${player2.name} Wins";
      textStartFontSize *= 2;
      turn = player2.name;
      gameIsFinished = true;
    }
    ball.left = (tableWidth / 2) - ballRadius;
    ball.top = (tableHeight / 2) - ballRadius;
  }

  void doTheMathWork() {



    player1.right = player1.left + playerSize;
    player1.bottom = player1.top + playerSize;
    player1.centerX = player1.left + playerRadius;
    player1.centerY = player1.top + playerRadius;
    player2.right = player2.left + playerSize;
    player2.bottom = player2.top + playerSize;
    player2.centerX = player2.left + playerRadius;
    player2.centerY = player2.top + playerRadius;
    ball.right = ball.left + ball.size;
    ball.bottom = ball.top + ball.size;
    ball.centerX = ball.left + ballRadius;
    ball.centerY = ball.top + ballRadius;
    distanceBall2P1 = pythagoras(ball.centerX - player1.centerX, ball.centerY - player1.centerY);
    distanceBall2P2 = pythagoras(ball.centerX - player2.centerX, ball.centerY - player2.centerY);
    // Player1 (top player) calculations
    if (distanceBall2P1 <= playerRadius + ballRadius) {
      xSpeed = (ball.centerX - player1.centerX) / (ball.centerY - player1.centerY);
      if (player1.shotX != 0) {
        xSpeed = 5*player1.shotX;
        ySpeed = 5*player1.shotY;
      }
      xSpeed = xSpeed > 10 ? 10 : xSpeed;
      ySpeed = 1 / xSpeed.abs();
      ySpeed = ySpeed > 5 ? 5 : ySpeed;
    }

    // Player2 (bottom player) calculations
    else if (distanceBall2P2 <= playerRadius + ballRadius) {
      xSpeed = -(ball.centerX - player2.centerX) / (ball.centerY - player2.centerY);
      if (player2.shotX != 0) {
        xSpeed = 5*player2.shotX;
        ySpeed = 5*player2.shotY;
      }
      xSpeed = xSpeed < -10 ? -10 : xSpeed;
      ySpeed = -1 / xSpeed.abs();
      ySpeed = ySpeed < (-5) ? (-5) : ySpeed;
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    double sWidth = MediaQuery.of(context).size.width;
    double sHeight = MediaQuery.of(context).size.height;

    if (!gameIsStarted) {
      player1.score=0;
      player2.score=0;
      tableWidth = sWidth - playerSize;
      tableHeight = sHeight - 4 * playerSize;
      player1.left = tableWidth / 2 - playerRadius;
      player1.top = 0;
      player2.left = tableWidth / 2 - playerRadius;
      player2.top = tableHeight - playerSize;
      textStartLeft = tableWidth / 2 - textStartWidth / 2;
      textStartTop = tableHeight / 2 - textStartHeight / 2;
      ball.left = tableWidth / 2 - ballRadius;
      ball.top = tableHeight / 2 - ballRadius;
      turn = Random().nextBool()?player1.name:player2.name;
      gameIsStarted = true;
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Container(
            color: Colors.green,
            width: tableWidth,
            height: tableHeight,
            child: Stack(
              children: [
                // The table which is stateless and does not move
                Positioned(
                  child: Column(
                    children: [
                      SizedBox(
                        height: playerSize*3,
                      ),
                      const Divider(),
                      const Expanded(child: SizedBox()),
                      const Divider(color: Colors.white,thickness: 2),
                      const Expanded(child: SizedBox()),
                      const Divider(),
                      SizedBox(
                        height: playerSize*3,
                      ),
                    ],
                  ),
                ),

                // player1 (top player)
                !gameIsFinished
                    ? Positioned(
                  left: player1.left,
                  top: player1.top,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      player1.left += details.delta.dx;
                      player1.left = player1.left > 0 ? player1.left : 0;
                      player1.left =
                      player1.left < (tableWidth - playerSize)
                          ? player1.left
                          : (tableWidth - playerSize);
                      player1.shotX = details.delta.dx;
                      player1.top += details.delta.dy;
                      player1.top = player1.top > 0 ? player1.top : 0;
                      player1.top =
                      player1.top < playerSize*2
                          ? player1.top
                          : playerSize*2;
                      player1.shotY = details.delta.dy;
                      setState(() {});
                    },
                    onPanEnd: (details) {
                      player1.shotX = 0;
                      player1.shotY = 0;
                      setState(() {});
                    },
                    child: player1,
                  ),
                )
                    : const SizedBox(),

                // player2 (bottom player)
                !gameIsFinished
                    ? Positioned(
                  left: player2.left,
                  top: player2.top,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      player2.left += details.delta.dx;
                      player2.left = player2.left > 0 ? player2.left : 0;
                      player2.left =
                      player2.left < (tableWidth - playerSize)
                          ? player2.left
                          : (tableWidth - playerSize);
                      player2.shotX = details.delta.dx;
                      player2.top += details.delta.dy;
                      player2.top = player2.top > tableHeight-3*playerSize ? player2.top : tableHeight-3*playerSize;
                      player2.top =
                      player2.top < tableHeight-playerSize
                          ? player2.top
                          : tableHeight-playerSize;
                      player2.shotY = details.delta.dy;
                      setState(() {});
                    },
                    onPanEnd: (details) {
                      player2.shotX = 0;
                      player2.shotY = 0;
                      setState(() {});
                    },
                    child: player2,
                  ),
                )
                    : const SizedBox(),

                // ball and the inside text
                !gameIsFinished
                    ? Positioned(
                  left: ball.left,
                  top: ball.top,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(ballRadius),
                    child: Container(
                      width: ballSize,
                      height: ballSize,
                      color: ball.color,
                      child: Visibility(
                        visible: showStartText,
                        child: Column(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceAround,
                          children: [
                            RotatedBox(
                              quarterTurns: 2,
                              child: Text(
                                "You: ${player1.score}",
                                style: TextStyle(
                                  fontSize: ballSize / 4,
                                ),
                              ),
                            ),
                            Text(
                              "You: ${player2.score}",
                              style: TextStyle(
                                fontSize: ballSize / 4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
                    : const SizedBox(),

                // text and tapping to start
                Positioned(
                  width: textStartWidth,
                  height: textStartHeight,
                  left: textStartLeft,
                  top: textStartTop,
                  child: Center(
                    child: Visibility(
                      visible: showStartText,
                      child: TextButton(
                        child: RotatedBox(
                          quarterTurns: turn == player1.name ? 2 : 0,
                          child: Text(
                            textStart,
                            style: TextStyle(
                                fontSize: textStartFontSize,
                                color: turn == player1.name
                                    ? player1.color
                                    : player2.color),
                          ),
                        ),
                        onPressed: () async {
                          if (gameIsFinished) {
                            return;
                          }
                          // xSpeed = Random().nextBool() ? 2.0 : -2.0 ;  // simpler version
                          // ySpeed = turn == player1 ? 1.0 : -1.0 ;  // simpler version
                          xSpeed = Random().nextBool()
                              ? (Random().nextInt(2) + 1).toDouble()
                              : -(Random().nextInt(2) + 1).toDouble();
                          ySpeed = turn == player1.name
                              ? (Random().nextInt(1) + 1).toDouble()
                              : -(Random().nextInt(1) + 1).toDouble();
                          showStartText = false;
                          do {
                            ball.left += xSpeed;
                            ball.top += ySpeed;
                            if (ball.left > tableWidth - ballSize) {
                              // xSpeed *= -1; // this version has bug and sometimes the ball stucks in the right wall
                              xSpeed = (-1) * (xSpeed.abs());
                            } else if (ball.left <= 0) {
                              // xSpeed *= -1; // this version has bug and sometimes the ball stucks in the left wall
                              xSpeed = xSpeed.abs();
                            }
                            if (ball.top > tableHeight - ballSize / 3) {
                              nextRound(player1.name);
                              break;
                            } else if (ball.top <= 0 - ballSize * 2 / 3) {
                              nextRound(player2.name);
                              break;
                            }
                            doTheMathWork();
                            await Future.delayed(
                                const Duration(milliseconds: 1));
                            setState(() {});
                          } while (true);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PlayerWidget extends StatefulWidget {
  late double left=0;
  late double right=0;
  late double top=0;
  late double bottom=0;
  late double centerX=0;
  late double centerY=0;
  late double shotX=0;
  late double shotY=0;
  late int score=0;
  final String name;
  final double size=playerSize;
  final Color color;

  PlayerWidget({
    super.key,
    required this.name,
    required this.color,
  });

  @override
  State<PlayerWidget> createState() => _PlayerWidgetState();
}

class _PlayerWidgetState extends State<PlayerWidget> {
  @override
  Widget build(BuildContext context) {

    return ClipRRect(
      borderRadius: BorderRadius.circular(playerRadius),
      child: Container(
        width: widget.size,
        height: widget.size,
        color: widget.color,
      ),
    );
  }
}
