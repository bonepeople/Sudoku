import 'package:calculate/GamePage.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '数独解密小程序',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: '数独解密小程序'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        padding: EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            ParagraphText('1.这是一个解密数独题的小程序，点击右下角的按钮进入数独界面。'),
            ParagraphText('2.进入页面后会显示一个空的数独表格，用户需要点击对应的格子填入已知的数字。'),
            ParagraphText('3.在填写数字的过程中，底部的候选项会自动推断可能填写的数字。'),
            ParagraphText('4.如果填写错误可以再次选中错误的格子进行更正，如果填入的数字与其他格子有冲突则会将数字标红显示。'),
            ParagraphText('5.在用户无法人为推断格子中的数字时可以点击顶部的帮助按钮，系统将尝试补全格子中的数字'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => GamePage())),
        tooltip: '打开',
        child: Icon(Icons.arrow_forward),
      ),
    );
  }
}

class ParagraphText extends StatelessWidget {
  final String text;

  ParagraphText(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Text(text),
    );
  }
}
