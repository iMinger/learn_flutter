import 'package:flutter/material.dart';
import 'about.dart';
import 'router/router.dart';
import 'unknown.dart';
import 'detail.dart';

void main() => runApp(MyApp());


class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          primarySwatch: Colors.blue, splashColor: Colors.transparent),
      routes: HYRouter.routes,
      initialRoute: HYRouter.initialRoute,
      onGenerateRoute: HYRouter.generateRoute,
      onUnknownRoute: HYRouter.unknownRoute,
    );
  }
}

class HYHomePage extends StatefulWidget {
  static const String routeName = "/";

  @override
  _HYHomePageState createState() => _HYHomePageState();
}

class _HYHomePageState extends State<HYHomePage> {
  String _homeMessage = "default message";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("首页"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_homeMessage, style: TextStyle(fontSize: 20, color: Colors.red),),
            RaisedButton(
              child: Text("跳转到详情"),
              onPressed: () => _jumpToDetail(context),
            ),
            RaisedButton(
              child: Text("跳转到关于"),
              onPressed: () => _jumpToAbout(context),
            ),
            RaisedButton(
              child: Text("跳转到详情"),
              onPressed: () => _jumpToDetail2(context),
            ),
            RaisedButton(
              child: Text("跳转到设置"),
              onPressed: () => _jumpToSettings(context),
            ),
          ],
        ),
      ),
    );
  }

  void _jumpToDetail(BuildContext context) {
    // 1.普通的跳转方式
    // 传递参数: 通过构造器直接传递即可
    Future result = Navigator.of(context).push(MaterialPageRoute(
      builder: (ctx) {
        return HYDetailPage("a home message");
      }
    ));

    result.then((res) {
      setState(() {
        _homeMessage = res;
      });
    });
  }

  void _jumpToAbout(BuildContext context) {
    Navigator.of(context).pushNamed(HYAboutPage.routeName, arguments: "a home message");
  }

  void _jumpToDetail2(BuildContext context) {
    Navigator.of(context).pushNamed(HYDetailPage.routeName, arguments: "a home detail2 message");
  }

  void _jumpToSettings(BuildContext context) {
    Navigator.of(context).pushNamed("/aaaa");
  }
}

