library matrix_gesture_detector;

import 'dart:async';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:vector_math/vector_math_64.dart';

typedef MatrixGestureDetectorCallback = void Function(
    Matrix4 matrix,
    Matrix4 translationDeltaMatrix,
    Matrix4 scaleDeltaMatrix,
    Matrix4 rotationDeltaMatrix);

typedef MatrixGestureDetectorInfoCallback = void Function(
    Offset focalPoint,
    Matrix4 matrix,
    );
/// [MatrixGestureDetector] detects translation, scale and rotation gestures
/// and combines them into [Matrix4] object that can be used by [Transform] widget
/// or by low level [CustomPainter] code. You can customize types of reported
/// gestures by passing [shouldTranslate], [shouldScale] and [shouldRotate]
/// parameters.
///
class MatrixGestureDetector extends StatefulWidget {
  /// [Matrix4] change notification callback
  ///
  final MatrixGestureDetectorCallback onMatrixUpdate;


  final MatrixGestureDetectorInfoCallback infoCallback;
  /// The [child] contained by this detector.
  ///
  /// {@macro flutter.widgets.child}
  ///
  final Widget child;

  /// Whether to detect translation gestures during the event processing.
  ///
  /// Defaults to true.
  ///
  final bool shouldTranslate;

  /// Whether to detect scale gestures during the event processing.
  ///
  /// Defaults to true.
  ///
  final bool shouldScale;

  /// Whether to detect rotation gestures during the event processing.
  ///
  /// Defaults to true.
  ///
  final bool shouldRotate;

  /// Whether [ClipRect] widget should clip [child] widget.
  ///
  /// Defaults to true.
  ///
  final bool clipChild;

  /// When set, it will be used for computing a "fixed" focal point
  /// aligned relative to the size of this widget.
  final Alignment focalPointAlignment;

  final Matrix4 forceMatrix;

  const MatrixGestureDetector({
    Key key,
    @required this.onMatrixUpdate,
    @required this.child,
    this.infoCallback,
    this.shouldTranslate = true,
    this.shouldScale = true,
    this.shouldRotate = true,
    this.clipChild = true,
    this.focalPointAlignment = Alignment.center,
    this.forceMatrix,

  })  : assert(onMatrixUpdate != null),
        assert(child != null),
        super(key: key);



  @override
  _MatrixGestureDetectorState createState() => _MatrixGestureDetectorState();



  ///
  /// Compose the matrix from translation, scale and rotation matrices - you can
  /// pass a null to skip any matrix from composition.
  ///
  /// If [matrix] is not null the result of the composing will be concatenated
  /// to that [matrix], otherwise the identity matrix will be used.
  /// 生成一个Matrix 对象
  static Matrix4 compose(Matrix4 matrix, Matrix4 translationMatrix,
      Matrix4 scaleMatrix, Matrix4 rotationMatrix) {
    if (matrix == null) matrix = Matrix4.identity();
    if (translationMatrix != null) matrix = translationMatrix * matrix;
    if (scaleMatrix != null) matrix = scaleMatrix * matrix;
    if (rotationMatrix != null) matrix = rotationMatrix * matrix;
    return matrix;
  }

  ///
  /// Decomposes [matrix] into [MatrixDecomposedValues.translation],
  /// [MatrixDecomposedValues.scale] and [MatrixDecomposedValues.rotation] components.
  ///


  /// 将Matrix4 对象转换成  translation scale  rotation 的Values
  static MatrixDecomposedValues decomposeToValues(Matrix4 matrix) {
    var array = matrix.applyToVector3Array([0, 0, 0, 1, 0, 0]);
    Offset translation = Offset(array[0], array[1]);
    Offset delta = Offset(array[3] - array[0], array[4] - array[1]);
    double scale = delta.distance;
    double rotation = delta.direction;
    return MatrixDecomposedValues(translation, scale, rotation);
  }
}


///  MatrixGestureDetector 的 State  类.
///  默认添加了4个变量: matrix  整体的矩阵转换   translationDeltaMatrix translation的矩阵变换
///  scaleDeltaMatrix 缩放 矩阵变换  rotationDeltaMatrix 旋转矩阵变换
///
class _MatrixGestureDetectorState extends State<MatrixGestureDetector> {
  Matrix4 translationDeltaMatrix = Matrix4.identity();
  Matrix4 scaleDeltaMatrix = Matrix4.identity();
  Matrix4 rotationDeltaMatrix = Matrix4.identity();
  /// 保留所有的矩阵变换信息
  Matrix4 _matrix =  Matrix4.identity();

  Matrix4 get matrix {
    return _matrix;
  }

  set matrix(Matrix4 value) {
    _matrix = value;
    widget.infoCallback(_lastFocalPoint,matrix);
  }

