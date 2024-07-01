import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/provider/anak_provider.dart';
import 'package:app/component/My_textfield.dart';
import 'package:app/models/user.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context, listen: false);
    final anaksProvider = Provider.of<AnakProvider>(context, listen: false);
    
    // Check if user is already logged in
    userModel.authService.isLoggedIn().then((isLoggedIn) {
      if (isLoggedIn) {
        Navigator.pushReplacementNamed(context, '/mainscreen');
      }
    });

    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'KidsZoo',
                  style: TextStyle(
                    color: Colors.blue[900],
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                MyTextfield(
                  hintText: 'Username',
                  obscure: false,
                  textController: _emailController,
                ),
                SizedBox(height: 20),
                MyTextfield(
                  hintText: 'Password',
                  obscure: true,
                  textController: _pwController,
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    userModel.login(
                        _emailController.text, _pwController.text, context);
                  },
                  child: Text('GO', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Don't have an account yet? ",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/profilanak');
                      },
                      child: Text(
                        'Sign up',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            child: Image.asset(
              'assets/images/naga.png',
              alignment: Alignment.bottomCenter,
              scale: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
