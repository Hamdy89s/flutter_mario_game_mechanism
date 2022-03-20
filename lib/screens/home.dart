import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mario_game/utils/utils.dart';
import 'package:google_fonts/google_fonts.dart';

class Home extends StatefulWidget {
  const Home({ Key? key }) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  late AnimationController _scaleAnimationController;
  late Animation<double> _scaleAnimation;

  // late AnimationController _mashroomAnimationController;
  // late Animation<double> _mashroomAnimation;

  late AnimationController _scaleBTNColorAnimationController;
  late Animation<double> _scaleBTNColorAnimation;


  final FocusNode _focusNode = FocusNode();
  static double marioX = -0.9;
  static double marioY = 1;
  double defaultStep = 0.02;
  double marioSize = 50.0;
  double time = 0;
  double height = 1;
  double initialHeight = marioY;

  String direction = 'right';
  bool jumping = false;
  bool walking = false;
  bool userIsHoldingButton = false;
  var gameFont = GoogleFonts.pressStart2p(
    color: Colors.white,
    fontSize: 20.0,
  );

  double mashroomX = 0.5;
  double mashroomY = 1;

  double monsterX = 0.8;
  double monsterY = 1;
  bool monsterWalking = false;

  double underGroundMonsterY  = 0.4;

  static double barrierXone = 1;
  double barrierXtwo = barrierXone + 1;

  bool block = false;
  bool gameOver = false;

  String currentButtonClicked = '';