  Offset _lastFocalPoint;


  Offset get lastFocalPoint => _lastFocalPoint;

  set lastFocalPoint(Offset value) {
    _lastFocalPoint = value;
    widget.infoCallback(_lastFocalPoint,matrix);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    matrix = widget.forceMatrix != null ? widget.forceMatrix : Matrix4.identity();
  }
  @override
  Widget build(BuildContext context) {
    /// 根据Widget 的命名构造函数传过来的参数来决定创建的子Widget是普通的Widget 还是 ClipRect 来包裹一层.
    /// 最终整体还是一个 GestureDetector 的Widget

    Timer(Duration(milliseconds: 100), (){
      Offset focalPoint;
      if (lastFocalPoint != null) {
        focalPoint = lastFocalPoint;
      } else if (widget.focalPointAlignment != null) {
        focalPoint = widget.focalPointAlignment.alongSize(context.size);
      }
      widget.infoCallback(focalPoint,matrix);
    });

    Widget child =
    widget.clipChild ? ClipRect(child: widget.child) : widget.child;
    return GestureDetector(
      onScaleStart: onScaleStart,
      onScaleUpdate: onScaleUpdate,
      child: child,
    );
  }

  /// 位移更新信息
  _ValueUpdater<Offset> translationUpdater = _ValueUpdater(
    onUpdate: (oldVal, newVal) => newVal - oldVal,
  );

  /// 旋转更新信息
  _ValueUpdater<double> rotationUpdater = _ValueUpdater(
    onUpdate: (oldVal, newVal) => newVal - oldVal,
  );

  /// 缩放(比例)更新信息
  _ValueUpdater<double> scaleUpdater = _ValueUpdater(
    onUpdate: (oldVal, newVal) => newVal / oldVal,
  );

  void onScaleStart(ScaleStartDetails details) {
    /// focal 焦点的  nan非数值
    /// 在手势开始时,给 translationUpdater  rotationUpdater scaleUpdater 的值赋初值
    translationUpdater.value = details.focalPoint;
    rotationUpdater.value = double.nan;
    scaleUpdater.value = 1.0;
  }

  void onScaleUpdate(ScaleUpdateDetails details) {
    /// 手势开始更新时, translationDeltaMatrix  scaleDeltaMatrix  rotationDeltaMatrix 都会被重新定义
    translationDeltaMatrix = Matrix4.identity();
    scaleDeltaMatrix = Matrix4.identity();
    rotationDeltaMatrix = Matrix4.identity();

    /// 处理矩阵移动
    // handle matrix translating
    if (widget.shouldTranslate) {
      Offset translationDelta = translationUpdater.update(details.focalPoint);
      translationDeltaMatrix = _translate(translationDelta);

      /// 将移动的矩阵和原来的matrix矩阵相乘得到新的matrix 矩阵
      matrix = translationDeltaMatrix * matrix;
    }

    /// 根据有没有设对齐方式来确定焦点. 旋转和缩放时以此focalPoint 为基准点来进行变换.
    Offset focalPoint;
    if (widget.focalPointAlignment != null) {
      focalPoint = widget.focalPointAlignment.alongSize(context.size);
    } else {
      RenderBox renderBox = context.findRenderObject();
      focalPoint = renderBox.globalToLocal(details.focalPoint);
    }
    lastFocalPoint = focalPoint;

    /// 处理scale matrix 变换.
    /// 因为现在是统一在scale 手势中处理scale 和  rotation 操作,所以根据手势中返回的scale 和  rotation 值来判断是否进行了scale 和  rotation 操作.
    // handle matrix scaling
    if (widget.shouldScale && details.scale != 1.0) {
      double scaleDelta = scaleUpdater.update(details.scale);
      scaleDeltaMatrix = _scale(scaleDelta, focalPoint);
      matrix = scaleDeltaMatrix * matrix;
    }


    /// 处理旋转矩阵变换
    // handle matrix rotating
    if (widget.shouldRotate && details.rotation != 0.0) {
      if (rotationUpdater.value.isNaN) {
        rotationUpdater.value = details.rotation;
      } else {
        double rotationDelta = rotationUpdater.update(details.rotation);
        rotationDeltaMatrix = _rotate(rotationDelta, focalPoint);
        matrix = rotationDeltaMatrix * matrix;
      }
    }

    /// 将最终的矩阵变换matrix 和 各自的translationDeltaMatrix scaleDeltaMatrix rotationDeltaMatrix 回传.
    widget.onMatrixUpdate(
        matrix, translationDeltaMatrix, scaleDeltaMatrix, rotationDeltaMatrix);
  }

