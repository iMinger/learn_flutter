
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';

class DragScaleRotateWidget extends StatefulWidget {
  @override
  _DragScaleRotateWidgetState createState() => _DragScaleRotateWidgetState();
}

class _DragScaleRotateWidgetState extends State<DragScaleRotateWidget> {

  Matrix4 matrix = Matrix4.identity();
  Matrix4 resetMatrix =  Matrix4.identity();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Transform-scale-rotate"),
      ),
      body: MatrixGestureDetector(
        onMatrixUpdate: (m, tm, sm, rm) {
          print("MatrixGestureDetector onMatrixUpdate build");
          print("m = \n$m");
          setState(() {
            matrix = MatrixGestureDetector.compose(matrix, tm, sm, rm);
          });

        },
        child: Transform(
              transform: matrix,
              child: Stack(
                children: <Widget>[
                  Container(
                    color: Colors.white30,
                  ),
                  Positioned.fill(
                    child: Container(
                      color: Colors.lightGreen,
//                      transform: notifier.value,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: Icon(
                          Icons.favorite,
                          color: Colors.deepPurple.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: FlutterLogoDecoration(),
                    padding: EdgeInsets.all(32),
                    alignment: Alignment(0, 0),
                    child: Text(
                      'use your two fingers to translate / rotate / scale ...',
                      style: Theme.of(context).textTheme.display2,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          setState(() {
            matrix = resetMatrix;
          });
        },
        child: Text("重置"),
      ),
    );
  }
}

/*
* Column(
              children: [
                Text("移动: x: ${matrix[12]}, y: ${matrix[13]} "),
                Text("放大: x: ${matrix[0]}"),
                Text("旋转:  ${matrix[4]} "),
              ],
            ),
* */

