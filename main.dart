import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(XOGame());

class XOGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'XO Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('XO Game'),
        ),
        body: Center(
          child: XOBoard(),
        ),
      ),
    );
  }
}

class XOBoard extends StatefulWidget {
  @override
  _XOBoardState createState() => _XOBoardState();
}

class _XOBoardState extends State<XOBoard> {
  late List<List<String>> board;
  late bool player1Turn;

  @override
  void initState() {
    super.initState();
    initializeBoard();
  }

  void initializeBoard() {
    board = List.generate(3, (_) => List.filled(3, ""));
    player1Turn = true;
    if (!player1Turn) {
      Future.delayed(Duration(milliseconds: 1000), () {
        _computerMove();
        if (_checkWin("O")) {
          _showDialog("Sorry! Computer wins!");
          return;
        }
        if (_checkDraw()) {
          _showDialog("It's a draw!");
          return;
        }
      });
    }
  }

  void _handleTap(int row, int col) {
    if (board[row][col] == "") {
      setState(() {
        board[row][col] = "X";
        player1Turn = !player1Turn;
      });
      if (_checkWin("X")) {
        _showDialog("Congratulations! You win!");
        return;
      }
      if (_checkDraw()) {
        _showDialog("It's a draw!");
        return;
      }
      if (!player1Turn) {
        Future.delayed(Duration(milliseconds: 1000), () {
          _computerMove();
          setState(() {
            if (_checkWin("O")) {
              _showDialog("Sorry! Computer wins!");
              return;
            }
            if (_checkDraw()) {
              _showDialog("It's a draw!");
              return;
            }
          });
        });
      }
    }
  }



  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Game Over",
            style: TextStyle(fontSize: 24.0,color: Colors.red)),
          content: Text(message),
          actions: [
            MaterialButton(
              onPressed: () {
                Navigator.of(context).pop();
                initializeBoard();
                setState(() {
                });
              },
              child: Text("Play Again"),
            ),
          ],
        );
      },
    );
  }

  void _computerMove() {
    int bestScore = -10;
    int moveRow = -1;
    int moveCol = -1;

    for (int i = 0; i < board.length; i++) {
      for (int j = 0; j < board[i].length; j++) {
        if (board[i][j] == "") {
          board[i][j] = "O";
          int score = checkCom_Move(board, 0, false);
          board[i][j] = "";
          if (score > bestScore) {
            bestScore = score;
            moveRow = i;
            moveCol = j;
          }
        }
      }
    }

    board[moveRow][moveCol] = "O";
    player1Turn = true;
  }

  int checkCom_Move(List<List<String>> board, int depth, bool isclose) {
    if (_checkWin("X")) return -10;
    if (_checkWin("O")) return 10;
    if (_checkDraw()) return 0;

    if (isclose) {
      int bestScore = -10;
      for (int i = 0; i < board.length; i++) {
        for (int j = 0; j < board[i].length; j++) {
          if (board[i][j] == "") {
            board[i][j] = "O";
            int score = checkCom_Move(board, depth + 1, false);
            board[i][j] = "";
            bestScore = max(score, bestScore);
          }
        }
      }
      return bestScore;
    } else {
      int bestScore = 10;
      for (int i = 0; i < board.length; i++) {
        for (int j = 0; j < board[i].length; j++) {
          if (board[i][j] == "") {
            board[i][j] = "X";
            int score = checkCom_Move(board, depth + 1, true);
            board[i][j] = "";
            bestScore = min(score, bestScore);
          }
        }
      }
      return bestScore;
    }
  }

  bool _checkWin(String player) {
    for (int i = 0; i < board.length; i++) {
      if (board[i][0] == player &&
          board[i][1] == player &&
          board[i][2] == player) {
        return true;
      }
    }
    for (int i = 0; i < board[0].length; i++) {
      if (board[0][i] == player &&
          board[1][i] == player &&
          board[2][i] == player) {
        return true;
      }
    }
    if (board[0][0] == player &&
        board[1][1] == player &&
        board[2][2] == player) {
      return true;
    }
    if (board[0][2] == player &&
        board[1][1] == player &&
        board[2][0] == player) {
      return true;
    }
    return false;
  }

  bool _checkDraw() {
    for (int i = 0; i < board.length; i++) {
      for (int j = 0; j < board[i].length; j++) {
        if (board[i][j] == "") {
          return false;
        }
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Column(
          children: board
              .asMap()
              .entries
              .map((entry) => _buildRow(entry.key, entry.value))
              .toList(),
        ),
        SizedBox(height: MediaQuery.of(context).size.height *.03),
        MaterialButton(
          color: Colors.black,
          onPressed: (){
            setState(() {
            });
            initializeBoard();
          },
          child: Text('Reset',style: TextStyle(
    fontSize: MediaQuery.of(context).size.height *.03,
    color: Colors.red),
        ),
        )],
    );
  }

  Widget _buildRow(int rowIndex, List<String> row) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: row.asMap().entries.map((entry) {
        int colIndex = entry.key;
        String value = entry.value;
        return GestureDetector(
          onTap: () => _handleTap(rowIndex, colIndex),
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(),
            ),
            child: Center(
              child: Text(
                value,
                style: TextStyle(fontSize: 24.0,color: Colors.blue),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
