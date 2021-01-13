import 'dart:async';

import 'package:flutter/material.dart';

class HYAboutPage extends StatefulWidget {
  static const String routeName = "/detail";

  @override
  _HYAboutPageState createState() => _HYAboutPageState();
}

class _HYAboutPageState extends State<HYAboutPage> {

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      final String message = ModalRoute.of(context).settings.arguments as String;
      print(message);
    });

    Timer.run(() {
      final String message = ModalRoute.of(context).settings.arguments as String;
      print(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    final String message = ModalRoute.of(context).settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: Text("关于页"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(message),
            RaisedButton(
              child: Text("返回首页"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        ),
      ),
    );
  }
}
