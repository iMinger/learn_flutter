
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart' as vectormath64;
import 'my_matrix_gesture_detector.dart';
import 'package:matrix4_transform/matrix4_transform.dart';

class DragScaleRotateWidget extends StatefulWidget {
  @override
  _DragScaleRotateWidgetState createState() => _DragScaleRotateWidgetState();
}

class _DragScaleRotateWidgetState extends State<DragScaleRotateWidget> {

  Matrix4 matrix = Matrix4.identity();
  Matrix4 resetMatrix =  Matrix4.identity();
  int key = 1;
  MatrixGestureDetector matrixGestureWidget;
  Offset lastFocalPoint = Offset(0, 0);

  Widget myMatrixGestureWidget(){
    matrixGestureWidget = MatrixGestureDetector(
      key: ValueKey("$key"),
      shouldRotate: true,
      shouldScale: true,
      focalPointAlignment: Alignment.center,
      forceMatrix: resetMatrix,
      infoCallback: (focalPoint, matrix){
        lastFocalPoint = focalPoint;
        matrix = matrix;
        print("信息更新");
        print("信息更新focalPoint======$focalPoint");
        print("信息更新matrix======$matrix");
      },
      onMatrixUpdate: (m, tm, sm, rm) {
        print("MatrixGestureDetector onMatrixUpdate build");
        print("m = \n$m");
        print("rm = \n$rm.");

        print("rotate = \n${m.getRotation()}.");
        print("信息 = \n${MatrixGestureDetector.decomposeToValues(m)}.");
        setState(() {
          matrix = m;
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
    );
    return matrixGestureWidget;
  }

  void updateTranslateX(double translateX) {
    setState(() {
      matrix[12] = double.parse(translateX.toStringAsFixed(0));
      resetMatrix = matrix;
    });
  }

  void updateTranslateY(double translateY) {
    setState(() {
      key += 1;
      matrix[13] = double.parse(translateY.toStringAsFixed(0));
      resetMatrix = matrix;
    });
  }

  void updateScale(double scalevalue) {
    /// 将x,y 轴方向上的缩放比例设置为1, 即不进行缩放.
    setState(() {
      key += 1;

      /// 方案一: 使用该方法会改变旋转值.
//      var dx = (1 - scalevalue) * lastFocalPoint.dx;
//      var dy = (1 - scalevalue) * lastFocalPoint.dy;
//      matrix[0] = scalevalue;
//      matrix[5] = scalevalue;
//      matrix[10] = scalevalue;
//      matrix[12] = dx;
//      matrix[13] = dy;

      /// 方案二: 使用
      MatrixDecomposedValues decomposedValues = MatrixGestureDetector.decomposeToValues(matrix);
      double factor = scalevalue / decomposedValues.scale;
      var myTransform = Matrix4Transform.from(matrix);
      matrix = myTransform.scale(factor,origin:lastFocalPoint).matrix4;
      resetMatrix = matrix;
    });
  }

  void updateRotate(double rotatevalue) {
    setState(() {
      key += 1;
      double angle = rotatevalue / 180.0 * pi;

      var c = cos(angle);
      var s = sin(angle);
      var dx = (1 - c) * lastFocalPoint.dx + s * lastFocalPoint.dy;
      var dy = (1 - c) * lastFocalPoint.dy - s * lastFocalPoint.dx;

      /// 方案一: rotateZ 这个旋转方法,是在原来matrix的基础上增加angle度的旋转.不能达到我们想要的结果.并且其旋转点在左上角.不是中心
//      matrix.rotateZ(angle);


      /// x scale
      /// 方案二: 在matrix4 对象中直接对其中的值进行更改. 使用这个方案,会导致scale 值更改.
//      matrix[0]  = c;
//      matrix[1]  = s;       // y skew
//      matrix[4]  = -s;      // x skew
//      matrix[5]  = c;       // y scale
//      matrix[12] = dx;      //# x translation
//      matrix[13] = dy;      //# y translation
//      resetMatrix = matrix;
      /// 方案三: 根据新的偏移量,缩放值,旋转值生成新的matrix4 对象, 会造成不是按照中心点位置来旋转并且x和y的偏移量每次都会改变
//      MatrixDecomposedValues decomposedValues = MatrixGestureDetector.decomposeToValues(matrix);
//      Matrix4 translateMatrix = Matrix4.translationValues(decomposedValues.translation.dx, decomposedValues.translation.dy, 0);
//      Matrix4 scaleMatrix     = Matrix4.diagonal3Values(decomposedValues.scale, decomposedValues.scale, 1);
//      Matrix4 rotateMatrix    = Matrix4.rotationZ(angle);
//
//      matrix      =  MatrixGestureDetector.compose(null, translateMatrix, scaleMatrix, rotateMatrix);
//      resetMatrix =  MatrixGestureDetector.compose(null, translateMatrix, scaleMatrix, rotateMatrix);


      MatrixDecomposedValues decomposedValues = MatrixGestureDetector.decomposeToValues(matrix);
      double angleGap = angle - decomposedValues.rotation;

      /// 方案四: matrix4_transform 使用该类来设置旋转的中心点.
      var myTransform = Matrix4Transform.from(matrix);
      matrix = myTransform.rotate(angleGap,origin: lastFocalPoint).matrix4;
      resetMatrix = matrix;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<Matrix4> notifier = ValueNotifier(Matrix4.identity());
    return Scaffold(
      appBar: AppBar(
        title: Text("Transform-scale-rotate"),
      ),
      body: Column(
        children: [
          Container(
            height: 400,
            child: Stack(
              children: [
                myMatrixGestureWidget(),
              ],
            ),
          ),
          Text("x偏移量: ${MatrixGestureDetector.decomposeToValues(matrix).translation.dx.toStringAsFixed(0)}: y偏移量: ${MatrixGestureDetector.decomposeToValues(matrix).translation.dy.toStringAsFixed(0)}"),
          Text("缩放比例: ${MatrixGestureDetector.decomposeToValues(matrix).scale.toStringAsFixed(2)}"),
          Text("旋转角度: ${(MatrixGestureDetector.decomposeToValues(matrix).rotation * 180 / pi).toStringAsFixed(0)}"),
          Row(
            children: [
              Text("修改水平方向偏移量:"),
              SizedBox(
                width: 150,
                child: TextField(
                  keyboardType: TextInputType.number,
                  onSubmitted: (String value){
                    updateTranslateX(double.parse(value));
                  },
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text("修改竖直方向偏移量:"),
              SizedBox(
                width: 150,
                child: TextField(
                  keyboardType: TextInputType.number,
                  onSubmitted: (String value){
                    updateTranslateY(double.parse(value));
                  },
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text("缩放比例:"),
              SizedBox(
                width: 150,
                child: TextField(
                  keyboardType: TextInputType.number,
                  onSubmitted: (String value){
                    updateScale(double.parse(value));
                  },
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text("旋转角度:"),
              SizedBox(
                width: 150,
                child: TextField(
                  keyboardType: TextInputType.number,
                  onSubmitted: (String value){
                    updateRotate(double.parse(value));
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
            setState(() {
              key +=1;


              /// 将x,y 轴方向上的缩放比例设置为1, 即不进行缩放.
              matrix[0] = 1;
              matrix[5] = 1;
              matrix[10] = 1;

              /// 将x, y 方向上的位移设为0,
              matrix[12] = 0;
              matrix[13] = 0;
              resetMatrix =   matrix;
              print("resetMatrix=\n${resetMatrix}");
              /// 将z方向上的旋转角度置为0
              ///
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

