import 'package:flutter/material.dart';
import 'package:app/screens/children/homepage.dart';
import 'package:app/screens/main/main_screen.dart';

class HomepageDrawer extends StatelessWidget {
  final bool quiz;

  const HomepageDrawer({Key? key, required this.quiz}) : super(key: key);

  void _showPasswordDialog(BuildContext context) {
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Password'),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Password',
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('OK'),
              onPressed: () {
                if (passwordController.text == '12345') {
                  Navigator.of(context).pop();
                  Navigator.popAndPushNamed(context, '/MainScreen');
                } else {
                  // Show an error message if the password is incorrect
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Incorrect password'),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.lightBlueAccent,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Hallo !!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: Colors.white),
              title: Text(
                'Dashboard Guru',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                _showPasswordDialog(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.quiz, color: Colors.white),
              title: Text(
                quiz ? 'Homepage' : 'Quiz',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.of(context).pop();
                if (quiz) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(quiz: false),
                    ),
                  );
                } else {
                  // Handle the Quiz navigation
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(
                        quiz: true,
                      ), // Replace with your Quiz screen
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
