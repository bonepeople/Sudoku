import 'package:flutter/material.dart';
import 'dart:math' as math;

int currentRow = 0;
int currentColumn = 0;
TableModel table = TableModel();

class GamePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _Page(),
    );
  }
}

class _Page extends StatefulWidget {
  @override
  __PageState createState() => __PageState();
}

class __PageState extends State<_Page> {
  static __PageState instance;

  __PageState() {
    instance = this;
  }

  static void updateState() {
    instance.setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    EdgeInsets padding = MediaQuery.of(context).padding;
    double top = math.max(padding.top, EdgeInsets.zero.top);

    //创建游戏区域的81个格子控件
    var blocks = <Widget>[];
    for (int i = 1; i <= 9; i++) {
      for (int j = 1; j <= 9; j++) {
        NumberBoxModel boxData = table.all[i][j];
        if (boxData.ensure)
          blocks.add(NumberBoxView(
            i,
            j,
            number: boxData.value,
          ));
        else
          blocks.add(NumberBoxView(i, j));
      }
    }
    //创建候选区域的控件
    var select = <Widget>[];
    if (currentRow > 0 && currentColumn > 0) {
      NumberBoxModel boxData = table.all[currentRow][currentColumn];
      if (!boxData.ensure) {
        for (int number in boxData.expect) {
          select.add(NumberBoxView(
            0,
            0,
            number: number,
          ));
        }
      } else {
        for (int number = 1; number <= 9; number++) {
          select.add(NumberBoxView(
            0,
            0,
            number: number == boxData.value ? 0 : number,
          ));
        }
      }
    }

    return Padding(
      padding: EdgeInsets.only(top: top),
      child: Column(
        children: <Widget>[
          //标题栏
          Container(
            alignment: Alignment.centerLeft,
            color: Colors.black12,
            height: 44,
            child: Row(
              children: <Widget>[
                IconButton(
                  icon: Image.asset(
                    'assets/arrow_left.png',
                    width: 20,
                    height: 20,
                  ),
                  iconSize: 10,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: GestureDetector(
                    child: Icon(
                      Icons.help,
                    ),
                    onTap: () {
                      help();
                    },
                  ),
                ),
              ],
            ),
          ),
          //游戏区域
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              padding: EdgeInsets.all(20),
              child: GridView(
                padding: EdgeInsets.all(0),
                physics: ScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 9),
                children: blocks,
              ),
            ),
          ),
          //候选区域
          Padding(
              padding: EdgeInsets.only(top: 20, left: 20, right: 20),
              child: AspectRatio(
                aspectRatio: 9,
                child: GridView(
                  padding: EdgeInsets.all(0),
                  physics: ScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 9),
                  children: select,
                ),
              ))
        ],
      ),
    );
  }

  //帮助功能，自动填充表格
  void help() {
    bool changed = false;
    //遍历81个格子，查找唯一数字
    for (int i = 1; i <= 9; i++) {
      for (int j = 1; j <= 9; j++) {
        NumberBoxModel boxData = table.all[i][j];
        //当前格子未被用户选择且备选数字只有一个则将其设置为备选数字
        if (!boxData.ensure && boxData.expect.length == 1) {
          table.changeValue(i, j, boxData.expect[0]);
          currentRow = i;
          currentColumn = j;
          changed = true;
          print("bone row = $i column = $j x = ${boxData.expect[0]}");
          break;
        }
      }
      if (changed) break;
    }
    //逐行排查唯一候选项
    if (!changed) {
      List<NumberBoxModel> list = List();
      for (int i = 1; i <= 9 && !changed; i++) {
        //将第i行格子放入列表中
        for (int j = 1; j <= 9; j++) {
          list.add(table.all[i][j]);
        }
        //查找第i行的唯一数字
        print("bone 查找第$i行");
        changed = findSingleNumber(list);
        list.clear();
      }
    }
    //逐列排查唯一候选项
    if (!changed) {
      List<NumberBoxModel> list = List();
      for (int i = 1; i <= 9 && !changed; i++) {
        //将第i列格子放入列表中
        for (int j = 1; j <= 9; j++) {
          list.add(table.all[j][i]);
        }
        //查找第i列的唯一数字
        print("bone 查找第$i列");
        changed = findSingleNumber(list);
        list.clear();
      }
    }
    //逐块排查唯一候选项
    if (!changed) {
      List<NumberBoxModel> list = List();
      for (int i = 1; i <= 9 && !changed; i++) {
        int startRow = ((i - 1) / 3).floor() * 3 + 1;
        int endRow = startRow + 2;
        int startColumn = (i % 3) * (i % 3);
        if (startColumn == 0) startColumn = 7;
        int endColumn = startColumn + 2;
        //将第i块的格子放入列表中
        for (int row = startRow; row <= endRow; row++) {
          for (int column = startColumn; column <= endColumn; column++) {
            list.add(table.all[row][column]);
          }
        }
        //查找第i列的唯一数字
        print("bone 查找第$i块");
        changed = findSingleNumber(list);
        list.clear();
      }
    }
    //找到之后更新页面，否则显示对话框进行提示
    if (changed) {
      updateState();
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text('暂时没有找到可以自动填充的格子'),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('确定'),
              )
            ],
          );
        },
      );
    }
  }

  //在给定数组中查找唯一数字，若找到则将更新数据并返回true，未找到则返回false
  //所有未选择的格子都有多个候选项，但如果某一个候选项只出现过一次，则表明此格子一定是这个候选项
  bool findSingleNumber(List<NumberBoxModel> list) {
    //从候选数字1-9依次查找
    for (int x = 1; x <= 9; x++) {
      int i = 0, j = 0, count = 0;
      for (NumberBoxModel box in list) {
        //若目标格子的期望值中包含所查找的数字，则记录位置并且计数器自增
        if (!box.ensure && box.expect.contains(x)) {
          i = box.boxRow;
          j = box.boxColumn;
          count++;
          //计数器自增至2的时候中断循环
          if (count > 1) break;
        }
      }
      //当格子遍历完成后计数器为1，则表明当前记录的格子数字可以确定为查找的数字，返回true
      if (count == 1) {
        table.changeValue(i, j, x);
        currentRow = i;
        currentColumn = j;
        print("bone row = $i column = $j x = $x");
        return true;
      }
    }
    return false;
  }
}

