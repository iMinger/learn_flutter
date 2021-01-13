import 'package:flutter/material.dart';

class MyTimeLineAnimationDemo extends StatelessWidget {
  buildBackButton(BuildContext context) {
    return Positioned(
      left: 0.0,
      top: 0.0,
      right: 0.0,
      child: Container(
        padding: EdgeInsets.only(top: 32),
        alignment: Alignment.topLeft,
        child: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          MainPage(),
          buildBackButton(context),
          IconLayer(),
        ],
      ),
    );
  }
}

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.grey, Colors.black],
        ),
      ),
    );
  }
}

class IconLayer extends StatefulWidget {
  @override
  _IconLayerState createState() => _IconLayerState();
}

class _IconLayerState extends State<IconLayer> with TickerProviderStateMixin {
  AnimationController posController;
  Animation<double> posAnimation;
  Duration posDuration;

  AnimationController nController;
  Duration nDuration;

  Animation<double> rotationAnimation;
  Animation<double> scaleDownAnimation;
  Animation<double> scaleUpAnimation;

  @override
  void initState() {
    super.initState();
    // 掉落的动画控制
    posDuration = Duration(milliseconds: 300);
    posController = AnimationController(vsync: this, duration: posDuration)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          // 稍微延迟一下再启动后面的动画， 免得太突兀了
          Future.delayed(Duration(milliseconds: 500), () {
            nController.repeat();
          });
        }
      });
    posAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: posController, curve: Curves.linearToEaseOut));

    //旋转和缩放的动画控制
    nDuration = Duration(milliseconds: 3000);
    nController = AnimationController(vsync: this, duration: nDuration);
    rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: nController, curve: Interval(0.0, 0.7)));
    scaleDownAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
        CurvedAnimation(parent: nController, curve: Interval(0.7, 0.85)));
    scaleUpAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(parent: nController, curve: Interval(0.85, 1.0)));
    //启动动画
    posController.forward();
  }

  @override
  void dispose() {
    posController?.dispose();
    nController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height - 120;
    return AnimatedPositioned(
      right: 10,
      top: height * posAnimation.value,
      duration: posDuration,
      child: Container(
        width: 80,
        height: 80,
        margin: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1.5),
        ),
        child: RotationTransition(
          turns: rotationAnimation,
          child: ScaleTransition(
            scale: scaleDownAnimation,
            child: ScaleTransition(
              scale: scaleUpAnimation,
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/images/juren.jpeg'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}