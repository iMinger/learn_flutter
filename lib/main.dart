import 'package:flutter/material.dart';
import 'package:learn_flutter/drag_scale_rotate.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: DragScaleRotateWidget(),
    );
  }
}