//数字框所对应的控件
class NumberBoxView extends StatelessWidget {
  final int row, column, number;

  NumberBoxView(this.row, this.column, {this.number});

  @override
  Widget build(BuildContext context) {
    BorderDirectional border = BorderDirectional(
      top: BorderSide(color: row % 3 == 1 ? Colors.black : Colors.grey),
      bottom: BorderSide(
          color: row % 3 == 0 && row != 0 ? Colors.black : Colors.grey),
      start: BorderSide(color: column % 3 == 1 ? Colors.black : Colors.grey),
      end: BorderSide(
          color: column % 3 == 0 && column != 0 ? Colors.black : Colors.grey),
    );

    Color textColor;
    if (row == 0 || column == 0)
      textColor = Colors.black;
    else {
      NumberBoxModel data = table.all[row][column];
      if (data.expect.contains(data.value)) {
        textColor = Colors.black;
      } else {
        textColor = Colors.red;
      }
    }
    String text;
    if (number == null)
      text = '';
    else if (number == 0)
      text = '?';
    else
      text = number.toString();

    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
            border: border,
            color: row == currentRow || column == currentColumn
                ? Colors.black12
                : Colors.white),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(color: textColor),
        ),
      ),
      onTap: () => clickBox(row, column, number),
    );
  }
}

//数字框控件的点击事件函数
void clickBox(int row, int column, int number) {
  if (row != 0 && column != 0) {
    currentRow = row;
    currentColumn = column;
  } else {
    table.changeValue(currentRow, currentColumn, number);
  }
  __PageState.updateState();
}

//页面的数据模型，主要负责维护页面内的数据
class TableModel {
  List<List<NumberBoxModel>> all = List(10);

  TableModel() {
    for (int rowIndex = 1; rowIndex <= 9; rowIndex++) {
      all[rowIndex] = List(10);
      for (int columnIndex = 1; columnIndex <= 9; columnIndex++) {
        NumberBoxModel box = NumberBoxModel(rowIndex, columnIndex);
        all[rowIndex][columnIndex] = box;
      }
    }
  }

  //更新指定位置的数字并更新所影响格子的数据
  changeValue(int row, int column, number) {
    if (number < 0 || number > 9) return;
    NumberBoxModel boxData;
    //当前格子
    boxData = all[row][column];
    boxData.ensure = number != 0;
    boxData.value = number;
    //行、列
    for (int i = 1; i <= 9; i++) {
      boxData = all[row][i];
      boxData.calculateExpect();

      boxData = all[i][column];
      boxData.calculateExpect();
    }
    //块
    int startRow = row - (row % 3 == 0 ? 3 : row % 3) + 1;
    int endRow = startRow + 2;
    int startColumn = column - (column % 3 == 0 ? 3 : column % 3) + 1;
    int endColumn = startColumn + 2;
    for (int i = startRow; i <= endRow; i++)
      for (int j = startColumn; j <= endColumn; j++) {
        boxData = table.all[i][j];
        boxData.calculateExpect();
      }
  }
}

//数据框所对应的数据模型
class NumberBoxModel {
  int boxRow;
  int boxColumn;
  bool ensure = false;
  int value;
  List expect = <int>[1, 2, 3, 4, 5, 6, 7, 8, 9];

  NumberBoxModel(this.boxRow, this.boxColumn);

  //计算当前位置可能出现的数字
  calculateExpect() {
    Set numbers = Set();
    NumberBoxModel boxData;
    //行、列
    for (int i = 1; i <= 9; i++) {
      boxData = table.all[boxRow][i];
      if (i != boxColumn && boxData.ensure) numbers.add(boxData.value);

      boxData = table.all[i][boxColumn];
      if (i != boxRow && boxData.ensure) numbers.add(boxData.value);
    }
    //块
    int startRow = boxRow - (boxRow % 3 == 0 ? 3 : boxRow % 3) + 1;
    int endRow = startRow + 2;
    int startColumn = boxColumn - (boxColumn % 3 == 0 ? 3 : boxColumn % 3) + 1;
    int endColumn = startColumn + 2;
    for (int i = startRow; i <= endRow; i++)
      for (int j = startColumn; j <= endColumn; j++) {
        boxData = table.all[i][j];
        if (i != boxRow && j != boxColumn && boxData.ensure)
          numbers.add(boxData.value);
      }
    expect.clear();
    for (int i = 1; i <= 9; i++) {
      if (!numbers.contains(i)) expect.add(i);
    }
  }
}
