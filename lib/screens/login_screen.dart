import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'register_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String? errorMessage;

  Future<void> login() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? saved = prefs.getString(emailController.text.trim());
    if (saved == null) {
      setState(() => errorMessage = "등록되지 않은 이메일입니다.");
      return;
    }
    List<String> arr = saved.split('||');
    String savedPw = arr[0];
    String name = arr.length > 1 ? arr[1] : '';
    if (savedPw != passwordController.text) {
      setState(() => errorMessage = "비밀번호가 일치하지 않습니다.");
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(name: name, email: emailController.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(controller: emailController, decoration: InputDecoration(labelText: 'Email')),
              TextField(controller: passwordController, decoration: InputDecoration(labelText: 'Password'), obscureText: true),
              SizedBox(height: 20),
              ElevatedButton(onPressed: login, child: Text("로그인")),
              TextButton(
                child: Text("회원가입"),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterScreen()));
                },
              ),
              if (errorMessage != null)
                Text(errorMessage!, style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ),
    );
  }
}
