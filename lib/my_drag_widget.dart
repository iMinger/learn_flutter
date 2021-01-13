import 'dart:ffi';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:learn_flutter/dashed_decaration.dart';
import 'package:yin_drag_sacle/core/drag_scale_widget.dart';

/// 使用GestureDetector 和 Transform.translate 来改变child的位置
class MyDragWidget extends StatefulWidget {
  MyDragWidget();

  @override
  _MyDragWidgetState createState() => _MyDragWidgetState();
}

class _MyDragWidgetState extends State<MyDragWidget> {
  final mykey = new GlobalKey();
  double dx = 100;
  double dy = 100;
  double scaleX = 1;
  bool operating = false;
  bool selected = false;
  Offset _lastOffset;
  String inputText = "Hello world";
  double rotation = 0;

  /// 输入的内部字符串

  /// 处理点击事件
  void tapEvent() {
    setState(() {
      selected = true;
    });
  }

  /// 取消选中事件
  void cancleTapEvent() {
    setState(() {
      selected = false;
    });
  }

  /// 处理拖动事件
  void dragEvent(DragUpdateDetails details) {
    final RenderObject box = context.findRenderObject();

    // 获取自定义widget的大小,用来计算Widget的中心锚点
    print("当前widget的高度=====${mykey.currentContext.size.height}");
    dx = details.globalPosition.dx - mykey.currentContext.size.width / 2;
    dy = details.globalPosition.dy - mykey.currentContext.size.height / 2;
    operating = true;
    setState(() {});
  }

  /// 拖动事件取消
  void cancelDradEvent(DragEndDetails details) {
    setState(() {
      operating = false;
    });
  }

  void scaleEvent(ScaleUpdateDetails details) {
    setState(() {
    });
  }

  /// 左上scale的widget
  Widget topleftScaleWidget() {
    return GestureDetector(
      onLongPressMoveUpdate: (LongPressMoveUpdateDetails details) {
        scaleX = (details.globalPosition.dx - mykey.currentContext.size.width / 2) / mykey.currentContext.size.width / 2;
        setState(() {});
      },
      child: Container(
        width: 20,
        height: 20,
        color: Colors.greenAccent,
      ),
    );
  }

  /// 右上取消的widget
  Widget toprightCancelWidget() {
    return GestureDetector(
      onTap: () {
        setState(() {
          inputText = null;
        });
      },
      child: Container(
        child: Icon(
          Icons.cancel,
          color: Colors.red,
          size: 30,
        ),
      ),
    );
  }

  /// 左下scale的widget
  Widget bottomleftScaleWidget() {}

  /// 右下scale的widget
  Widget bottomrightScaleWidget() {}

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }



  /// version1 每次都会调用setstate,每次都会重新build State. 比较耗性能.
  Widget version1Widget() {
    return GestureDetector(
      /// 最外一层:衣服层
      onTap: cancleTapEvent,
      child: Stack(
        children: [
          Container(
              width: double.infinity,
              height: double.infinity,
              padding: EdgeInsets.fromLTRB(50, 200, 50, 200),
              color: Colors.grey,
              child: DottedBorder(borderType: BorderType.RRect, color: Colors.red, child: SizedBox())),
          GestureDetector(
            onTap: tapEvent,
            onHorizontalDragUpdate: dragEvent,
            onHorizontalDragEnd: cancelDradEvent,
            onVerticalDragUpdate: dragEvent,
            onVerticalDragEnd: cancelDradEvent,
            child: Transform.translate(
              offset: Offset(dx, dy),
              child: Align(
                  alignment: Alignment.topLeft,
                  child: Stack(
                    children: [
                      DottedBorder(
                        color: Colors.greenAccent,
                        child: Container(
//                            alignment: Alignment.center,
                          key: mykey,
                          color: Colors.yellow,
                          child: inputText != null && inputText.length > 0
                              ? Text(
                                  inputText,
                                  maxLines: 1,
                                  style: TextStyle(
                                    decoration: TextDecoration.none,
                                  ),
                                )
                              : SizedBox(),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: toprightCancelWidget(),
                      ),
                    ],
                  )),
            ),
          ),
        ],
      ),
    );
  }

  Widget version2Widget() {
    return GestureDetector(
      /// 最外一层:衣服层
      onTap: cancleTapEvent,
      child: Stack(
        children: [
          Container(
              width: double.infinity,
              height: double.infinity,
              padding: EdgeInsets.fromLTRB(50, 200, 50, 200),
              color: Colors.grey,
              child: DottedBorder(borderType: BorderType.RRect, color: Colors.red, child: ClipRRect(child: SizedBox()))),
          Center(
            child: Container(
              child: Row(
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: GestureDetector(
                                onTap: tapEvent,
                                onHorizontalDragUpdate: dragEvent,
                                onHorizontalDragEnd: cancelDradEvent,
                                onVerticalDragUpdate: dragEvent,
                                onVerticalDragEnd: cancelDradEvent,
                                child: Transform.translate(
                                  offset: Offset(dx, dy),
                                  child: Transform.scale(
                                    scale: scaleX,
                                    child: Align(
                                        alignment: Alignment.topLeft,
                                        child: Stack(
                                          overflow: Overflow.visible,
                                          children: [
                                            DottedBorder(
                                              color: Colors.greenAccent,
                                              child: Container(
//                            alignment: Alignment.topLeft,
                                                key: mykey,
                                                color: Colors.yellow,
                                                child: inputText != null && inputText.length > 0
                                                    ? Text(
                                                  inputText,
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                    decoration: TextDecoration.none,
                                                  ),
                                                )
                                                    : SizedBox(),
                                              ),
                                            ),
                                            Positioned(
                                              right: -15,
                                              top: -15,
                                              child: toprightCancelWidget(),
                                            ),
                                            Positioned(
                                              left: -5,
                                              top: -5,
                                              child: topleftScaleWidget(),
                                            ),
                                          ],
                                        )),
                                  ),
                                ),
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

      ],
      ),
    );
  }

  Widget version3Widget(){
    return Stack(
      children: [
        Positioned(
          top: dy,
          left: dx,
          child: GestureDetector(
            onScaleStart: (d) {
              print('start localFocalPoint:${d.localFocalPoint}');
              print('start focalPoint:${d.focalPoint}');
              _lastOffset = d.focalPoint;
            },
            onScaleUpdate: (ScaleUpdateDetails d) {


              dx += (d.focalPoint.dx - _lastOffset.dx);
              dy += (d.focalPoint.dy - _lastOffset.dy);

              if (d.scale != 1) {
                scaleX = d.scale.clamp(0.3, 8);
              }
              if (d.rotation != 0) {
                rotation = d.rotation;
              }
              _lastOffset = d.focalPoint;
              setState(() {

              });
            },
            child: Transform.rotate(angle: rotation, child: Text("开心am?")),
          ),
        ),
      ],
    );
  }

  Widget version4Widget(){
     return DragScaleContainer(
      child: Image(image: NetworkImage("http://h.hiphotos.baidu.com/zhidao/wh%3D450%2C600/sign=0d023672312ac65c67506e77cec29e27/9f2f070828381f30dea167bbad014c086e06f06c.jpg")),
      doubleTapStillScale: false,
      maxScale: 4, //放大最大倍数
    );
  }

  Widget build(BuildContext context) {
    print("_MyDragWidgetState 重新build");
    print("dx ==== $dx, dy======$dy");
    return Container(
      alignment: Alignment.center,
      child: version4Widget(),
    );
  }
}
