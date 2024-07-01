import 'package:app/component/My_textfield.dart';
import 'package:app/models/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignUpPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _confirmPwController = TextEditingController();

  void register(BuildContext context) async {
    final userModel = Provider.of<UserModel>(context, listen: false);
    if (_pwController.text == _confirmPwController.text) {
      try {
        await userModel.login(
            _emailController.text, _pwController.text, context);
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(title: Text(e.toString())),
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(title: Text("Passwords don't match!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                SizedBox(height: 40),
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
                SizedBox(height: 20),
                MyTextfield(
                  hintText: 'Confirm Password',
                  obscure: true,
                  textController: _confirmPwController,
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () => register(context),
                  child: Text('SIGN UP', style: TextStyle(color: Colors.white)),
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
                      "Already have an account? ",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/Login');
                      },
                      child: Text(
                        'Login',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
          Container(
            width: 400,
            child: Image.asset(
              alignment: Alignment.bottomCenter,
              scale: 1.48,
              'assets/images/naga.png',
              fit: BoxFit.none, // Ensure your image path is correct
            ),
          ),
        ],
      ),
    );
  }
}
