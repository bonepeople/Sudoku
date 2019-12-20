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
            number: number,
          ));
        }
      }
    }

    return Padding(
      padding: EdgeInsets.only(top: top),
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.centerLeft,
            color: Colors.black12,
            height: 44,
            child: IconButton(
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
          ),
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
}

class NumberBoxView extends StatelessWidget {
  final int row, column, number;

  NumberBoxView(this.row, this.column, {this.number});

  @override
  Widget build(BuildContext context) {
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

    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            color: row == currentRow || column == currentColumn
                ? Colors.black12
                : Colors.white),
        alignment: Alignment.center,
        child: Text(
          '${number == null ? '' : '$number'}',
          style: TextStyle(color: textColor),
        ),
      ),
      onTap: () => clickBox(row, column, number),
    );
  }
}

void clickBox(int row, int column, int number) {
  if (row != 0 && column != 0) {
    currentRow = row;
    currentColumn = column;
  } else {
    table.changeValue(currentRow, currentColumn, number);
  }
  __PageState.updateState();
}

class TableModel {
  List all = List(10);

  TableModel() {
    for (int rowIndex = 1; rowIndex <= 9; rowIndex++) {
      all[rowIndex] = List(10);
      for (int columnIndex = 1; columnIndex <= 9; columnIndex++) {
        NumberBoxModel box = NumberBoxModel(rowIndex, columnIndex);
        all[rowIndex][columnIndex] = box;
      }
    }
  }

  changeValue(int row, int column, number) {
    if (number < 1 || number > 9) return;
    NumberBoxModel boxData;
    //当前格子
    boxData = all[row][column];
    boxData.ensure = true;
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

class NumberBoxModel {
  int boxRow;
  int boxColumn;
  bool ensure = false;
  int value;
  List expect = <int>[1, 2, 3, 4, 5, 6, 7, 8, 9];

  NumberBoxModel(this.boxRow, this.boxColumn);

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
