import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  String? errorMessage;

  Future<void> register() async {
    String email = emailController.text.trim();
    String name = nameController.text.trim();
    String pw = passwordController.text;
    String cpw = confirmController.text;

    if (name.isEmpty || email.isEmpty || pw.isEmpty || cpw.isEmpty) {
      setState(() => errorMessage = "모든 항목을 입력하세요.");
      return;
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      setState(() => errorMessage = "이메일 형식이 올바르지 않습니다.");
      return;
    }
    if (pw.length < 6) {
      setState(() => errorMessage = "비밀번호는 6자 이상이어야 합니다.");
      return;
    }
    if (pw != cpw) {
      setState(() => errorMessage = "비밀번호가 일치하지 않습니다.");
      return;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString(email) != null) {
      setState(() => errorMessage = "이미 등록된 이메일입니다.");
      return;
    }
    await prefs.setString(email, "$pw||$name");
    setState(() => errorMessage = "회원가입 성공! 로그인 화면으로 이동합니다.");
    Future.delayed(Duration(seconds: 1), () {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("회원가입")),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(controller: nameController, decoration: InputDecoration(labelText: '이름')),
              TextField(controller: emailController, decoration: InputDecoration(labelText: 'Email')),
              TextField(controller: passwordController, decoration: InputDecoration(labelText: '비밀번호'), obscureText: true),
              TextField(controller: confirmController, decoration: InputDecoration(labelText: '비밀번호 확인'), obscureText: true),
              SizedBox(height: 20),
              ElevatedButton(onPressed: register, child: Text("회원가입")),
              if (errorMessage != null)
                Text(errorMessage!, style: TextStyle(color: errorMessage!.contains("성공") ? Colors.green : Colors.red)),
            ],
          ),
        ),
      ),
    );
  }
}