  /// 将位移的dx和dy 转变成 translate的Matrix4对象
  Matrix4 _translate(Offset translation) {
    var dx = translation.dx;
    var dy = translation.dy;

    //  ..[0]  = 1       # x scale
    //  ..[5]  = 1       # y scale
    //  ..[10] = 1       # diagonal "one"
    //  ..[12] = dx      # x translation
    //  ..[13] = dy      # y translation
    //  ..[15] = 1       # diagonal "one"
    return Matrix4(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, dx, dy, 0, 1);
  }

  /// 将缩放比例scale 和 焦点focalPoint  转变成 translate的Matrix4对象
  Matrix4 _scale(double scale, Offset focalPoint) {
    var dx = (1 - scale) * focalPoint.dx;
    var dy = (1 - scale) * focalPoint.dy;

    //  ..[0]  = scale   # x scale
    //  ..[5]  = scale   # y scale
    //  ..[10] = 1       # diagonal "one"
    //  ..[12] = dx      # x translation
    //  ..[13] = dy      # y translation
    //  ..[15] = 1       # diagonal "one"
    return Matrix4(scale, 0, 0, 0, 0, scale, 0, 0, 0, 0, 1, 0, dx, dy, 0, 1);
  }

  /// 将旋转角度 和 焦点focalPoint  转变成 rotate的Matrix4对象
  Matrix4 _rotate(double angle, Offset focalPoint) {
    var c = cos(angle);
    var s = sin(angle);
    var dx = (1 - c) * focalPoint.dx + s * focalPoint.dy;
    var dy = (1 - c) * focalPoint.dy - s * focalPoint.dx;

    //  ..[0]  = c       # x scale
    //  ..[1]  = s       # y skew
    //  ..[4]  = -s      # x skew
    //  ..[5]  = c       # y scale
    //  ..[10] = 1       # diagonal "one"
    //  ..[12] = dx      # x translation
    //  ..[13] = dy      # y translation
    //  ..[15] = 1       # diagonal "one"
    return Matrix4(c, s, 0, 0, -s, c, 0, 0, 0, 0, 1, 0, dx, dy, 0, 1);
  }



  /// 手动添加该方法,在当前总的Matrix4 中更新scale 值,返回最新的Matrix4 对象
  Matrix4 updatescale(double scale) {
    Offset focalPoint;
    if (lastFocalPoint != null) {
      focalPoint = lastFocalPoint;
    } else if (widget.focalPointAlignment != null) {
      focalPoint = widget.focalPointAlignment.alongSize(context.size);
    }

    var dx = (1 - scale) * focalPoint.dx;
    var dy = (1 - scale) * focalPoint.dy;

    matrix[0] = scale;
    matrix[5] = scale;
    matrix[12] = dx;
    matrix[13] = dy;

    return matrix;
  }

  /// 手动添加该方法,在当前总的Matrix4 中更新rotate 值,返回最新的Matrix4 对象
  Matrix4 updateRotate(double angle) {
    var c = cos(angle);
    var s = sin(angle);

    Offset focalPoint;
    if (lastFocalPoint != null) {
      focalPoint = lastFocalPoint;
    } else if (widget.focalPointAlignment != null) {
      focalPoint = widget.focalPointAlignment.alongSize(context.size);
    }

    var dx = (1 - c) * focalPoint.dx + s * focalPoint.dy;
    var dy = (1 - c) * focalPoint.dy - s * focalPoint.dx;

    /// x scale
    matrix[0]  = c;
    matrix[1]  = s;       // y skew
    matrix[4]  = -s;      // x skew
    matrix[5]  = c;       // y scale
    matrix[12] = dx;      //# x translation
    matrix[13] = dy;      //# y translation
    return matrix;
  }



}



/// 重定义一个方法,定义后的方法名为 _OnUpdate<T>. 方法返回值为T
typedef _OnUpdate<T> = T Function(T oldValue, T newValue);

/// 声明一个类 _ValueUpdater, 该类是私有类. 该类遵循泛型T
class _ValueUpdater<T> {

  /// 声明一个函数对象
  final _OnUpdate<T> onUpdate;
  T value;


  /// 构造函数
  _ValueUpdater({this.onUpdate});

  /// 带返回值的方法.方法名: update ,参数:  newValue
  T update(T newValue) {
    T updated = onUpdate(value, newValue);
    value = newValue;
    return updated;
  }
}

class MatrixDecomposedValues {
  /// Translation, in most cases useful only for matrices that are nothing but
  /// a translation (no scale and no rotation).
  final Offset translation;

  /// Scaling factor.
  final double scale;

  /// Rotation in radians, (-pi..pi) range.
  final double rotation;

  MatrixDecomposedValues(this.translation, this.scale, this.rotation);

  @override
  String toString() {
    return 'MatrixDecomposedValues(translation: $translation, scale: ${scale.toStringAsFixed(3)}, rotation: ${rotation.toStringAsFixed(3)})';
  }
}
