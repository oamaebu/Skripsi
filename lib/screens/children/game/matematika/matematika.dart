import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(MathGameApp());

class MathGameApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Math Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MathGamePage(),
    );
  }
}

class MathGamePage extends StatefulWidget {
  @override
  _MathGamePageState createState() => _MathGamePageState();
}

class _MathGamePageState extends State<MathGamePage> {
  final TextEditingController _answerController = TextEditingController();
  late int _num1;
  late int _num2;
  String _feedback = '';

  @override
  void initState() {
    super.initState();
    _generateNewProblem();
  }

  void _generateNewProblem() {
    final random = Random();
    setState(() {
      _num1 = random.nextInt(10) + 1;
      _num2 = random.nextInt(10) + 1;
      _answerController.clear();
      _feedback = '';
    });
  }

  void _checkAnswer() {
    final answer = int.tryParse(_answerController.text);
    if (answer == _num1 + _num2) {
      setState(() {
        _feedback = 'Correct! Good job!';
      });
    } else {
      setState(() {
        _feedback = 'Try again!';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      appBar: AppBar(
        title: Text(
          'Math Game',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Solve the following problem:',
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
            SizedBox(height: 20),
            Text(
              '$_num1 + $_num2 = ?',
              style: TextStyle(fontSize: 32, color: Colors.white),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _answerController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter your answer',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkAnswer,
              child: Text('Check Answer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              _feedback,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _feedback == 'Correct! Good job!'
                    ? Colors.green
                    : Colors.red,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _generateNewProblem,
              child: Text('New Problem'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
