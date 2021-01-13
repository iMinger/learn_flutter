import 'package:flutter/material.dart';

class ImageDemo02 extends StatelessWidget {
  const ImageDemo02({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset("assets/images/juren.jpeg");
  }
}

class ImageDemo01 extends StatelessWidget {
  const ImageDemo01({
    Key key,
    @required this.imageURL,
  }) : super(key: key);

  final String imageURL;

  @override
  Widget build(BuildContext context) {
    // Image.network(imageURL)
    return Image(
      color: Colors.green,
      colorBlendMode: BlendMode.colorDodge,
      image: NetworkImage(imageURL),
      width: 200,
      height: 200,
      fit: BoxFit.contain,
      repeat: ImageRepeat.repeatY,
//      alignment: Alignment.bottomCenter,
//    范围: -1 1
      alignment: Alignment(0, 0),
    );
  }
}