  @override
  void initState() {
    super.initState();
    
    _scaleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _scaleBTNColorAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleBTNColorAnimation = Tween(
      begin: 1.0,
      end: 60.0,
    ).animate(CurvedAnimation(
      parent: _scaleBTNColorAnimationController,
      curve: const Interval(
        0.0,
        0.800,
        curve: Curves.ease,
      ),
    ))..addListener(() {
        setState(() {});
      })..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _scaleBTNColorAnimationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _scaleBTNColorAnimationController.forward();
      }
    });
    _scaleBTNColorAnimationController.forward();
    

    _scaleAnimation = Tween(
      begin: 1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _scaleAnimationController,
      curve: const Interval(
        0.0,
        0.800,
        curve: Curves.ease,
      ),
    ))..addListener(() {
      setState(() {
        
      });
    });

    //underGroundmonster running upsidedown
    // _underGroundMonsterMoveUpsideDown();

    //monster running
    _monsterMoveLeft();

  }
  @override
  void dispose() {
    _scaleAnimationController.dispose();
    _scaleBTNColorAnimationController.dispose();
    super.dispose();
  }

  void _restartGame() {
    if (gameOver == true) {      
      setState(() {
        marioX = -0.9;
        marioY = 1;
        marioSize = 50.0;
        block = false;
        jumping = false;
        

        time = 0;
        height = 1;
        initialHeight = marioY;
        direction = 'right';
        walking = false;
        userIsHoldingButton = false;


        mashroomX = 0.5;
        mashroomY = 1;

        monsterX = 0.8;
        monsterY = 1;
        underGroundMonsterY  = 0.4;

        barrierXone = 1;
        barrierXtwo = barrierXone + 1;

        gameOver = false;
      });  
    }
  }

  void ateMashroom() {
    if ((mashroomX-marioX).abs() < 0.05 && (marioY-mashroomY).abs() < 0.05) {
      _scaleAnimationController.forward();
      setState(() {
        //marioSize = 100.0;
        mashroomX = 2;
      });
    }
  }
  void monsterKilledMario() {
    // print(marioX - monsterX);
    bool a = marioX - monsterX > 0.01;
    bool b = marioX - monsterX < 0.2;
    bool c = marioY == 1;

    if (a && b && c) {
      _deathJump();
      
      sleep(const Duration(seconds: 1));
      setState(() {
        gameOver = true;
      });
    }

    
  }

  void _deathJump() {
    time = 0;
    initialHeight = marioY;
    jumping = false;
    
    Timer.periodic(
      const Duration(milliseconds: 50), (timer) {
      time += 0.05;
      height = -4.9 * time * time + 5 * time;  
      if (gameOver == true) {
        setState(() {
          marioY = initialHeight - height;
          jumping = false;
        });
        // timer.cancel();

      } else {
        if (initialHeight - height > 1) {
          setState(() {
            marioY = 1;
            jumping = false;
          });
        }
        timer.cancel();
      }
      
    });
  }

  void _jump() {
    //this if condition for disable jumping out of hight scope
    if (jumping == false) {
      //every jump reset time and initialHeight
      time = 0;
      initialHeight = marioY;
      jumping = true;

      Timer.periodic(
        const Duration(milliseconds: 50), (timer) {
        time += 0.05;
        height = -4.9 * time * time + 5 * time;  
        double currentMarioY = initialHeight - height;
        if (currentMarioY > 1) {
          jumping = false;
          setState(() {
            marioY = 1;
          });
          timer.cancel();
        } else {
          setState(() {
            marioY = initialHeight - height;
            marioX = direction == 'right' 
              ? marioX + defaultStep : marioX - defaultStep;
          });
        }
        
      });
      jumping = false;
    }
  }
  void _moveLeft() {
    direction = 'left';
    block = false;
    ateMashroom();
    Timer.periodic(const Duration(milliseconds: 50),
    (timer) {
      ateMashroom();
      if (userIsHoldingButton) {
        if ((marioX - defaultStep) > -1) {
          //check if barrierXone pos == marioX so blocking mario walking
          _barrierOneBlockMarioFromRunning(direction);
          //check if barrierXtwo pos == marioX so blocking mario walking
          _barrierTwoBlockMarioFromRunning(direction);

          if (block) {
            setState(() {
              walking = !walking;
            });
          } else {
            setState(() {
              marioX -= defaultStep;
              walking = !walking;

              //barriers
              barrierXone += defaultStep;
              barrierXtwo += defaultStep;
              // _buildBarriersLifeCycle();
            });
          }
        } else {
          setState(() {
            walking = !walking;
          });
        }
        
      } else {
        timer.cancel();
      }
    });
  }
  void _moveRight() {
    direction = 'right';
    block = false;
    ateMashroom();
    Timer.periodic(const Duration(milliseconds: 50),
    (timer) {
      ateMashroom();
      if (userIsHoldingButton) {

        if ((marioX + defaultStep) < 1) {
          //check if barrierXone pos == marioX so blocking mario walking
          _barrierOneBlockMarioFromRunning(direction);
          //check if barrierXtwo pos == marioX so blocking mario walking
          _barrierTwoBlockMarioFromRunning(direction);

          if (block) {
            setState(() {
              walking = !walking;
            });
          } else {
            setState(() {
              marioX += defaultStep;
              walking = !walking;

              //barriers
              barrierXone -= defaultStep;
              barrierXtwo -= defaultStep;
              // _buildBarriersLifeCycle();
            });
          }
        } else {
          setState(() {
            walking = !walking;
          });
        }
      } else {
        timer.cancel();
      }
    });
  }

  _barrierOneBlockMarioFromRunning(String direction) {

    // print("(marioX - barrierXone).abs(): ${(marioX - barrierXone).abs()}");
    // print("marioX - barrierXone: ${marioX - barrierXone}");
    // print("barrierXone: ${barrierXone}");
    // print("marioX: ${marioX}");

    if (direction == 'right') {
      bool a = barrierXone - marioX > 0.1;
      bool b = barrierXone - marioX < 0.2;

      if (a && b) {
        setState(() {
          block = true;
        });
      }
    }
    else if (direction == 'left') {
      bool a = marioX - barrierXone > 0.1;
      bool b = marioX - barrierXone < 0.2;

      if (a && b) {
        setState(() {
          block = true;
        });
      }
    }

    // if (direction == 'right') {
    //   if ((marioX - barrierXone).abs() < barrierXone + defaultStep) {
    //     setState(() {
    //       block = true;
    //     });
    //   } else {
    //     setState(() {
    //       block = false;
    //     });
    //   }
    // } else if (direction == 'left'){
    //   if ((marioX - barrierXone).abs() < barrierXone + defaultStep) {
    //     setState(() {
    //       block = true;
    //     });
    //   } else {
    //     setState(() {
    //       block = false;
    //     });
    //   }
    // }
    
  }
  _barrierTwoBlockMarioFromRunning(String direction) {
    if (direction == 'right') {
      bool a = barrierXtwo - marioX > 0.1;
      bool b = barrierXtwo - marioX < 0.2;

      if (a && b) {
        setState(() {
          block = true;
        });
      }
    }
    else if (direction == 'left') {
      bool a = marioX - barrierXtwo > 0.1;
      bool b = marioX - barrierXtwo < 0.2;

      if (a && b) {
        setState(() {
          block = true;
        });
      }
    }

    // if (direction == 'right') {
    //   print((barrierXtwo - marioX).abs());
    //   print(barrierXtwo + defaultStep);

    //   if ((barrierXtwo - marioX).abs() == barrierXtwo + defaultStep) {
    //     setState(() {
    //       block = true;
    //     });
    //   } else {
    //     setState(() {
    //       block = false;
    //     });
    //   }
    // } else if (direction == 'left') {
    //   if ((barrierXtwo - marioX).abs() < barrierXtwo + defaultStep) {
    //     setState(() {
    //       block = true;
    //     });
    //   } else {
    //     setState(() {
    //       block = false;
    //     });
    //   }
    // }

    
  }

  void _buildBarriersLifeCycle() {
    if (barrierXone < -2.2 ) {
      barrierXone += 3.2;
    } else {
      barrierXone -= defaultStep;
    }

    if (barrierXtwo < -2.2 ) {
      barrierXtwo += 3.2;
    } else {
      barrierXtwo -= defaultStep;
    }
  }

  // Widget _buildControlButton({required Widget child, required onPress, required String key}) {
  //   return GestureDetector(
  //     onTapDown: (details) {
  //       if (gameOver == false) {
  //         setState(() {
  //           currentButtonClicked = key;
  //           userIsHoldingButton = true;
  //           onPress();
  //         });
  //       }
  //     },
  //     onTapUp: (details) {
  //       setState(() {
  //         userIsHoldingButton = false;
  //       });
  //     },
  //     child: Container(
  //       width: screenAwareSize(60.0, context),
  //       height: screenAwareSize(60.0, context),
  //       decoration: BoxDecoration(
  //         color: userIsHoldingButton 
  //           ? currentButtonClicked == key ? Colors.blue : Colors.white60
  //           : Colors.white60,
  //         borderRadius: BorderRadius.circular(10.0),
  //       ),
  //       child: child,
  //     ),
  //   );
  // }

  Widget _buildControlButton({required Widget child, required onPress, required String key}) {
    return GestureDetector(
      onTapDown: (details) {
        if (gameOver == false) {
          setState(() {
            currentButtonClicked = key;
            userIsHoldingButton = true;
            onPress();
          });
          print('${_scaleBTNColorAnimation.value}');
        }
      },
      onTapUp: (details) {
        setState(() {
          userIsHoldingButton = false;
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            clipBehavior: Clip.hardEdge,
            width: screenAwareSize(60.0, context),
            height: screenAwareSize(60.0, context),
            decoration: BoxDecoration(
              color: Colors.white60,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: child,
          ),

          if (userIsHoldingButton && currentButtonClicked == key)...[
            Container(
              width: screenAwareSize(_scaleBTNColorAnimation.value, context),
              height: screenAwareSize(_scaleBTNColorAnimation.value, context),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ]
            
          
        ],
      ),
    );
  }
  
  Widget _buildMarioPlayer() {
    Widget child = Container(
      width: screenAwareSize(marioSize * _scaleAnimation.value, context),
      height: screenAwareSize(marioSize * _scaleAnimation.value, context),
      child: jumping 
        ? Image.asset('assets/images/running_mario.png')
        : walking 
          ? Image.asset('assets/images/running_mario_2.png')
          : Image.asset('assets/images/walking_mario.png'),
    );
    if (direction == 'left'){
      return Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationY(pi),
        child: child,
      );
    }
    return child;
  }
  
  Widget _buildMashroom() {
    return Container(
      width: screenAwareSize(30.0, context),
      height: screenAwareSize(30.0, context),
      child: Image.asset("assets/images/mushroom.png"),
    );
  }
  Widget _buildMonster() {
    return Container(
      width: screenAwareSize(40.0, context),
      height: screenAwareSize(40.0, context),
      child: monsterWalking 
        ? Image.asset("assets/images/monster.png")
        : Image.asset("assets/images/monster_2.png"),
    );
  }
  void _monsterMoveLeft() {
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (monsterX < -1.5) {
        setState(() {
          monsterX = 1.5; 
        });
        timer.cancel();
      }
      else {
        setState(() {
          monsterX -= defaultStep;
          monsterWalking = !monsterWalking;
        });
        monsterKilledMario();
      }
      
    });
  }
  void _underGroundMonsterMoveUpsideDown() {
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (underGroundMonsterY == 0.4) {
        setState(() {
          underGroundMonsterY += .1;
        });
      } else {
        setState(() {
          underGroundMonsterY -= .1;
        });
      }

    });
  }

  //posX the only that will be variable
  Widget _buildBarrier({required double size, required posX, required posY, required bool monster}) {
    if (monster) {
      return Stack(
        children: [
          AnimatedContainer(
            alignment: Alignment(posX, posY),
            duration: const Duration(milliseconds: 0), //0 => to start immediately
            child: Container(
              width: screenAwareSize(100.0, context),
              height: screenAwareSize(size, context),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(15.0),
                border: Border.all(color: Colors.green[700]!, width: 5.0),
              ),
            ),
          ),
          AnimatedContainer(
            alignment: Alignment(posX-0.04, underGroundMonsterY),
            duration: const Duration(milliseconds: 200),
            width: screenAwareSize(50.0, context),
            height: screenAwareSize(50.0, context),
            child: Image.asset("assets/images/monster_2.png"),
          ),
        ],
      );
    }
    return AnimatedContainer(
      alignment: Alignment(posX, posY),
      duration: const Duration(milliseconds: 0), //0 => to start immediately
      child: Container(
        width: screenAwareSize(100.0, context),
        height: screenAwareSize(size, context),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(15.0),
          border: Border.all(color: Colors.green[700]!, width: 5.0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              flex: 4,
              child: Stack(
                children: [
                  Container(
                    color: Colors.blue,
                    child: Stack(
                      children: [
                        AnimatedContainer(
                          alignment: Alignment(marioX, marioY),
                          duration: const Duration(milliseconds: 0),
                          child: _buildMarioPlayer(),
                        ),
                      
                        //barriers
                        _buildBarrier(size: 200.0, posX: barrierXone, posY: 1.3, monster: false),
                        _buildBarrier(size: 250.0, posX: barrierXtwo, posY: 1.3, monster: false),
        
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment(mashroomX, mashroomY),
                    child: _buildMashroom(),
                  ),
                  Align(
                    alignment: const Alignment(0, 0),
                    child: InkWell(
                      onTap: _restartGame,
                      child: gameOver == false ? Text('') : Text("PLAY AGAIN", style: gameFont,)
                    ),
                  ),
                  Align(
                    alignment: Alignment(monsterX, monsterY),
                    child: _buildMonster(),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Text("MARIO", style: gameFont,),
                            addVerticalSpace(10.0),
                            Text("0000", style: gameFont,),
                          ],
                        ),
                        Column(
                          children: [
                            Text("WORLD", style: gameFont,),
                            addVerticalSpace(10.0),
                            Text("1-1", style: gameFont,),
                          ],
                        ),
                        Column(
                          children: [
                            Text("TIME", style: gameFont,),
                            addVerticalSpace(10.0),
                            Text("9999", style: gameFont,),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                color: Colors.brown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildControlButton(
                      child: const Icon(Icons.arrow_back),
                      onPress: _moveLeft,
                      key: '1',
                    ),
                    _buildControlButton(
                      child: const Icon(Icons.arrow_upward),
                      onPress: _jump,
                      key: '2',
                    ),
                    _buildControlButton(
                      child: const Icon(Icons.arrow_forward),
                      onPress: _moveRight,
                      key: '3',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

